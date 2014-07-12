//
//  RecipeDetailViewController2.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

let _RecipeDetailViewController2_PROTOTYPE_CELL_IDENTIFIER = "IngredientPrototypeCell"

class RecipeDetailViewController2: RecipeDetailPageViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView

    override func viewDidLoad() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    var _ingredientSectionCount: Int {
        return
            (self.recipeResult.availableIngredients.count  > 0 ? 1 : 0) +
            (self.recipeResult.substituteIngredients.count > 0 ? 1 : 0) +
            (self.recipeResult.missingIngredients.count    > 0 ? 1 : 0)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self._ingredientSectionCount
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._ingredientGroupForSection(section).count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(_RecipeDetailViewController2_PROTOTYPE_CELL_IDENTIFIER) as UITableViewCell

        let ingredient = self._measuredIgredientForIndexPath(indexPath)

        cell.textLabel.text = ingredient.measurementDisplay
        cell.detailTextLabel.text = ingredient.ingredientDisplay

        return cell
    }

    func _ingredientGroupForSection(section: Int) -> MeasuredIngredient[] {
        return [
            self.recipeResult.availableIngredients,
            self.recipeResult.substituteIngredients,
            self.recipeResult.missingIngredients
        ].filter({ $0.count > 0 })[section]
    }

    func _measuredIgredientForIndexPath(indexPath: NSIndexPath) -> MeasuredIngredient {
        return self._ingredientGroupForSection(indexPath.section)[indexPath.row]
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // I can't one-line this or remove the names because otherwise Swift will shit itself
        // even though it should be identical without using intermediate values.
        var sections: (ingredients: MeasuredIngredient[], title: String)[] = [
            (ingredients: self.recipeResult.availableIngredients,  title: "Available Ingredients"),
            (ingredients: self.recipeResult.substituteIngredients, title: "Substitute Ingredients"),
            (ingredients: self.recipeResult.missingIngredients,    title: "Missing Ingredients")
        ].filter({ $0.ingredients.count > 0 })
        return sections[section].title
    }
}
