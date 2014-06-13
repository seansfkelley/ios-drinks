//
//  Recipe.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/12/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

let dropCharactersRegex = NSRegularExpression(pattern: "[^- a-zA-Z0-9]", options: nil, error: nil)
let collapseWhitespaceRegex = NSRegularExpression(pattern: " +", options: nil, error: nil)

class Recipe {
    let name: String
    let normalizedName: String
    let measuredIngredients: MeasuredIngredient[]
    let instructions: String
    let isCustom: Bool

    let notes: String?
    let sourceName: String?
    let sourceUrl: String?

    var rawIngredients: Ingredient[] {
    get {
        return self.measuredIngredients.map { $0.ingredient }
    }

    set { /* readonly */ }
    }

    init(name: String, measuredIngredients: MeasuredIngredient[], instructions: String, isCustom: Bool = false, notes: String?, sourceName: String?, sourceUrl: String?) {
        self.name = name
        self.measuredIngredients = measuredIngredients
        self.instructions = instructions
        self.isCustom = isCustom
        self.notes = notes
        self.sourceName = sourceName
        self.sourceUrl = sourceUrl

        normalizedName = dropCharactersRegex.stringByReplacingMatchesInString(self.name, options: nil, range: NSRange(location: 0, length: countElements(self.name)), withTemplate: "")
        normalizedName = collapseWhitespaceRegex.stringByReplacingMatchesInString(normalizedName, options: nil, range: NSRange(location: 0, length: countElements(normalizedName)), withTemplate: " ")
        self.normalizedName = normalizedName.stringByReplacingOccurrencesOfString(" ", withString: "-")
     }
}
