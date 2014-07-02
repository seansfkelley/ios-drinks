//
//  SegmentedRecipeViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/30/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

enum RecipeDisplayMode: String {
    case MIXABLE = "Mixable"
    case ALL = "All"
}

let DISPLAY_MODE_ORDERING: RecipeDisplayMode[] = [ .ALL, .MIXABLE ]

// TODO: Class variable, when Swift supports it.
var _PROTOTYPE_CELL_IDENTIFIER = "RecipePrototypeCell"

class SegmentedRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var manager: AlphabeticalTableSectionManager<RecipeSearchResult>?

    @IBOutlet var segmentedControl: UISegmentedControl
    @IBOutlet var tableView : UITableView

    var _displayMode = RecipeDisplayMode.ALL // Tagged class. Fuck iOS and how fucking hard it is to just have a view controller that swaps out other fucking view controllers.

    override func viewDidLoad()  {
        super.viewDidLoad()

        self.segmentedControl.removeAllSegments()
        for mode in DISPLAY_MODE_ORDERING {
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
        let cell = tableView.dequeueReusableCellWithIdentifier(_PROTOTYPE_CELL_IDENTIFIER) as UITableViewCell
        let recipe = self.manager!.objectAtIndexPath(indexPath).recipe

        cell.textLabel.text = recipe.name
        cell.detailTextLabel.text = "\(recipe.measuredIngredients.count) ingredients"

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
        self._displayMode = DISPLAY_MODE_ORDERING[self.segmentedControl.selectedSegmentIndex]

        var recipes: RecipeSearchResult[]
        switch (self._displayMode) {
        case .ALL:
            recipes = RecipeIndex.instance().allRecipes.map { RecipeIndex.generateDummySearchResultFor($0) }
        case .MIXABLE:
            recipes = RecipeIndex.instance().getFuzzyMixableRecipes(SelectedIngredients.instance().set)
        }
        
        self.manager = AlphabeticalTableSectionManager<RecipeSearchResult>(items: recipes, titleExtractor: { $0.recipe.name })

        self.tableView.reloadData()
    }

}