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

    // Do we even need these functions anymore?
    /*
    func groupByMissingIngredients(availableIngredients: Set<Ingredient>) -> Dictionary<Int, RecipeSearchResult[]> {
        return self._groupByMissingIngredients(availableIngredients)
    }

    func _groupByMissingIngredients(availableIngredients: Set<Ingredient>) -> Dictionary<Int, RecipeSearchResult[]> {
        var genericTags = availableIngredients.map { $0.genericTag }
        var allTags = availableIngredients.map { $0.tag }
        allTags.put(genericTags)

        var grouped = Dictionary<Int, RecipeSearchResult[]>()
        for i in 0..._RecipeIndex_FUZZY_MATCH_COUNT { // Inclusive.
            grouped[i] = []
        }

        for r in self.allRecipes {
            var recipeGenericTags = Set(array: r.genericIngredientTags)
            var missingCount = (recipeGenericTags - genericTags).count
            if missingCount <= _RecipeIndex_FUZZY_MATCH_COUNT && missingCount != recipeGenericTags.count {
                var group = grouped[missingCount]! // Can't one-line this for some reason.
                group.append(RecipeIndex.generateRecipeSearchResultFor(r, withAvailableTags: allTags))
            }
        }

        for i in 0..._RecipeIndex_FUZZY_MATCH_COUNT {
            grouped[i] = sort(grouped[i]!, { $0.recipe.name < $1.recipe.name })
        }

        return grouped
    }
    */
}
