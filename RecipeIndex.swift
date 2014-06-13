//
//  RecipeIndex.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/6/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

typealias JSONObject = Dictionary<String, AnyObject>

func loadIngredientsFromJson(path: String) -> JSONObject[] {
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
    let allIngredients : Ingredient[]

    init() {
        self.allIngredients = loadIngredientsFromJson(NSBundle.mainBundle().pathForResource("ingredients", ofType: ".json")).map({ Ingredient(fromParsedJson: $0) })
    }
}
