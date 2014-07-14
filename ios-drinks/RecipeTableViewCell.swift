//
//  RecipeTableViewCell.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

let RecipeTableViewCell_SEGUE_NAME = "recipeTableViewCellSelected"

class RecipeTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel
    @IBOutlet var subtitleLabel: UILabel
    @IBOutlet var subtitleAsideLabel: UILabel
    @IBOutlet var recipeImageView: UIImageView

    var controller: UIViewController!
    var tableView: UITableView!

    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)  {
        var indexPath = self.tableView.indexPathForCell(self)
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)

        self.controller.performSegueWithIdentifier(RecipeTableViewCell_SEGUE_NAME, sender: self)

        super.touchesEnded(touches, withEvent: event)
    }
}
