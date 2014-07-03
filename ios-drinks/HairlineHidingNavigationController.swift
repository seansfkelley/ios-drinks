//
//  HairlineHidingNavigationController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/2/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

func _findSubviewWithClass(view: UIView, klass: AnyClass) -> UIView? {
    if view.subviews?.count > 0 {
        for v in view.subviews as UIView[] {
            if v.isKindOfClass(klass) {
                return v
            }
        }
    }
    return nil
}

// http://stackoverflow.com/questions/21887252/uisegmentedcontrol-below-uinavigationbar-in-ios-7
class HairlineHidingNavigationController: UINavigationController {
    var hairlineImageView: UIImageView?

    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)

        let barBackgroundView = _findSubviewWithClass(self.navigationBar, NSClassFromString("_UINavigationBarBackground"))
        if barBackgroundView {
            self.hairlineImageView = _findSubviewWithClass(barBackgroundView!, UIImageView.self) as? UIImageView
        }

        if self.hairlineImageView {
            self.hairlineImageView!.hidden = true
        }
    }

    override func viewDidDisappear(animated: Bool)  {
        if self.hairlineImageView {
            self.hairlineImageView!.hidden = false
        }

        super.viewDidDisappear(animated)
    }
}
