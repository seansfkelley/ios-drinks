//
//  RecipeImageViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class RecipeImageViewController: RecipeDetailPageViewController {
    @IBOutlet var sourceButton: UIButton
    @IBOutlet var imageView: UIImageView

    override func viewWillAppear(animated: Bool)  {
        self.imageView.image = UIImage(named: "DefaultRecipeImage")

        if let name = self.recipeResult.recipe.sourceName {
            self.sourceButton.hidden = false
            self.sourceButton.setTitle("from \(name)", forState: UIControlState.Normal)
        } else {
            self.sourceButton.hidden = true
        }
    }

    @IBAction func goToSource() {
        UIApplication.sharedApplication().openURL(NSURL(string: self.recipeResult.recipe.sourceUrl!))
    }
}
