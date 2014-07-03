//
//  Ingredient.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/6/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation

class Ingredient: Hashable, Equatable {
    let displayName: String = ""
    let tag: String = ""
    let genericTag: String? = nil
    let isHidden: Bool = false

    var isGeneric: Bool = false

    var hashValue: Int {
        return self.tag.hashValue // Ingredients must have unique tags, so we can use it as the hash.
    }

    var mostGenericTag: String {
        if let resolvedGenericTag = self.genericTag {
            return resolvedGenericTag
        } else {
            return self.tag
        }
    }

    init(displayName: String, tag: String, genericTag: String? = nil, isHidden: Bool = false) {
        self.displayName = displayName
        self.tag = tag
        self.genericTag = genericTag
        self.isHidden = isHidden
    }

    init(fromParsedJson json: NSDictionary) {
        self.displayName = json["display"] as String

        if let tag: AnyObject = json["tag"] {
            self.tag = tag as String
        } else {
            self.tag = self.displayName.lowercaseString
        }

        self.genericTag = json["genericTag"] as? String

        if let isHidden = json["hidden"] as? Bool {
            self.isHidden = isHidden
        }
    }
}

func ==(a: Ingredient, b: Ingredient) -> Bool {
    return a.tag == b.tag
}
