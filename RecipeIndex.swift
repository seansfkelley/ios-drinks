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

let _RecipeIndex_INSTANCE = RecipeIndex()

let _RecipeIndex_INGREDIENTS = loadJSONArrayFromPath(NSBundle.mainBundle().pathForResource("ingredients", ofType: ".json")).map({ Ingredient(fromParsedJson: $0) })

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

    func getFuzzyMixableRecipes(availableIngredients: Set<Ingredient>) -> RecipeSearchResult[] {
        var mostGenericTags = availableIngredients.map { $0.mostGenericTag }
        var allTags = availableIngredients.map { $0.tag }
        allTags.put(mostGenericTags)

        var result: RecipeSearchResult[] = []

        for r in self.allRecipes {
            var recipeMostGenericTags = Set(array: r.mostGenericIngredientTags)
            var missingCount = (recipeMostGenericTags - mostGenericTags).count
            if missingCount <= _RecipeIndex_FUZZY_MATCH_COUNT && missingCount != recipeMostGenericTags.count {
                result += RecipeIndex.generateRecipeSearchResultFor(r, withAvailableTags: allTags)
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

    func savePermanentState() {
        // Save any custom recipes.
    }

    func loadPermanentState() {
        // Load up any custom recipes.
    }
}
