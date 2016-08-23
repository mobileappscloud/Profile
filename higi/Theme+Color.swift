//
//  Theme+Color.swift
//  higi
//
//  Created by Remy Panicker on 4/5/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

extension Theme {
    
    /// Represents colors as specified in [style guide](http://consistify.higi.com/#/colors).
    struct Color {
        static let primary = Primary.green
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
            
            static let atRisk = HealthStatus.orange
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

// MARK: - Sign Up

extension Theme.Color {
    
    struct SignUp {
        struct Email {
            static let errorPlaceholder = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        }
        
        struct Name {
            static let errorPlaceholder = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        }
    }
    
    struct LogIn {
        static let errorPlaceholder = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
    }
    
    struct ChangePassword {
        static let errorPlaceholder = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
    }
}


// MARK: - Challenges

extension Theme.Color {
    
    struct Challenge {
        struct Status {
            static let unjoinedAndUnderway = Primary.green
            static let unjoinedAndNotUnderway = Utility.colorFromHexString("#F5821F")
            static let joinedAndUnderway = Primary.green
            static let joinedAndNotUnderway = Utility.colorFromHexString("#F5821F")
            static let tabulatingResults = Utility.colorFromHexString("#F5821F")
            static let challengeComplete = Utility.colorFromHexString("#A30D22")
            static let cancelled = Utility.colorFromHexString("#A30D22")
        }
    }
    
}

extension Theme.Color.Challenge {
    
    struct Detail {
        static let joinButton = Theme.Color.Primary.green
        static let inviteButton = Theme.Color.Secondary.teal
        static let buttonText = Theme.Color.Primary.white
    }
}

extension Theme.Color.Challenge.Detail {
    
    struct Segment {
        static let officialRulesText = Utility.colorFromHexString("#8CC63F")
        static let chevron = Utility.colorFromHexString("#8CC63F")
        static let defaultTint = UIColor.blackColor()
    }
}


// MARK: - Content Service

extension Theme.Color {
    
    struct Content {}
}

extension Theme.Color.Content {

    struct Comment {
        
        struct TextInput {
            static let borderColor = Theme.Color.Primary.silver
            static let buttonTintColor = Theme.Color.primary
        }
    }
    
    struct ActionBar {
        
        static let primary = Theme.Color.primary
        
        static let secondary = Theme.Color.Primary.pewter
    }
}


// MARK: - Leaderboard

extension Theme.Color {
    
    struct Leaderboard {
        struct User {
            static let borderColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        }
    }
    
}
