//
//  BrowseAllRecipesViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/12/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class BrowseAllRecipesViewController : UITableViewController {
    let index = RecipeIndex()

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.index.allIngredients.count
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
    }
}