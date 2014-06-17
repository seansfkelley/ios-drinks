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
        return self.measuredIngredients.filter({
            if let _ = $0.ingredient {
                return true
            } else {
                return false
            }
        }).map { $0.ingredient! }
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

    convenience init(fromParsedJson json: NSDictionary, withIngredients tagToIngredient: Dictionary<String, Ingredient>) {
        let name = json["name"] as String
        let instructions = json["instructions"] as String
        let notes = json["notes"] as? String
        let sourceName = json["source"] as? String
        let sourceUrl = json["url"] as? String

        var ingredients: MeasuredIngredient[] = []
        for i: NSDictionary in json["ingredients"] as Array<NSDictionary> {
            var ingredient: Ingredient?
            if let tag = i["tag"] as? String {
                if let ingredientFromDictionary = tagToIngredient[tag] {
                    ingredient = ingredientFromDictionary
                } else {
                    println("Ignoring recipe '\(name)' because it refers to unknown ingredient tag '\(tag)'")
                }
            }
            var measurement = ""
            if let actualMeasurement = i["displayMeasure"] as? String {
                measurement = actualMeasurement
            }
            ingredients += MeasuredIngredient(ingredient: ingredient, measurementDisplay: measurement, ingredientDisplay: i["displayIngredient"] as String)
        }

        self.init(name: name, measuredIngredients: ingredients, instructions: instructions, isCustom: false, notes: notes, sourceName: sourceName, sourceUrl: sourceUrl)
    }
}