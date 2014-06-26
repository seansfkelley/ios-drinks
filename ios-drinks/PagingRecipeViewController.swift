//
//  PagingRecipeViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/24/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: Equatable {}

// This is probably not the smartest way to do this. Will this leak out and cause weird issues elsewhere
// since I'm extending a builtin class?
func == (lhs: UIViewController, rhs: UIViewController) -> Bool {
    return lhs === rhs
}

class PagingRecipeViewController: UIPageViewController, UIPageViewControllerDataSource {
    var allRecipeResults: RecipeSearchResult[] = []
    var currentResultIndex: Int = -1

    var _allViewControllers: UIViewController[] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        var detailsController = self.storyboard.instantiateViewControllerWithIdentifier("recipeDetailViewController") as RecipeDetailViewController
        var blankViewController = self.storyboard.instantiateViewControllerWithIdentifier("blankViewController") as UIViewController
        detailsController.allRecipeResults = self.allRecipeResults
        detailsController.currentResultIndex = self.currentResultIndex

        self.dataSource = self

        self._allViewControllers = [ detailsController, blankViewController ]

        self.setViewControllers([ detailsController ], direction: .Forward, animated: true, completion: nil)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let i = find(self._allViewControllers, viewController) {
            if i + 1 < self._allViewControllers.count {
                return self._allViewControllers[i + 1]
            }
        }
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let i = find(self._allViewControllers, viewController) {
            if i - 1 >= 0 {
                return self._allViewControllers[i - 1]
            }
        }
        return nil
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self._allViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
