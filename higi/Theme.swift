//
//  Theme.swift
//  higi
//
//  Created by Remy Panicker on 2/11/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class Theme {
    
    /// Represents colors as specified in [style guide](http://consistify.higi.com/#/colors).
    struct Color {
        static let primary = Primary.green
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
        
        static let lightTeal = Secondary.teal
        
        static let teal = Secondary.teal
        
        static let darkTeal = Utility.colorFromHexString("#2C9B95")
        
        static let lightLavender = Secondary.lavender
        
        static let lavender = Secondary.lavender
        
        static let darkLavender = Utility.colorFromHexString("#8B59Bf")
        
        static let lightGrape = Secondary.grape
        
        static let grape = Secondary.grape
        
        static let darkGrape = Utility.colorFromHexString("#8B59Bf")
        
        static let green = Primary.green
        
        static let darkGreen = Utility.colorFromHexString("#599033")
        
        static let whiteGray = Primary.whiteGray
        
        static let silver = Primary.silver
        
        static let pewter = Primary.pewter
        
        static let charcoal = Primary.charcoal
    }
}

// MARK: - Metrics

// MARK: Activity

extension Theme.Color {
    
    struct Activity {
        static let primary = Primary.green
    }
}

// MARK: Blood Pressure

extension Theme.Color {
    
    struct BloodPressure {
        
        static let primary = Utility.colorFromHexString("#8379B5")
        
        static let secondary = Utility.colorFromHexString("#2C9B95")
        
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
        
        static let primary = Utility.colorFromHexString("#5FAFDF")
        
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
        
        static let primary = BodyMassIndex.primary
        
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
        
        static let primary = Utility.colorFromHexString("#EE6C55")
        
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
        
        static let primary = Weight.primary
        
        struct Category {
            
            static let healthy = HealthStatus.green
            
            static let acceptable = HealthStatus.yellow
            
            static let atRisk = HealthStatus.orange
        }
    }
}

// MARK: - Core Plot

extension Theme.Color {
    
    struct Metrics {
        
        struct Plot {
            
            static let symbol = Secondary.teal
            
            static let line = Secondary.teal
            
            static func gradientStart() -> CPTColor {
                let color = CPTColor(CGColor: line.CGColor)
                return color.colorWithAlphaComponent(0.2)
            }
            
            static func gradientEnd() -> CPTColor {
                let color = CPTColor(CGColor: line.CGColor)
                return color.colorWithAlphaComponent(0.05)
            }
        }
    }
}

// MARK: - Protocols

// MARK: Navigation Bar

protocol ThemeNavBar {
    
    func configureNavBar(navBar: UINavigationBar)
}

extension ThemeNavBar {
    
    func configureNavBar(navBar: UINavigationBar) {
        navBar.translucent = false
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        navBar.tintColor = UIColor.whiteColor()
        navBar.barTintColor = Theme.Color.primary
        navBar.barStyle = .Black
    }
}