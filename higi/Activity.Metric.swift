//
//  Activity.Metric.swift
//  higi
//
//  Created by Remy Panicker on 8/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

// MARK: - Metric

extension Activity {

    /**
     *  Representation of a health metric.
     */
    struct Metric: UniquelyIdentifiable {
        
        /// Unique identifier.
        let identifier: String
        
        /// Activity category this metric blongs to.
        let category: Activity.Category
        
        /// The type this metric's data (or value) is expressed in.
        let dataType: DataType
        
        /// The type of units this metric is expressed in.
        let unitType: UnitType
    }
}

extension Activity.Metric {

    /**
     Identifier for a metric. 
     - note: This is not an exhaustive enum. Several cases were omitted because they are not currently utilized by the app.
     
     - steps:                  Walking step count
     - fatRatio:               Fat ratio
     - fatFreeMass:            Portion of body mass which is free of fat
     - fatMass:                Portion of body mass comprised of fat
     - weight:                 Body mass
     - diastolic:              Arterial pressure between heart beats
     - systolic:               Arterial pressure when the heart beats
     - bmi:                    Body mass index
     - pulse:                  Heart rate
     - checkinFitnessLocation: Check-in to fitness location
     */
    enum Identifier: APIString {
        case steps
        case fatRatio
        case fatFreeMass
        case fatMass
        case weight
        case diastolic
        case systolic
        case bmi
        case pulse
        case checkinFitnessLocation
    }
}

extension Activity.Metric {
    
    enum DataType: APIString {
        case int
        case float
        case string
        case bool
    }
}

extension Activity.Metric {
    
    enum UnitType: APIString {
        case unknown
        case meters
        case kcal
        case steps
        case percentage
        case ohms
        case kg
        case mmHg
        case seconds
        case bpm
        case normal
        case arrhythmic
    }
}
