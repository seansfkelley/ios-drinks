//
//  SelectedIngredients.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/26/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

let _SelectedIngredients_INSTANCE = SelectedIngredients()

// lololol dedicated wrapper class to expose global singleton. <3 iOS development.
class SelectedIngredients {
    var set: Set<Ingredient> = Set()

    class func instance() -> SelectedIngredients {
        return _SelectedIngredients_INSTANCE
    }
}