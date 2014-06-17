//
//  RecipeDetailViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/15/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class IngredientSection {
    let title: String
    let ingredients: MeasuredIngredient[]

    init(title: String, ingredients: MeasuredIngredient[]) {
        self.title = title
        self.ingredients = ingredients
    }
}

enum RowType {
    case Ingredient
    case Source
    case Instructions
    case Notes
}

class RecipeDetailViewController : UITableViewController {
    var allRecipeResults: RecipeSearchResult[] = []
    var currentResultIndex: Int = -1

    var _ingredientSections: IngredientSection[] = []

    var _recipeResult: RecipeSearchResult {
        return self.allRecipeResults[self.currentResultIndex]
    }

    var _hasNotes: Bool {
        if let _ = self._recipeResult.recipe.notes {
            return true
        } else {
            return false
        }
    }

    var _hasSource: Bool {
        if let _ = self._recipeResult.recipe.sourceName {
            return true
        } else {
            return false
        }
    }

    var _proseSectionCount: Int {
        return 1 + (self._hasNotes ? 1 : 0) + (self._hasSource ? 1 : 0)
    }

    override func viewDidLoad()  {
        super.viewDidLoad()

        self._regenerateContents()
    }

    func _regenerateContents() {
        self._generateTableSections()

        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPointMake(0.0, -self.tableView.contentInset.top), animated: true)
    }

    func _generateTableSections() {
        let orderedTitles = [ "Missing Ingredients", "Ingredients (Substitutions)", "Ingredients" ]
        let orderedIngredientLists = [ self._recipeResult.missingIngredients, self._recipeResult.substituteIngredients, self._recipeResult.availableIngredients ]

        self._ingredientSections = []
        for i in 0..3 {
            if orderedIngredientLists[i].count > 0 {
                self._ingredientSections += IngredientSection(title: orderedTitles[i], ingredients: orderedIngredientLists[i])
            }
        }
    }

    // This is the worst thing.
    func _rowTypeForIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> RowType {
        var sectionDiff = indexPath.section - (self.numberOfSectionsInTableView(tableView) - self._proseSectionCount)
        switch sectionDiff {
        case 0:
            return .Instructions
        case 1:
            if self._hasNotes {
                return .Notes
            }
            fallthrough
        case 2:
            if self._hasSource {
                return .Source
            }
            fallthrough
        default:
            return .Ingredient
        }
    }

    // pragma mark - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return self._ingredientSections.count + self._proseSectionCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        if section < self._ingredientSections.count {
            return self._ingredientSections[section].ingredients.count
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?  {
        if section < self._ingredientSections.count {
            return self._ingredientSections[section].title
        } else {
            return nil
        }
    }

    func _ingredientAtIndexPath(indexPath: NSIndexPath) -> MeasuredIngredient {
        return self._ingredientSections[indexPath.section].ingredients[indexPath.row]
    }

    func _measuredIngredientCellForIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MeasuredIngredientPrototypeCell", forIndexPath:indexPath) as UITableViewCell
        var ingredient = self._ingredientAtIndexPath(indexPath)

        cell.textLabel.text = ingredient.measurementDisplay
        cell.detailTextLabel.text = ingredient.ingredientDisplay

        return cell
    }

    func _proseTextCellForIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ProseTextPrototypeCell", forIndexPath:indexPath) as UITableViewCell

        // Configure shared values.
        cell.textLabel.text = "" // Trick the layout into ignoring this label entirely.
        cell.detailTextLabel.numberOfLines = 0
        cell.detailTextLabel.lineBreakMode = .ByWordWrapping

        // Reset some stuff.
        cell.accessoryType = .None
        cell.selectionStyle = .None
        cell.userInteractionEnabled = false

        // Configure according to what cell it actually is.
        switch self._rowTypeForIndexPath(tableView, indexPath: indexPath) {
        case .Ingredient:
            assert(false, "Ingredient case should be handled elsewhere.")
        case .Source:
            cell.detailTextLabel.text = self._recipeResult.recipe.sourceName;
            if self._recipeResult.recipe.sourceUrl {
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                cell.userInteractionEnabled = true
            }
        case .Instructions:
            cell.detailTextLabel.text = self._recipeResult.recipe.instructions
        case .Notes:
            cell.detailTextLabel.text = self._recipeResult.recipe.notes
        }

        return cell
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section < self._ingredientSections.count {
            return self._measuredIngredientCellForIndexPath(tableView, indexPath: indexPath)
        } else {
            return self._proseTextCellForIndexPath(tableView, indexPath: indexPath)
        }
    }
}
