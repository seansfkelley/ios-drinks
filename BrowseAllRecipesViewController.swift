//
//  BrowseAllRecipesViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/12/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class BrowseAllRecipesViewController : UITableViewController {
    var index: RecipeIndex?
    var manager: AlphabeticalTableSectionManager<Recipe>?

    override func viewDidLoad()  {
        self.index = RecipeIndex()
        self.manager = AlphabeticalTableSectionManager<Recipe>(items: self.index!.allRecipes, titleExtractor: { $0.name })
    }

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.manager!.orderedSections.count
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.manager!.orderedSections[section].count
    }
}