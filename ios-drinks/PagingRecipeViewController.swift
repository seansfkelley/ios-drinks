//
//  PagingRecipeViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/24/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation
import UIKit

class PagingRecipeViewController: UIPageViewController, UIPageViewControllerDataSource {
    var allRecipeResults: RecipeSearchResult[] = []
    var currentResultIndex: Int = -1

    override func viewDidLoad() {
        var detailsController = self.storyboard.instantiateViewControllerWithIdentifier("recipeDetailViewController") as RecipeDetailViewController
        var blankViewController = self.storyboard.instantiateViewControllerWithIdentifier("blankViewController") as UIViewController
        detailsController.allRecipeResults = self.allRecipeResults
        detailsController.currentResultIndex = self.currentResultIndex

        self.dataSource = self

        self.setViewControllers([ detailsController ], direction: .Forward, animated: true, completion: nil)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        println(viewController)
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        println(viewController)
        return nil
    }

    func presentationCountForViewController(pageViewController: UIPageViewController) -> Int {
        return 3
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
    }
}
