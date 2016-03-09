//
//  InterfaceOrientation.swift
//  higi
//
//  Created by Remy Panicker on 3/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
   This file contains all interface orientation preferences for each view. Ideally, we will work towards supporting adaptive layout, at which point, this file and all extensions can simply be deleted. Unfortunately, we can not create a protocol extension and compose interface orientation behavior on each class because the relevant interface orientation methods are defined in `UIViewController` itself. And no, we don't want to create a base subclass to share the interface orientation preferences.
 */

final class InterfaceOrientation {
    
    class func isLandscape(size: CGSize) -> Bool {
        return size.width > size.height
    }
    
    /**
     Force the device to change interface orientations. **Warning: This method should only be used when absolutely necessary.**
     
     - parameter interfaceOrientation: Desired interface orientation. 
     */
    class func force(interfaceOrientation: UIInterfaceOrientation) {
        let value = interfaceOrientation.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
}

// MARK: - Tab Bar Controller

extension TabBarController {
    
    /**
     Hides the tab bar based on the size.
     
     - parameter size: Size of superview or screen.
     */
    func hideTabBar(forSize size: CGSize) {
        // Remove this code after the app can handle adaptive layout.
        self.tabBar.hidden = InterfaceOrientation.isLandscape(size)
    }
}

extension TabBarController {
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        let preference: UIInterfaceOrientation = .Portrait
        guard let selectedViewController = self.selectedViewController else { return preference }
        
        if let navigationController = selectedViewController as? UINavigationController {
            return navigationController.preferredInterfaceOrientationForPresentation() ?? preference
        } else {
            return selectedViewController.preferredInterfaceOrientationForPresentation() ?? preference
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let preference: UIInterfaceOrientationMask = .Portrait
        guard let selectedViewController = self.selectedViewController else { return preference }
        
        if let navigationController = selectedViewController as? UINavigationController {
            return navigationController.supportedInterfaceOrientations() ?? preference
        } else {
            return selectedViewController.supportedInterfaceOrientations() ?? preference
        }
    }
    
    override func shouldAutorotate() -> Bool {
        let preference: Bool = false
        guard let selectedViewController = self.selectedViewController else { return preference }
        
        if let navigationController = selectedViewController as? UINavigationController {
            return navigationController.shouldAutorotate() ?? preference
        } else {
            return selectedViewController.shouldAutorotate() ?? preference
        }
    }
}

extension TabBarController {
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        hideTabBar(forSize: size)
    }
}

// MARK: - Navigation Controller

extension UINavigationController {
    
    override public func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if let _ = self.topViewController as? NewMetricsViewController {
            // This prevents the Metrics view from being rendered upside down after the modally presented Metric Detail view is dismissed.
            let currentOrientation = UIDevice.currentDevice().orientation
            if currentOrientation.isPortrait {
                return .Portrait
            } else {
                return UIDevice.currentDevice().orientation == .LandscapeLeft ? .LandscapeRight : .LandscapeLeft
            }
        } else if let _ = self.topViewController as? MetricDetailViewController {
            return .LandscapeLeft
        } else {
            return .Portrait
        }
    }
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let _ = self.topViewController as? NewMetricsViewController {
            return .AllButUpsideDown
        } else if let _ = self.topViewController as? MetricDetailViewController {
            return .Landscape
        } else {
            return .Portrait
        }
    }
    
    override public func shouldAutorotate() -> Bool {
        if let _ = self.topViewController as? NewMetricsViewController {
            return true
        } else if let _ = self.topViewController as? MetricDetailViewController {
            return true
        } else {
            return false
        }
    }
}
