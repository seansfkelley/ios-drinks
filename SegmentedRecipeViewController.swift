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

    func styleTableCell(cell: RecipeTableViewCell, recipeResult: RecipeSearchResult)
}

struct MixableConfiguration: DisplayModeConfiguration {
    var recipes: RecipeSearchResult[] {
        return RecipeIndex.instance().getFuzzyMixableRecipes(SelectedIngredients.instance().set)
    }

    func styleTableCell(cell: RecipeTableViewCell, recipeResult: RecipeSearchResult) {
        let recipe = recipeResult.recipe

        cell.titleLabel.text = recipe.name
        cell.subtitleLabel.text = "\(recipe.measuredIngredients.count) ingredients"
        if recipeResult.missingIngredients.count == 0 {
            cell.subtitleAsideLabel.hidden = true
        } else {
            cell.subtitleAsideLabel.hidden = false
            cell.subtitleAsideLabel.text = "(\(recipeResult.missingIngredients.count) missing)"
        }
        cell.recipeImageView.image = UIImage(named: "DefaultRecipeImage")
    }
}

struct AllConfiguration: DisplayModeConfiguration {
    var recipes: RecipeSearchResult[] = RecipeIndex.instance().allRecipes.map { RecipeIndex.generateDummySearchResultFor($0) }

    func styleTableCell(cell: RecipeTableViewCell, recipeResult: RecipeSearchResult) {
        let recipe = recipeResult.recipe

        cell.titleLabel.text = recipe.name
        cell.subtitleLabel.text = "\(recipe.measuredIngredients.count) ingredients"
        cell.subtitleAsideLabel.hidden = true
        cell.recipeImageView.image = UIImage(named: "DefaultRecipeImage")
    }
}



// These really should be class statics, once Swift supports that.
let _DISPLAY_MODE_ORDERING: RecipeDisplayMode[] = [ .ALL, .MIXABLE ]
let _DISPLAY_MODE_TO_CONFIGURATION: Dictionary<RecipeDisplayMode, DisplayModeConfiguration> = [
    .ALL: AllConfiguration(),
    .MIXABLE: MixableConfiguration()
]
let _SegmentedRecipeViewController_PROTOTYPE_CELL_IDENTIFIER = "RecipePrototypeCell"

class SegmentedRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIToolbarDelegate, UISearchBarDelegate {
    var manager: AlphabeticalTableSectionManager<RecipeSearchResult>!

    @IBOutlet var segmentedControl: UISegmentedControl
    @IBOutlet var searchBar: UISearchBar
    @IBOutlet var tableView: UITableView

    var _displayMode = RecipeDisplayMode.ALL // Tagged class. Fuck iOS and how fucking hard it is to just have a view controller that swaps out other fucking view controllers.

    override func viewDidLoad()  {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "RecipeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: _SegmentedRecipeViewController_PROTOTYPE_CELL_IDENTIFIER)

        // This is pretty fragile, but whatever.
        self.tableView.contentInset = UIEdgeInsets(top: self.searchBar.frame.height, left: 0, bottom: 0, right: 0)

        self.segmentedControl.removeAllSegments()
        for mode in _DISPLAY_MODE_ORDERING {
            self.segmentedControl.insertSegmentWithTitle(mode.toRaw(), atIndex: self.segmentedControl.numberOfSegments, animated: false)
        }

        self.segmentedControl.selectedSegmentIndex = 0
        self.indexChanged()
    }

    override func viewWillAppear(animated: Bool) {
        // http://stackoverflow.com/questions/19379510/uitableviewcell-doesnt-get-deselected-when-swiping-back-quickly
        // In addition to fixing the above, also serves to deselect it under normal circumstances.
        self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow(), animated: animated)
    }

    // pragma mark UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.manager.orderedSections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager.orderedSections[section].count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(_SegmentedRecipeViewController_PROTOTYPE_CELL_IDENTIFIER) as RecipeTableViewCell
        cell.controller = self
        cell.tableView = tableView

        _DISPLAY_MODE_TO_CONFIGURATION[self._displayMode]!.styleTableCell(cell, recipeResult: self.manager!.objectAtIndexPath(indexPath))

        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.manager.orderedSectionTitles[section]
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> AnyObject[] {
        return self.manager.allSectionIndexTitles
    }

    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.manager.sectionForSectionIndexTitle(title)
    }

    // pragma mark UIToolbarDelegate

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }

    // pragma mark UISegmentedControl actions

    @IBAction func indexChanged() {
        self._displayMode = _DISPLAY_MODE_ORDERING[self.segmentedControl.selectedSegmentIndex]
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self._reloadDataRespectingSearchText()
    }

    // pragma mark UISearchBarDelegate

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self._reloadDataRespectingSearchText()
    }

    // pragma mark Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        var controller = UIUtils.actualTargetViewControllerForSegue(segue)

        if controller.isKindOfClass(PagingRecipeViewController.self) {
            let pagingController = controller as PagingRecipeViewController
            let indexPath = self.tableView.indexPathForSelectedRow()

            pagingController.allRecipeResults = self.manager.sortedItems
            pagingController.currentResultIndex = self.manager.sortedIndexForIndexPath(indexPath)
//        } else if controller.isKindOfClass(RecipeDetailViewController.self) {
//            let recipeController = controller as RecipeDetailViewController
//            let indexPath = self.tableView.indexPathForSelectedRow()
//
//            recipeController.allRecipeResults = self.manager.sortedItems
//            recipeController.currentResultIndex = self.manager.sortedIndexForIndexPath(indexPath)
        } else {
            assert(false, "Unknown segue. All segues must be handled.")
        }
    }

    // pragma mark Miscellaneous

    func _reloadDataRespectingSearchText() {
        var recipes = _DISPLAY_MODE_TO_CONFIGURATION[self._displayMode]!.recipes

        if !self.searchBar.text.isEmpty {
            recipes = recipes.filter(RecipeIndex.generateSearchTextFilterFunction(self.searchBar.text))
        }

        self.manager = AlphabeticalTableSectionManager(items: recipes, titleExtractor: { $0.recipe.name })
        self.tableView.reloadData()
    }
}