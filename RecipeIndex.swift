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

class RecipeIndex {
    let allIngredients: Ingredient[]
    let allRecipes: Recipe[]

    let _tagToIngredient: Dictionary<String, Ingredient>

    init() {
        self.allIngredients = loadJSONArrayFromPath(NSBundle.mainBundle().pathForResource("ingredients", ofType: ".json")).map({ Ingredient(fromParsedJson: $0) })

        self._tagToIngredient = Dictionary<String, Ingredient>()
        for i in self.allIngredients {
            self._tagToIngredient[i.tag] = i
        }

        self.allRecipes = [] // Why is this necessary?!
        self.allRecipes = loadJSONArrayFromPath(NSBundle.mainBundle().pathForResource("recipes", ofType: ".json")).map({ Recipe(fromParsedJson: $0, withIngredients: self._tagToIngredient) })
    }

    func generateDummySearchResultFor(recipe: Recipe) -> RecipeSearchResult {
        return self._generateRecipeSearchResultFor(recipe, withAvailableTags: Set(array: self.allIngredients.map { $0.tag }))
    }

    func _generateRecipeSearchResultFor(recipe: Recipe, withAvailableTags tags: Set<String>) -> RecipeSearchResult {
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
}
