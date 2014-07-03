//
//  RecipeSourceViewController.swift
//  ios-drinks
//
//  Created by Sean Kelley on 7/3/14.
//  Copyright (c) 2014 Sean Kelley. All rights reserved.
//

import UIKit

// None of the shit in this class works. The timer doesn't trigger the selector, but it doesn't
// matter because the indicator never gets properly shown in the navigation bar anyway.
class RecipeSourceViewController: RecipeDetailPageViewController, UIWebViewDelegate {
    @IBOutlet var webView: UIWebView

    var _activityIndicator: UIActivityIndicatorView!
    var _loadCount = 0
    var _timer: NSTimer?

    override func viewDidLoad()  {
        super.viewDidLoad()

        self._activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self._activityIndicator.hidesWhenStopped = true

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self._activityIndicator)

        self.webView.scalesPageToFit = true
    }

    override func viewDidDisappear(animated: Bool)  {
        super.viewDidDisappear(animated)
        self._resetLoading()
    }

    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)
        self._resetLoading()

        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.recipeResult.recipe.sourceUrl!)))
    }

    func _resetLoading() {
        self._loadCount = 0
        if let timer = self._timer {
            timer.invalidate()
        }
        self._updateSpinners()
    }

    func _updateSpinners() {
        if self._loadCount > 0 {
            self._activityIndicator.startAnimating()
        } else {
            self._activityIndicator.stopAnimating()
        }
    }

    func _requestSpinnerUpdate() {
        if let timer = self._timer {
            timer.invalidate()
        }
        self._timer = NSTimer(timeInterval: 0.1, target: self, selector: "_updateSpinners", userInfo: nil, repeats: false)
    }

    func webViewDidStartLoad(webView: UIWebView) {
        self._loadCount += 1
        self._requestSpinnerUpdate()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        self._loadCount -= 1
        self._requestSpinnerUpdate()
    }
}
