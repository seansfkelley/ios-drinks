//
//  RecipeImageViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class RecipeImageViewController: RecipeDetailPageViewController {
    @IBOutlet var imageView: UIImageView

    override func viewWillAppear(animated: Bool)  {
        self.imageView.image = UIImage(named: "DefaultRecipeImage")
    }
}
