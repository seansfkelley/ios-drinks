//
//  BrowseAllRecipesViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/25/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class MixableRecipesViewController : AbstractRecipesViewController {
    override var recipes: RecipeSearchResult[] {
        let index = RecipeIndex.instance()
        return index.allRecipes.map { RecipeIndex.generateDummySearchResultFor($0) }
    }

    // pragma mark UITableViewDataSource

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let recipeResult = self.manager!.objectAtIndexPath(indexPath)
        let recipe = recipeResult.recipe

        if recipeResult.missingIngredients.count > 0 {
            cell.detailTextLabel.text = "\(recipe.measuredIngredients.count) ingredients (\(recipeResult.missingIngredients.count) missing)"
        } else {
            cell.detailTextLabel.text = "\(recipe.measuredIngredients.count) ingredients"
        }

        return cell
    }

    // pragma mark - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        // http://stackoverflow.com/questions/15414146/uitableview-prepareforsegue-assigning-indexpath-to-sender

        var controller = UIUtils.actualTargetViewControllerForSegue(segue)

        if controller.isKindOfClass(PagingRecipeViewController.self) {
            let pagingController = controller as PagingRecipeViewController
            let indexPath = self.tableView.indexPathForSelectedRow()

            pagingController.allRecipeResults = self.manager!.sortedItems
            pagingController.currentResultIndex = self.manager!.sortedIndexForIndexPath(indexPath)

        } else {
            assert(false, "Unknown segue. All segues must be handled.")
        }
    }
}