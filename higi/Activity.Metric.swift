//
//  Activity.Metric.swift
//  higi
//
//  Created by Remy Panicker on 8/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import HealthKit

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
     - fatMass:                Portion of body mass comprised of fat
     - weight:                 Body mass
     - diastolic:              Arterial pressure between heart beats
     - systolic:               Arterial pressure when the heart beats
     - bodyMassIndex:          Body mass index
     - pulse:                  Heart rate
     - checkinFitnessLocation: Check-in to fitness location
     */
    enum Identifier: APIString {
        case steps
        case fatRatio
        case fatMass
        case weight
        case diastolic
        case systolic
        case bodyMassIndex = "bmi"
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

// MARK: - Blood Pressure

extension Activity.Metric {
    
    struct BloodPressure {
        
        enum Reading {
            case diastolic
            case systolic
        }
        
        enum `Class`: APIString {
            case normal
            case atRisk = "atrisk"
            case high
            
            static let allValues = [normal, atRisk, high]
        }
    }
}

extension Activity.Metric.BloodPressure.Class {
    
    func name() -> String {
        let name: String
        switch self {
        case .normal:
            name = NSLocalizedString("BLOOD_PRESSURE_RANGE_NORMAL_TITLE", comment: "Title for blood pressure within a normal range.")
        case .atRisk:
            name = NSLocalizedString("BLOOD_PRESSURE_RANGE_AT_RISK_TITLE", comment: "Title for blood pressure within an at-risk range.")
        case .high:
            name = NSLocalizedString("BLOOD_PRESSURE_RANGE_HIGH_TITLE", comment: "Title for blood pressure within a high range.")
        }
        return name
    }
    
    func color() -> UIColor {
        let color: UIColor
        switch self {
        case .normal:
            color = Theme.Color.BloodPressure.Category.healthy
        case .atRisk:
            color = Theme.Color.BloodPressure.Category.atRisk
        case .high:
            color = Theme.Color.BloodPressure.Category.high
        }
        return color
    }
}

extension Activity.Metric.BloodPressure {
    
    private static func range(forReading reading: Activity.Metric.BloodPressure.Reading, `class`: Activity.Metric.BloodPressure.Class) -> (lowerBounds: Double, upperBounds: Double) {
        let range: (lowerBounds: Double, upperBounds: Double)
        switch reading {
        case .systolic:
            switch `class` {
            case .normal:
                range = (90, 120)
            case .atRisk:
                range = (120, 140)
            case .high:
                range = (140, 200)
            }
        case .diastolic:
            switch `class` {
            case .normal:
                range = (60, 80)
            case .atRisk:
                range = (80, 90)
            case .high:
                range = (90, 120)
            }
        }
        return range
    }
    
    static func ranges(forReading reading: Activity.Metric.BloodPressure.Reading) -> [MetricGauge.Range] {
        var ranges: [MetricGauge.Range] = []
        for `class` in `Class`.allValues {
            let name = `class`.name()
            let color = `class`.color()
            let interval = self.range(forReading: reading, class: `class`)
            let range = MetricGauge.Range(label: name, color: color, interval: interval)
            ranges.append(range)
        }
        return ranges
    }
}

// MARK: - Body Mass Index

extension Activity.Metric {
    
    struct BodyMassIndex {
        
        enum `Class`: APIString {
            case underweight
            case normal
            case overweight
            case obese
            
            static let allValues = [underweight, normal, overweight, obese]
        }
    }
}

extension Activity.Metric.BodyMassIndex.Class {
    
    /**
     Body Mass Index (BMI) range as classified by the Center for Disease Control and Prevention.
     [CDC Reference](http://www.cdc.gov/healthyweight/assessing/bmi/adult_bmi/)
     
     - returns: Body Mass Index range for a given weight category.
     */
    func range() -> (lowerBounds: Double, upperBounds: Double) {
        let range: (lowerBounds: Double, upperBounds: Double)!
        switch self {
        case .underweight:
            range = (10.0, 18.5)
        case .normal:
            range = (18.5, 25.0)
        case .overweight:
            range = (25.0, 30.0)
        case .obese:
            range = (30.0, 50.0)
        }
        return range
    }
    
    func name() -> String {
        let name: String
        switch self {
        case .underweight:
            name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_UNDERWEIGHT_LABEL", comment: "Label for a weight which falls within an underweight range.")
        case .normal:
            name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_NORMAL_LABEL", comment: "Label for a weight which falls within a normal range.")
        case .overweight:
            name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_OVERWEIGHT_LABEL", comment: "Label for a weight which falls within an overweight range.")
        case .obese:
            name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_OBESE_LABEL", comment: "Label for a weight which falls within an obese range.")
        }
        return name
    }
    
    func color() -> UIColor {
        let color: UIColor
        switch self {
        case .underweight:
            color = Theme.Color.BodyMassIndex.Category.underweight
        case .normal:
            color = Theme.Color.BodyMassIndex.Category.normal
        case .overweight:
            color = Theme.Color.BodyMassIndex.Category.overweight
        case .obese:
            color = Theme.Color.BodyMassIndex.Category.obese
        }
        return color
    }
}

extension Activity.Metric.BodyMassIndex.Class {
    
    static func ranges() -> [MetricGauge.Range] {
        var ranges: [MetricGauge.Range] = []
        for category in Activity.Metric.BodyMassIndex.Class.allValues {
            let label = category.name()
            let color = category.color()
            let interval = category.range()
            let range = MetricGauge.Range(label: label, color: color, interval: interval)
            ranges.append(range)
        }
        return ranges
    }
}

// MARK: - Pulse

extension Activity.Metric {
    
    struct Pulse {
        
        enum `Class`: APIString {
            case low
            case normal
            case high
            
            static let allValues = [low, normal, high]
        }
    }
}

extension Activity.Metric.Pulse.Class {
    
    func name() -> String {
        let name: String
        switch self {
        case .low:
            name = NSLocalizedString("PULSE_RANGE_LOW_TITLE", comment: "Title for pulse reading which falls within a low range.")
        case .normal:
            name = NSLocalizedString("PULSE_RANGE_NORMAL_TITLE", comment: "Title for pulse reading which falls within a normal range.")
        case .high:
            name = NSLocalizedString("PULSE_RANGE_HIGH_TITLE", comment: "Title for pulse reading which falls within a high range.")
        }
        return name
    }
    
    func color() -> UIColor {
        let color: UIColor
        switch self {
        case .low:
            color = Theme.Color.Pulse.Category.low
        case .normal:
            color = Theme.Color.Pulse.Category.normal
        case .high:
            color = Theme.Color.Pulse.Category.high
        }
        return color
    }
}

extension Activity.Metric.Pulse.Class {
    
    static func ranges() -> [MetricGauge.Range] {
        var ranges: [MetricGauge.Range] = []
        for category in Activity.Metric.Pulse.Class.allValues {
            let label = category.name()
            let color = category.color()
            let interval = category.range()
            let range = MetricGauge.Range(label: label, color: color, interval: interval)
            ranges.append(range)
        }
        return ranges
    }
    
    func range() -> (lowerBounds: Double, upperBounds: Double) {
        switch self {
        case .low:
            return (40.0, 60.0)
        case .normal:
            return (60.0, 100.0)
        case .high:
            return (100.0, 120.0)
        }
    }
}

// MARK: - Body Fat

extension Activity.Metric {
    
    struct Fat {
        
        enum `Class`: APIString {
            case healthy
            case acceptable
            case atRisk = "atrisk"
            
            static let allValues = [healthy, acceptable, atRisk]
        }
    }
}

extension Activity.Metric.Fat.Class {
    
    func name() -> String {
        let name: String
        switch self {
        case .healthy:
            name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_HEALTHY_LABEL", comment: "Label for a weight which falls within a healthy range.")
        case .acceptable:
            name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_ACCEPTABLE_LABEL", comment: "Label for a weight which falls within an acceptable range.")
        case .atRisk:
            name = NSLocalizedString("WEIGHT_METRICS_WEIGHT_RANGE_AT_RISK_LABEL", comment: "Label for a weight which falls within an at-risk range.")
        }
        return name
    }
    
    func color() -> UIColor {
        let color: UIColor
        switch self {
        case .healthy:
            color = Theme.Color.BodyFat.Category.healthy
        case .acceptable:
            color = Theme.Color.BodyFat.Category.acceptable
        case .atRisk:
            color = Theme.Color.BodyFat.Category.atRisk
        }
        return color
    }
}

extension Activity.Metric.Fat.Class {
    
    func range(biologicalSex: HKBiologicalSex) -> (lowerBounds: Double, upperBounds: Double) {
        let range: (lowerBounds: Double, upperBounds: Double)
        let isMale = biologicalSex == .Male
        switch self {
        case .healthy:
            range = isMale ? (5, 18) : (10, 25)
        case .acceptable:
            range = isMale ? (18, 25) : (25, 32)
        case .atRisk:
            range = isMale ? (25, 40) : (32, 45)
        }
        return range
    }
    
    static func ranges(biologicalSex: HKBiologicalSex) -> [MetricGauge.Range] {
        var ranges: [MetricGauge.Range] = []
        for category in Activity.Metric.Fat.Class.allValues {
            let label = category.name()
            let color = category.color()
            let interval = category.range(biologicalSex)
            let range = MetricGauge.Range(label: label, color: color, interval: interval)
            ranges.append(range)
        }
        return ranges
    }
}
