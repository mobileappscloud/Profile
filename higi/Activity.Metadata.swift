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
        
        /// Mass which is fat-free (kg).
        let fatFreeMass: Double?
        
        /// Mass which is comprised of fat (kg).
        let fatMass: Double?
        
        /// Body mass (kg).
        let weight: Double?
        
        /// The pressure in the arteries between heartbeats (when the heart muscle is resting between beats and refilling with blood) (mmHg).
        let diastolic: Double?
        
        /// The pressure in the arteries when the heart beats (when the heart muscle contracts) (mmHg).
        let systolic: Double?
        
        /// Body mass index calculation (kg/m^2).
        let bmi: Double?
        
        /// Heart beats per minute (count/minute)
        let pulse: Double?
        
        // MARK: Check-in
        
        /// Whether or not the activity is a check-in to a fitness location.
        let checkinFitnessLocation: Bool?
    }
}

// MARK: Converted Values 
// Temporary solution until measurements/formatters are used

extension Activity.Metadata {
   
    var weightImperial: Double? {
        get {
            guard let weight = weight else { return nil }
            
            let conversionFactor = 2.20462
            return weight * conversionFactor
        }
    }
}

extension Activity.Metadata: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        self.steps = dictionary[Activity.Metric.Identifier.steps.rawValue] as? Int
        self.fatRatio = dictionary[Activity.Metric.Identifier.fatRatio.rawValue] as? Double
        self.fatFreeMass = dictionary[Activity.Metric.Identifier.fatFreeMass.rawValue] as? Double
        self.fatMass = dictionary[Activity.Metric.Identifier.fatMass.rawValue] as? Double
        self.weight = dictionary[Activity.Metric.Identifier.weight.rawValue] as? Double
        self.diastolic = dictionary[Activity.Metric.Identifier.diastolic.rawValue] as? Double
        self.systolic = dictionary[Activity.Metric.Identifier.systolic.rawValue] as? Double
        self.bmi = dictionary[Activity.Metric.Identifier.bmi.rawValue] as? Double
        self.pulse = dictionary[Activity.Metric.Identifier.pulse.rawValue] as? Double
        
        self.checkinFitnessLocation = dictionary[Activity.Metric.Identifier.checkinFitnessLocation.rawValue] as? Bool
    }
}
