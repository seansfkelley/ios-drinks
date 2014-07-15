//
//  PagingRecipeViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/24/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation
import UIKit

extension RecipeDetailPageViewController: Equatable {}

// This is probably not the smartest way to do this.
func == (lhs: RecipeDetailPageViewController, rhs: RecipeDetailPageViewController) -> Bool {
    return lhs === rhs
}

class PagingRecipeViewController: UIPageViewController, UIPageViewControllerDataSource {
    var allRecipeResults: RecipeSearchResult[]!
    var currentResultIndex: Int!

    var recipeResult: RecipeSearchResult {
        return self.allRecipeResults[self.currentResultIndex]
    }

    var _imageController: RecipeImageViewController!
    var _detailsController: RecipeDetailViewController!
    var _similarDrinksController: SimilarDrinksViewController!

    var _currentViewControllers: RecipeDetailPageViewController[] {
        return [ self._imageController, self._detailsController, self._similarDrinksController ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self._imageController =
            self.storyboard.instantiateViewControllerWithIdentifier("RecipeImageViewController") as RecipeImageViewController
        self._detailsController =
            self.storyboard.instantiateViewControllerWithIdentifier("RecipeDetailViewController") as RecipeDetailViewController
        self._similarDrinksController =
            self.storyboard.instantiateViewControllerWithIdentifier("SimilarDrinksViewController") as SimilarDrinksViewController

        self.dataSource = self
    }

    override func viewWillAppear(animated: Bool)  {
        self.navigationItem.title = self.recipeResult.recipe.name

        for controller in self._currentViewControllers {
            controller.recipeResult = self.allRecipeResults[self.currentResultIndex]
        }

        self.setViewControllers([ self._detailsController ], direction: .Forward, animated: true, completion: nil)
    }

    // pragma mark UIPageViewControllerDataSource

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let i = find(self._currentViewControllers, viewController as RecipeDetailPageViewController) {
            if i + 1 < self._currentViewControllers.count {
                return self._currentViewControllers[i + 1]
            }
        }
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let i = find(self._currentViewControllers, viewController as RecipeDetailPageViewController) {
            if i - 1 >= 0 {
                return self._currentViewControllers[i - 1]
            }
        }
        return nil
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self._currentViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
    }
}
