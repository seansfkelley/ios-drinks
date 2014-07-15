//
//  RecipeDetailViewController2.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

let _RecipeDetailViewController_INGREDIENTS_PROTOTYPE_CELL_IDENTIFIER = "ingredientPrototypeCell"
let _RecipeDetailViewController_INSTRUCTIONS_PROTOTYPE_CELL_IDENTIFIER = "instructionsPrototypeCell"

enum RecipeDetailCellType {
    case Ingredient
    case Instructions
}

class RecipeDetailViewController: RecipeDetailPageViewController, UITableViewDataSource, UITableViewDelegate {
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

    func _cellTypeForSection(section: Int) -> RecipeDetailCellType {
        if section < self._ingredientSectionCount {
            return .Ingredient
        } else {
            return .Instructions
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self._ingredientSectionCount + 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (self._cellTypeForSection(section)) {
        case .Ingredient:
            return self._ingredientGroupForSection(section).count
        case .Instructions:
            return 1
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> Double {
        switch (self._cellTypeForSection(indexPath.section)) {
        case .Ingredient:
            return 45.0
        case .Instructions:
            let instructions = self.recipeResult.recipe.instructions
            let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as InstructionsTableViewCell

            let size = NSString(string: instructions).boundingRectWithSize(
                CGSize(width: 300.0, height: CGFLOAT_MAX),
                options: .UsesLineFragmentOrigin,
                attributes: [ NSFontAttributeName: cell.proseTextLabel.font ],
                context: nil)

            return Double(size.height + 45.0)
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (self._cellTypeForSection(indexPath.section)) {
        case .Ingredient:
            let cell = tableView.dequeueReusableCellWithIdentifier(_RecipeDetailViewController_INGREDIENTS_PROTOTYPE_CELL_IDENTIFIER) as UITableViewCell

            let ingredient = self._measuredIgredientForIndexPath(indexPath)

            cell.textLabel.text = ingredient.measurementDisplay
            cell.detailTextLabel.text = ingredient.ingredientDisplay
            
            return cell
        case .Instructions:
            let cell = tableView.dequeueReusableCellWithIdentifier(_RecipeDetailViewController_INSTRUCTIONS_PROTOTYPE_CELL_IDENTIFIER) as InstructionsTableViewCell

            let instructions = self.recipeResult.recipe.instructions

            cell.proseTextLabel.text = instructions

            return cell
        }
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
        switch (self._cellTypeForSection(section)) {
        case .Ingredient:
            // I can't one-line this or remove the names because otherwise Swift will shit itself
            // even though it should be identical without using intermediate values.
            var sections: (ingredients: MeasuredIngredient[], title: String)[] = [
                (ingredients: self.recipeResult.missingIngredients,    title: "Missing Ingredients"),
                (ingredients: self.recipeResult.availableIngredients,  title: "Ingredients"),
                (ingredients: self.recipeResult.substituteIngredients, title: "Ingredients (Substitutions)")
                ].filter({ $0.ingredients.count > 0 })
            return sections[section].title

        case .Instructions:
            return "Preparation"
        }
    }
}
