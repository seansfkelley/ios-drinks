//
//  RecipeDetailPage.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

// Can't be a protocol, because we want to be able to check for conformance (requiring @objc)
// but we also want it to be an optional property (disallowing @objc). So fuck it. It's a class.
class RecipeDetailPageViewController: UIViewController {
    var recipeResult: RecipeSearchResult! = nil
}
