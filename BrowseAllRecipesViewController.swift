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
    var manager: AlphabeticalTableSectionManager<RecipeSearchResult>?

    override func viewDidLoad()  {
        self.index = RecipeIndex()
        self.manager = AlphabeticalTableSectionManager<RecipeSearchResult>(items: self.index!.allRecipes.map { self.index!.generateDummySearchResultFor($0) }, titleExtractor: { $0.recipe.name })
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
        let recipe = self.manager!.objectAtIndexPath(indexPath).recipe

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

    // pragma mark - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        // http://stackoverflow.com/questions/15414146/uitableview-prepareforsegue-assigning-indexpath-to-sender

        // TODO: Factor this grossness out as a function that takes a block or a map of classes to blocks.
        var controller: UIViewController
        if segue.destinationViewController.isKindOfClass(UINavigationController.self) {
            controller = (segue.destinationViewController as UINavigationController).viewControllers[0] as UIViewController
        } else {
            controller = segue.destinationViewController as UIViewController
        }

        if controller.isKindOfClass(RecipeDetailViewController.self) {
            let detailController = controller as RecipeDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()

            detailController.allRecipeResults = self.manager!.sortedItems
            detailController.currentResultIndex = self.manager!.sortedIndexForIndexPath(indexPath)
        } else if controller.isKindOfClass(PagingRecipeViewController.self) {
            let pagingController = controller as PagingRecipeViewController
            let indexPath = self.tableView.indexPathForSelectedRow()

            pagingController.allRecipeResults = self.manager!.sortedItems
            pagingController.currentResultIndex = self.manager!.sortedIndexForIndexPath(indexPath)

        } else {
            assert(false, "Unknown segue. All segues must be handled.")
        }
    }
}