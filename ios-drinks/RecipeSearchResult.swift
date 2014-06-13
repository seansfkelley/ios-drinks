//
//  RecipeSearchResult.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/12/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

class RecipeSearchResult {
    let recipe: Recipe
    let availableIngredients: Ingredient[]
    let substituteIngredients: Ingredient[]
    let missingIngredients: Ingredient[]

    init(recipe: Recipe, availableIngredients: Ingredient[], substituteIngredients: Ingredient[], missingIngredients: Ingredient[]) {
        self.recipe = recipe
        self.availableIngredients = availableIngredients
        self.substituteIngredients = substituteIngredients
        self.missingIngredients = missingIngredients
    }
}