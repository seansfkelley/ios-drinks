//
//  IngredientsViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/2/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

let _IngredientsViewController_PROTOTYPE_CELL_IDENTIFIER = "IngredientPrototypeCell"

class IngredientsViewController: UITableViewController, UIActionSheetDelegate {
    var manager: AlphabeticalTableSectionManager<Ingredient>!

    @IBOutlet var resetButton: UIBarButtonItem

    override func viewDidLoad()  {
        super.viewDidLoad()

        self.manager = AlphabeticalTableSectionManager(items: RecipeIndex.instance().allIngredients.filter({ !$0.isHidden }), titleExtractor: { $0.displayName })
    }

    // pragma mark UITableViewDataSource

    // This is highly duplicated in any other class that uses the Alphabetical manager. How to factor out?
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.manager.orderedSections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager.orderedSections[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(_IngredientsViewController_PROTOTYPE_CELL_IDENTIFIER) as UITableViewCell
        let ingredient = self.manager.objectAtIndexPath(indexPath)

        cell.textLabel.text = ingredient.displayName
        if SelectedIngredients.instance().set[ingredient] {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.manager.orderedSectionTitles[section]
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> AnyObject[] {
        return self.manager.allSectionIndexTitles
    }

    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.manager.sectionForSectionIndexTitle(title)
    }

    // pragma mark Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        // Awkwardly, we need to keep referencing SelectedIngredients.instance().set because it's a struct
        // and we don't want a local copy. Should it be a class instead?
        var selectedIngredient = self.manager!.objectAtIndexPath(indexPath)
        if SelectedIngredients.instance().set[selectedIngredient] {
            SelectedIngredients.instance().set.remove(selectedIngredient)
        } else {
            SelectedIngredients.instance().set.put(selectedIngredient)
        }

        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }

    // pragma mark Reset button

    @IBAction func resetIngredients() {
        // http://stackoverflow.com/questions/24198233/exc-bad-access-when-trying-to-init-uiactionsheet-in-swift
        var actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle("Reset Ingredients")
        actionSheet.destructiveButtonIndex = 0
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = 1
        actionSheet.showFromBarButtonItem(self.resetButton, animated: true)
    }

    func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            SelectedIngredients.instance().set = Set()
            self.tableView.reloadData()
        }
    }
}
