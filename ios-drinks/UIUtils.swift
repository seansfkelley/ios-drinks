//
//  uiUtils.swift
//  ios-drinks
//
//  Created by Sean Kelley on 6/26/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

class UIUtils {
    class func actualTargetViewControllerForSegue(segue: UIStoryboardSegue) -> UIViewController {
        if segue.destinationViewController.isKindOfClass(UINavigationController.self) {
            return (segue.destinationViewController as UINavigationController).viewControllers[0] as UIViewController
        } else {
            return segue.destinationViewController as UIViewController
        }
    }
}
