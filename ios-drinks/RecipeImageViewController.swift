//
//  RecipeImageViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class RecipeImageViewController: UIViewController {
    @IBOutlet var imageView: UIImageView

    var recipeResult: RecipeSearchResult!

    override func viewWillAppear(animated: Bool)  {
        self.imageView.image = UIImage(named: "DefaultRecipeImage")
    }
}
