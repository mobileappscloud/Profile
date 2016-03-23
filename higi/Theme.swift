//
//  Theme.swift
//  higi
//
//  Created by Remy Panicker on 2/11/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

/// This class contains all 
final class Theme {
    
    /// Represents colors as specified in [style guide](http://consistify.higi.com/#/colors).
    struct Color {
        static let primary = Primary.green
    }
    
    /// Contains common themed stylings which can be applied to UI elements. Leverages `UIAppearance` to apply global styling.
    struct Appearance {
        static func applyGlobalStylings() {
            NavigationBar.style()
            TabBar.style()
        }
    }
}

// MARK: - Color

extension Theme.Color {
    
    struct Primary {
        
        static let green = Utility.colorFromHexString("#76C044")
        
        static let white = Utility.colorFromHexString("#FFFFFF")
        
        static let whiteGray = Utility.colorFromHexString("#F1F1F1")
        
        static let silver = Utility.colorFromHexString("#CBCCCB")
        
        static let pewter = Utility.colorFromHexString("#808080")
        
        static let charcoal = Utility.colorFromHexString("#41423F")
    }
}

extension Theme.Color {
    
    struct Secondary {
        
        static let teal = Utility.colorFromHexString("#3ACEC7")
        
        static let lavender = Utility.colorFromHexString("#BA77FF")
        
        static let grape = Utility.colorFromHexString("#7B3979")
    }
}

extension Theme.Color {
    
    struct HealthStatus {
        
        static let green = Primary.green
        
        static let blue = Utility.colorFromHexString("#0093C7")
        
        static let orange = Utility.colorFromHexString("#F5821F")
    
        static let yellow = Utility.colorFromHexString("#FFDD00")
        
        static let red = Utility.colorFromHexString("#D8203C")
    }
}

extension Theme.Color {
    
    struct Illustration {
        
        static let lightTeal = Utility.colorFromHexString("#61D8D2")
        
        static let teal = Secondary.teal
        
        static let darkTeal = Utility.colorFromHexString("#2C9B95")
        
        static let lightLavender = Utility.colorFromHexString("#C892FF")
        
        static let lavender = Secondary.lavender
        
        static let darkLavender = Utility.colorFromHexString("#8B59BF")
        
        static let lightGrape = Utility.colorFromHexString("#956194")
        
        static let grape = Secondary.grape
        
        static let darkGrape = Utility.colorFromHexString("#5C2B5B")
        
        static let green = Primary.green
        
        static let darkGreen = Utility.colorFromHexString("#599033")
        
        static let whiteGray = Primary.whiteGray
        
        static let silver = Primary.silver
        
        static let pewter = Primary.pewter
        
        static let charcoal = Primary.charcoal
    }
}

// MARK: - Metrics

// MARK: Blood Pressure

extension Theme.Color {
    
    struct BloodPressure {
        
        struct Category {
            
            static let healthy = HealthStatus.green
            
            static let atRisk = HealthStatus.yellow
            
            static let high = HealthStatus.orange
        }
    }
}

// MARK: Pulse

extension Theme.Color {
    
    struct Pulse {
        
        struct Category {
            
            static let low = HealthStatus.blue
            
            static let normal = HealthStatus.green
            
            static let high = HealthStatus.orange
        }
    }
}

// MARK: Weight 

extension Theme.Color {
    
    struct Weight {
        
        struct Category {
            
            static let underweight = BodyMassIndex.Category.underweight
            
            static let normal = BodyMassIndex.Category.normal
            
            static let overweight = BodyMassIndex.Category.overweight
            
            static let obese = BodyMassIndex.Category.obese
        }
    }
}

// MARK: Body Mass Index

extension Theme.Color {
    
    struct BodyMassIndex {
        
        struct Category {
            
            static let underweight = HealthStatus.yellow
            
            static let normal = HealthStatus.green
            
            static let overweight = HealthStatus.orange
            
            static let obese = HealthStatus.red
        }
    }
}

// MARK: Body Fat

extension Theme.Color {
    
    struct BodyFat {
        
        struct Category {
            
            static let healthy = HealthStatus.green
            
            static let acceptable = HealthStatus.yellow
            
            static let atRisk = HealthStatus.red
        }
    }
}

// MARK: - Core Plot

extension Theme.Color {
    
    struct Metrics {
        
        static let primary = Secondary.teal

        static let secondary = Utility.colorFromHexString("#2C9B95")
        
        static let text = primary
        
        struct Plot {
            
            static let symbol = primary
            
            static let line = primary
            
            static func gradientStart() -> CPTColor {
                let color = CPTColor(CGColor: line.CGColor)
                return color.colorWithAlphaComponent(0.2)
            }
            
            static func gradientEnd() -> CPTColor {
                let color = CPTColor(CGColor: line.CGColor)
                return color.colorWithAlphaComponent(0.05)
            }
        }
        
        struct TableView {
            
            static let selectedCellBackGround = Metrics.Plot.line.colorWithAlphaComponent(0.3)
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
