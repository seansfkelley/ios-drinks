//
//  SegmentedRecipeViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/30/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

enum RecipeDisplayMode: String {
    case ALL = "All"
    case MIXABLE = "Mixable"
}



protocol DisplayModeConfiguration {
    var recipes: RecipeSearchResult[] { get }

    func styleTableCell(cell: UITableViewCell, recipeResult: RecipeSearchResult)
}

struct MixableConfiguration: DisplayModeConfiguration {
    var recipes: RecipeSearchResult[] {
        return RecipeIndex.instance().getFuzzyMixableRecipes(SelectedIngredients.instance().set)
    }

    func styleTableCell(cell: UITableViewCell, recipeResult: RecipeSearchResult) {
        let recipe = recipeResult.recipe

        cell.textLabel.text = recipe.name
        if recipeResult.missingIngredients.count == 0 {
            cell.detailTextLabel.text = "\(recipe.measuredIngredients.count) ingredients"
        } else {
            cell.detailTextLabel.text = "\(recipe.measuredIngredients.count) ingredients (\(recipeResult.missingIngredients) missing)"
        }
    }
}

struct AllConfiguration: DisplayModeConfiguration {
    var recipes: RecipeSearchResult[] = RecipeIndex.instance().allRecipes.map { RecipeIndex.generateDummySearchResultFor($0) }

    func styleTableCell(cell: UITableViewCell, recipeResult: RecipeSearchResult) {
        let recipe = recipeResult.recipe

        cell.textLabel.text = recipe.name
        cell.detailTextLabel.text = "\(recipe.measuredIngredients.count) ingredients"
    }
}



// These really should be class statics, once Swift supports that.
let _DISPLAY_MODE_ORDERING: RecipeDisplayMode[] = [ .ALL, .MIXABLE ]
let _DISPLAY_MODE_TO_CONFIGURATION: Dictionary<RecipeDisplayMode, DisplayModeConfiguration> = [
    .ALL: AllConfiguration(),
    .MIXABLE: MixableConfiguration()
]
let _SegmentedRecipeViewController_PROTOTYPE_CELL_IDENTIFIER = "RecipePrototypeCell"

class SegmentedRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var manager: AlphabeticalTableSectionManager<RecipeSearchResult>?

    @IBOutlet var segmentedControl: UISegmentedControl
    @IBOutlet var tableView: UITableView

    var _displayMode = RecipeDisplayMode.ALL // Tagged class. Fuck iOS and how fucking hard it is to just have a view controller that swaps out other fucking view controllers.

    override func viewDidLoad()  {
        super.viewDidLoad()

        self.segmentedControl.removeAllSegments()
        for mode in _DISPLAY_MODE_ORDERING {
            self.segmentedControl.insertSegmentWithTitle(mode.toRaw(), atIndex: self.segmentedControl.numberOfSegments, animated: false)
        }

        self.segmentedControl.selectedSegmentIndex = 0
        self.indexChanged()
    }

    // pragma mark UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.manager!.orderedSections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager!.orderedSections[section].count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(_SegmentedRecipeViewController_PROTOTYPE_CELL_IDENTIFIER) as UITableViewCell

        _DISPLAY_MODE_TO_CONFIGURATION[self._displayMode]!.styleTableCell(cell, recipeResult: self.manager!.objectAtIndexPath(indexPath))

        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.manager!.orderedSectionTitles[section]
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> AnyObject[] {
        return self.manager!.allSectionIndexTitles
    }

    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.manager!.sectionForSectionIndexTitle(title)
    }

    // pragma mark UISegmentControl actions

    @IBAction func indexChanged() {
        self._displayMode = _DISPLAY_MODE_ORDERING[self.segmentedControl.selectedSegmentIndex]

        var recipes = _DISPLAY_MODE_TO_CONFIGURATION[self._displayMode]!.recipes
        self.manager = AlphabeticalTableSectionManager<RecipeSearchResult>(items: recipes, titleExtractor: { $0.recipe.name })

        self.tableView.reloadData()
    }

    // pragma mark Navigation

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