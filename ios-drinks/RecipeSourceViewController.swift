//
//  RecipeSourceViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class RecipeSourceViewController: RecipeDetailPageViewController {
    @IBOutlet var webView: UIWebView

    override func viewDidLoad()  {
        self.webView.scalesPageToFit = true
    }

    override func viewWillAppear(animated: Bool)  {
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.recipeResult.recipe.sourceUrl!)))
    }
}
