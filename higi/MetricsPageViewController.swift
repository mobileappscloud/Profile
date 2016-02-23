//
//  MetricsPageViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/3/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

/// `UIPageViewController` subclass which contains various child viewcontrollers with metrics data.
final class MetricsPageViewController: UIPageViewController {

    // Sorry... 🤐
    lazy private var internalScrollView: UIScrollView? = {
        var internalScrollView: UIScrollView? = nil
        for view in self.view.subviews {
            if view.isKindOfClass(UIScrollView) {
                internalScrollView = view as? UIScrollView
                break
            }
        }
        return internalScrollView
    }()
    
    /// Returns `true` if the `UIPageViewcontroller` can scroll to transition between child viewcontrollers.
    private(set) var scrollEnabled: Bool? = true
    
    /**
     Enable or disable scrolling to transition between child viewcontrollers.

     - parameter scrollEnabled: Whether scrolling is enabled to transition between child viewcontrollers.
     */
    func scrollEnabled(scrollEnabled: Bool) {
        self.scrollEnabled = scrollEnabled
        self.internalScrollView?.scrollEnabled = scrollEnabled
    }
}
