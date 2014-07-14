//
//  SimilarDrinksViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/13/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

let _SimilarDrinksViewController_PROTOTYPE_CELL_IDENTIFIER = "RecipePrototypeCell"

class SimilarDrinksViewController: RecipeDetailPageViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView

    var manager: AlphabeticalTableSectionManager<RecipeSearchResult>!

    override func viewDidLoad()  {
        super.viewDidLoad()

        self.tableView.registerNib(UINib(nibName: "RecipeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: _SimilarDrinksViewController_PROTOTYPE_CELL_IDENTIFIER)

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.manager = AlphabeticalTableSectionManager<RecipeSearchResult>(
            items: RecipeIndex.instance().getSimilarRecipes(self.recipeResult.recipe).map({ RecipeIndex.generateDummySearchResultFor($0) }),
            titleExtractor: { $0.recipe.name })
    }

    // pragma mark UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.manager.orderedSections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager.orderedSections[section].count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(_SimilarDrinksViewController_PROTOTYPE_CELL_IDENTIFIER) as RecipeTableViewCell
        cell.controller = self
        cell.tableView = tableView

        let recipe = self.manager!.objectAtIndexPath(indexPath).recipe

        cell.titleLabel.text = recipe.name
        cell.subtitleLabel.text = "\(recipe.measuredIngredients.count) ingredients"
        cell.subtitleAsideLabel.hidden = true
        cell.recipeImageView.image = UIImage(named: "DefaultRecipeImage")

        return cell
    }
}
