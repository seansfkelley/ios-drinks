//
//  RecipeIndex.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/6/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

typealias JSONObject = NSDictionary

func loadJSONArrayFromPath(path: String) -> JSONObject[] {
    var error: NSError?
    let jsonData = NSData.dataWithContentsOfFile(path, options: nil, error: &error)
    let parsedObject = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as JSONObject[]

    if let actualError = error {
        println("Error while parsing JSON: \(actualError)")
        return []
    } else {
        return parsedObject
    }
}

func _loadDefaultIngredientsFromJSON() -> Ingredient[] {
    var loadedIngredients = loadJSONArrayFromPath(NSBundle.mainBundle().pathForResource("ingredients", ofType: ".json")).map({ Ingredient(fromParsedJson: $0) })
    var allIngredients = loadedIngredients.copy()
    var knownTags = Set(array: loadedIngredients.map { $0.tag })
    for i in loadedIngredients {
        if i.genericTag && !knownTags[i.genericTag!] {
            println("\(i) refers to unknown generic '\(i.genericTag)'; inferring hidden ingredient")
            allIngredients.append(Ingredient(displayName: "[inferred] \(i.genericTag!)", tag: i.genericTag!, genericTag: nil, isHidden: true))
            knownTags.put(i.genericTag!)
        }
    }
    return allIngredients
}

let _RecipeIndex_INSTANCE = RecipeIndex()

let _RecipeIndex_INGREDIENTS = _loadDefaultIngredientsFromJSON()

let _RecipeIndex_FUZZY_MATCH_COUNT = 2

let _RecipeIndex_DATA_FILE_PATH = "\(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])/custom-drinks.dat"

let _RecipeIndex_SELECTED_INGREDIENTS_KEY = "selected-ingredients"

class RecipeIndex {
    let allIngredients = _RecipeIndex_INGREDIENTS
    let allRecipes: Recipe[]

    let _tagToIngredient: Dictionary<String, Ingredient>

    class func instance() -> RecipeIndex {
        return _RecipeIndex_INSTANCE
    }

    init() {
        self._tagToIngredient = Dictionary<String, Ingredient>()
        for i in self.allIngredients {
            self._tagToIngredient[i.tag] = i
        }

        self.allRecipes = [] // Why is this necessary?!
        self.allRecipes = loadJSONArrayFromPath(NSBundle.mainBundle().pathForResource("recipes", ofType: ".json")).map({ Recipe(fromParsedJson: $0, withIngredients: self._tagToIngredient) })
    }

    class func generateDummySearchResultFor(recipe: Recipe) -> RecipeSearchResult {
        return self.generateRecipeSearchResultFor(recipe, withAvailableTags: Set(array: _RecipeIndex_INGREDIENTS.map { $0.tag }))
    }

    class func generateRecipeSearchResultFor(recipe: Recipe, withAvailableTags tags: Set<String>) -> RecipeSearchResult {
        var missing: MeasuredIngredient[] = []
        var substitutes: MeasuredIngredient[] = []
        var available: MeasuredIngredient[] = []

        for m in recipe.measuredIngredients {
            if let ingredient = m.ingredient {
                if tags[ingredient.tag] {
                    available += m
                } else if tags[ingredient.genericTag] {
                    substitutes += m
                } else {
                    missing += m
                }
            } else {
                available += m
            }
        }

        return RecipeSearchResult(recipe: recipe, availableIngredients: available, substituteIngredients: substitutes, missingIngredients: missing)
    }

    class func generateSearchTextFilterFunction(searchText: String) -> (RecipeSearchResult) -> Bool {
        let searchTextPredicate = NSPredicate(format: "self contains[cd] %@", searchText)
        return { (recipeResult: RecipeSearchResult) -> Bool in
            if searchTextPredicate.evaluateWithObject(recipeResult.recipe.name) {
                return true
            } else {
                for ingredient in recipeResult.recipe.unmeasuredIngredients {
                    if searchTextPredicate.evaluateWithObject(ingredient.displayName) {
                        return true
                    }
                }
            }
            return false
        }
    }

