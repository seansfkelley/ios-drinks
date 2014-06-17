//
//  RecipeSearchResult.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/12/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

class RecipeSearchResult {
    let recipe: Recipe
    let availableIngredients: MeasuredIngredient[]
    let substituteIngredients: MeasuredIngredient[]
    let missingIngredients: MeasuredIngredient[]

    init(recipe: Recipe, availableIngredients: MeasuredIngredient[], substituteIngredients: MeasuredIngredient[], missingIngredients: MeasuredIngredient[]) {
        self.recipe = recipe
        self.availableIngredients = availableIngredients
        self.substituteIngredients = substituteIngredients
        self.missingIngredients = missingIngredients
    }
}