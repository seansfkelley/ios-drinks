//
//  MeasuredIngredient.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/12/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

class MeasuredIngredient: Printable {
    let ingredient: Ingredient?
    let measurementDisplay: String
    let ingredientDisplay: String

    init(ingredient: Ingredient?, measurementDisplay: String, ingredientDisplay: String) {
        self.ingredient = ingredient
        self.measurementDisplay = measurementDisplay
        self.ingredientDisplay = ingredientDisplay
    }

    var description: String {
        return "MeasuredIngredient[\(self.measurementDisplay) \(self.ingredientDisplay)]"
    }
}