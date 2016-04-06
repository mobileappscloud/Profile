//
//  Theme+Appearance.swift
//  higi
//
//  Created by Remy Panicker on 4/5/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

extension Theme {
    
    /// Contains common themed stylings which can be applied to UI elements. Leverages `UIAppearance` to apply global styling.
    struct Appearance {
        static func applyGlobalStylings() {
            NavigationBar.style()
            TabBar.style()
        }
    }
}


// MARK: - Appearance

extension Theme.Appearance {
    
    struct NavigationBar {
        
        static let barTintColor = Theme.Color.primary
        static let tintColor = Theme.Color.Primary.white
        static let unselectedTintColor = Theme.Color.Primary.whiteGray
        
        static func style() {
            let navigationBar = UINavigationBar.appearance()
            navigationBar.translucent = false
            
            navigationBar.barTintColor = barTintColor
            navigationBar.barStyle = .Black
            
            navigationBar.tintColor = tintColor
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : tintColor]
            
            let barButtonItem: UIBarButtonItem!
            if #available(iOS 9.0, *) {
                barButtonItem = UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self])
            } else {
                barButtonItem = UIBarButtonItem.higi_appearanceWhenContainedIn(UINavigationBar.self)
            }
            barButtonItem.tintColor = navigationBar.tintColor
            barButtonItem.setTitleTextAttributes(navigationBar.titleTextAttributes, forState: .Normal)
            barButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName : unselectedTintColor], forState: .Disabled)
        }
    }
}

extension Theme.Appearance {
    
    struct TabBar {
        
        static let selectedTintColor = Theme.Color.primary
        static let unselectedTintColor = Theme.Color.Primary.charcoal
        
        static func style() {
            let tabBar = UITabBar.appearance()
            
            // Set color for selected tab bar item
            tabBar.tintColor = selectedTintColor
            
            let tabBarItem = UITabBarItem.appearance()
            // Set text tint color for unselected tab bar item
            let unselectedAttributes = [NSForegroundColorAttributeName: unselectedTintColor]
            tabBarItem.setTitleTextAttributes(unselectedAttributes, forState: .Normal)
            
            let selectedAttributes = [NSForegroundColorAttributeName: selectedTintColor]
            tabBarItem.setTitleTextAttributes(selectedAttributes, forState: .Selected)
        }
    }
}
