//
//  Activity.Metadata.swift
//  higi
//
//  Created by Remy Panicker on 9/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Activity {
    
    struct Metadata {
        
        // MARK: Metrics
        
        /// Count of steps walked.
        let steps: Int?
        
        /// Ratio of fat mass to fat-free mass (%).
        let fatRatio: Double?
        
        /// Mass which is comprised of fat (kg).
        let fatMass: Double?
        
        /// Body mass (kg).
        let weight: Double?
        
        /// The pressure in the arteries between heartbeats (when the heart muscle is resting between beats and refilling with blood) (mmHg).
        let diastolic: Double?
        
        /// The pressure in the arteries when the heart beats (when the heart muscle contracts) (mmHg).
        let systolic: Double?
        
        /// Body mass index calculation (kg/m^2).
        let bodyMassIndex: Double?
        
        /// Heart beats per minute (count/minute)
        let pulse: Double?
        
        // MARK: Check-in
        
        /// Whether or not the activity is a check-in to a fitness location.
        let checkinFitnessLocation: Bool?
        
        // MARK: Characteristics
        
        let height: Double?
        
        // MARK: Legacy Properties - These are undocumented in the new apiary docs and may be removed, but are currently required for migration
        
        // MARK: Classification
        
        let bloodPressureClass: Activity.Metric.BloodPressure.`Class`?
        
        let bodyMassIndexClass: Activity.Metric.BodyMassIndex.`Class`?
        
        let pulseClass: Activity.Metric.Pulse.`Class`?
        
        let fatClass: Activity.Metric.Fat.`Class`?
    }
}

// MARK: Converted Values 
// Temporary solution until measurements/formatters are used

extension Activity.Metadata {
   
    var weightImperial: Double? {
        get {
            let conversionFactor = 2.20462
            return imperialValue(fromMetricValue: weight, conversionFactor: conversionFactor)
        }
    }
    
    var heightImperial: Double? {
        get {
            let conversionFactor = 39.3701
            return imperialValue(fromMetricValue: height, conversionFactor: conversionFactor)
        }
    }
    
    private func imperialValue(fromMetricValue metricValue: Double?, conversionFactor: Double) -> Double? {
        guard let metricValue = metricValue else { return nil }
        return metricValue * conversionFactor
    }
}

extension Activity.Metadata: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        self.steps = dictionary[Activity.Metric.Identifier.steps.rawValue] as? Int
        self.fatRatio = dictionary[Activity.Metric.Identifier.fatRatio.rawValue] as? Double
        self.fatMass = dictionary[Activity.Metric.Identifier.fatMass.rawValue] as? Double
        self.weight = dictionary[Activity.Metric.Identifier.weight.rawValue] as? Double
        self.diastolic = dictionary[Activity.Metric.Identifier.diastolic.rawValue] as? Double
        self.systolic = dictionary[Activity.Metric.Identifier.systolic.rawValue] as? Double
        self.bodyMassIndex = dictionary[Activity.Metric.Identifier.bodyMassIndex.rawValue] as? Double
        self.pulse = dictionary[Activity.Metric.Identifier.pulse.rawValue] as? Double
        
        self.checkinFitnessLocation = dictionary[Activity.Metric.Identifier.checkinFitnessLocation.rawValue] as? Bool
        
        self.height = dictionary["height"] as? Double
        
        self.bloodPressureClass = Activity.Metric.BloodPressure.`Class`(rawJSONValue: dictionary["bpClass"])
        self.bodyMassIndexClass = Activity.Metric.BodyMassIndex.`Class`(rawJSONValue: dictionary["bmiClass"])
        self.pulseClass = Activity.Metric.Pulse.`Class`(rawJSONValue: dictionary["pulseClass"])
        self.fatClass = Activity.Metric.Fat.`Class`(rawJSONValue: dictionary["fatClass"])
    }
}