    func _withAnyGenerics(ingredients: Set<Ingredient>) -> Set<Ingredient> {
        var withGenerics = Set<Ingredient>()
        for i in ingredients {
            var current = i
            withGenerics.put(current)
            while current.genericTag {
                current = self._tagToIngredient[current.genericTag!]!
                withGenerics.put(current)
            }
        }
        return withGenerics
    }

    func getFuzzyMixableRecipes(availableIngredients: Set<Ingredient>) -> RecipeSearchResult[] {
        var allAvailableIngredientsWithGenerics = self._withAnyGenerics(availableIngredients)

        var allAvailableTags = Set<String>()
        var mostGenericAvailableTags = Set<String>()
        for i in allAvailableIngredientsWithGenerics {
            allAvailableTags.put(i.tag)
            if !i.genericTag {
                mostGenericAvailableTags.put(i.tag)
            }
        }

        var result: RecipeSearchResult[] = []

        for r in self.allRecipes {
            var mostGenericRecipeTags = Set<String>()

            for i in self._withAnyGenerics(Set(array: r.unmeasuredIngredients)) {
                if !i.genericTag {
                    mostGenericRecipeTags.put(i.tag)
                }
            }
            var i = 1
            var missingCount = (mostGenericRecipeTags - mostGenericAvailableTags).count
            if missingCount <= _RecipeIndex_FUZZY_MATCH_COUNT && missingCount != mostGenericRecipeTags.count {
                result += RecipeIndex.generateRecipeSearchResultFor(r, withAvailableTags: allAvailableTags)
            }
        }

        return sort(result) { $0.recipe.name < $1.recipe.name }
    }

    func saveTransientState() {
        // This crashes the compiler if I un-inline the set-array-map. Wow.
        NSUserDefaults.standardUserDefaults().setObject(SelectedIngredients.instance().set.toArray().map({ $0.tag }), forKey: _RecipeIndex_SELECTED_INGREDIENTS_KEY)
    }

    func loadTransientState() {
        // http://stackoverflow.com/questions/24032863/swift-and-nsuserdefaults-exc-bad-instruction-when-user-defaults-empty
        var savedTags: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(_RecipeIndex_SELECTED_INGREDIENTS_KEY) // Explicitly declare as AnyObject? to avoid implicit unwrapping and crashing on startup.
        if let resolvedSavedTags = savedTags as? String[] {
            var selectedIngredientTags = Set(array: resolvedSavedTags as String[])
            for ingredient in self.allIngredients {
                if selectedIngredientTags[ingredient.tag] {
                    SelectedIngredients.instance().set.put(ingredient)
                }
            }
        }
    }

    func similarityIndex(r1: Recipe, r2: Recipe) -> Float {
        // Some combination of /which/ ingredients exists and a cosine similarity weighted
        // by quantity would be ideal -- how to get good weightings automagically? And how
        // to deal with generics: should we explode an ingredient into all its ancestors,
        // then weight them all the same, then compute the vector?

        var allIngredientsWithGenerics1 = self._withAnyGenerics(Set(array: r1.unmeasuredIngredients))
        var allIngredientsWithGenerics2 = self._withAnyGenerics(Set(array: r2.unmeasuredIngredients))

        // http://en.wikipedia.org/wiki/Jaccard_index
        return Float((allIngredientsWithGenerics1 & allIngredientsWithGenerics2).count) /
               Float((allIngredientsWithGenerics1 | allIngredientsWithGenerics2).count)

        // http://en.wikipedia.org/wiki/S%C3%B8rensen_similarity_index
//        return 2 * Float((allIngredientsWithGenerics1 & allIngredientsWithGenerics2).count) /
//               Float(allIngredientsWithGenerics1.count + allIngredientsWithGenerics2.count)
    }

    func savePermanentState() {
        // Save any custom recipes.
    }

    func loadPermanentState() {
        // Load up any custom recipes.
    }
}
