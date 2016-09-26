//
//  Device.Identifier.swift
//  higi
//
//  Created by Remy Panicker on 8/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Device {
    
    /**
     Identifier for the third-party activity tracking partner. Current integrations include:
     
     - nike
     - runkeeper
     - fitbit
     - foursquare
     - mapMyFitness
     - everyTrail
     - garmin
     - bodyMedia
     - endomondo
     - omron
     - moves
     - jawbone
     - higi
     - strava
     - misfit
     - striiv
     - withings
     - iHealth
     - underArmour
     - microsoftBand
     */
    enum Identifier: APIString {
        case nike
        case runkeeper
        case fitbit
        case foursquare
        case mapMyFitness = "mapmyfitness"
        case everyTrail = "everytrail"
        case garmin
        case bodyMedia = "bodymedia"
        case endomondo
        case omron
        case moves
        case jawbone
        case higi
        case strava
        case misfit
        case striiv
        case withings
        case iHealth = "ihealth"
        case underArmour = "underarmour"
        case microsoftBand = "microsoftband"
    }
}
