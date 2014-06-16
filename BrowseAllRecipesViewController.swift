//
//  BrowseAllRecipesViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/12/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

let PROTOTYPE_CELL_IDENTIFIER = "RecipePrototypeCell"

class BrowseAllRecipesViewController : UITableViewController {
    var index: RecipeIndex?
    var manager: AlphabeticalTableSectionManager<Recipe>?

    override func viewDidLoad()  {
        self.index = RecipeIndex()
        self.manager = AlphabeticalTableSectionManager<Recipe>(items: self.index!.allRecipes, titleExtractor: { $0.name })
    }

    // pragma mark UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.manager!.orderedSections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager!.orderedSections[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PROTOTYPE_CELL_IDENTIFIER) as UITableViewCell
        let recipe = self.manager!.objectAtIndexPath(indexPath)

        cell.textLabel.text = recipe.name
        cell.detailTextLabel.text = "\(recipe.measuredIngredients.count) ingredients"

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.manager!.orderedSectionTitles[section]
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> AnyObject[] {
        return self.manager!.allSectionIndexTitles
    }

    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.manager!.sectionForSectionIndexTitle(title)
    }
}