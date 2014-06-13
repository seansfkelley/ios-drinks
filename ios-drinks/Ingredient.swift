//
//  Ingredient.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/6/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

class Ingredient {
    let displayName: String = ""
    let tag: String = ""
    let genericTag: String? = nil
    let isHidden: Bool = false

    var isGeneric: Bool = false

    init(displayName: String, tag: String, genericTag: String? = nil, isHidden: Bool = false) {
        self.displayName = displayName
        self.tag = tag
        self.genericTag = genericTag
        self.isHidden = isHidden
    }

    init(fromParsedJson: Dictionary<String, AnyObject>) {
        if let displayName: AnyObject = fromParsedJson["display"] {
            self.displayName = displayName as String
        } else {
            raiseInputException("All ingredients must have a display field.")
        }

        if let tag: AnyObject = fromParsedJson["tag"] {
            self.tag = tag as String
        } else {
            self.tag = self.displayName.lowercaseString
        }

        if let genericTag: AnyObject = fromParsedJson["genericTag"] {
            self.genericTag = genericTag as? String
        }

        if let isHidden: AnyObject = fromParsedJson["hidden"] {
            self.isHidden = isHidden as Bool
        }
    }
}

func raiseInputException(description: String) {
    NSException.raise("IllegalInputFormat", format: description, arguments: CVaListPointer(fromUnsafePointer: UnsafePointer()))
}