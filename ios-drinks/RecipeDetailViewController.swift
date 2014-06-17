//
//  RecipeDetailViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/15/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class RecipeDetailViewController : UITableViewController {
    var allRecipeResults: RecipeSearchResult[] = []
    var currentResultIndex: Int = -1

    override func viewDidUnload()  {
        super.viewDidLoad()

        self._regenerateContents()
    }

    func _regenerateContents() {
        self._generateTableSections()

        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPointMake(0.0, -self.tableView.contentInset.top), animated: true)
    }

    func _generateTableSections() {

    }
}
