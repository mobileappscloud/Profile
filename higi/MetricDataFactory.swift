//
//  MetricDataFactory.swift
//  higi
//
//  Created by Remy Panicker on 12/15/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation

/**
 *   Data structure which stores graph points for higi Activities.
 */
struct DailySummaryMetricGraphPoints {
    /// Activity points as represented in a user's higi Score.
    var activityPoints: [GraphPoint] = []
}

/**
 *   Data structure which stores graph points for blood pressure readings.
 */
struct BloodPressureMetricGraphPoints {
    /// Systolic blood pressure reading stored in mmHg.
    var systolicPoints: [GraphPoint] = []
    /// Diastolic blood pressure reading stored in mmHg.
    var diastolicPoints: [GraphPoint] = []
}

/**
 *   Data structure which stores graph points for pulse readings.
 */
struct PulseMetricGraphPoints {
    /// Pulse readings sttored in beats per minute.
    var pulsePoints: [GraphPoint] = []
}

/**
 *   Data structure which stores graph points for weight readings.
 */
struct WeightMetricGraphPoints {
    /// Body weight readings.
    var weightPoints: [GraphPoint] = []
}

/**
 *   Data structure which stores graph points for body mass index readings.
 */
struct BodyMassIndexGraphPoints {
    /// Calculated values for body mass index.
    var bodyMassIndexPoints: [GraphPoint] = []
}

/**
 *   Data structure which stores graph points for body fat readings.
 */
struct BodyFatMetricGraphPoints {
    /// Body fat as a percentage. _Ex: 21.82 %_
    var bodyFatPoints: [GraphPoint] = []
    /// Portion of body weight comprised of body fat. Values are calculated using body fat ratio. _Ex: 45.12 lbs_
    var fatWeightPoints: [GraphPoint] = []
}

struct MetricGraphPoints {
    var dailySummary: DailySummaryMetricGraphPoints
    var bloodPressure: BloodPressureMetricGraphPoints
    var pulse: PulseMetricGraphPoints
    var weight: WeightMetricGraphPoints
    var bodyMassIndex: BodyMassIndexGraphPoints
    var bodyFat: BodyFatMetricGraphPoints
}

/// Class with methods to extract, transform, and load graph points from activities and checkins.
final class MetricDataFactory {

}

// These functions are partially-refactored versions of the original ETL code.
extension MetricDataFactory {
    
    func metricData(checkins: [HigiCheckin]?, activitiesDictionary: [String: (totalPoints: Int, activities: [HigiActivity])]?) -> MetricGraphPoints {
        
        let checkinPoints = graphPoints(checkins)
        let activityPoints = graphPoints(activitiesDictionary)
        let metricsPoints = MetricGraphPoints(dailySummary: activityPoints, bloodPressure: checkinPoints.bloodPressure, pulse: checkinPoints.pulse, weight: checkinPoints.weight, bodyMassIndex: checkinPoints.bodyMassIndex, bodyFat: checkinPoints.bodyFat)
        
        return metricsPoints
    }
    
    func graphPoints(checkins: [HigiCheckin]?) -> (bloodPressure: BloodPressureMetricGraphPoints, pulse: PulseMetricGraphPoints, weight: WeightMetricGraphPoints, bodyMassIndex: BodyMassIndexGraphPoints, bodyFat: BodyFatMetricGraphPoints) {
        guard let checkins = checkins else {
            return (BloodPressureMetricGraphPoints(), PulseMetricGraphPoints(), WeightMetricGraphPoints(), BodyMassIndexGraphPoints(), BodyFatMetricGraphPoints())
        }
        
        var diastolicPoints: [GraphPoint] = []
        var systolicPoints: [GraphPoint] = []
        
        var pulsePoints: [GraphPoint] = []
        
        var weightPoints: [GraphPoint] = []
        
        var bodyMassIndexPoints: [GraphPoint] = []
        
        var bodyFatPoints: [GraphPoint] = []
        var fatWeightPoints: [GraphPoint] = []
        
        // We only want to plot the latest metric reading for a given date. Sort the checkins in reverse chronological order so that we can store the first reading for a given date and ignore preceding readings for the same date.
        let sortedCheckins = checkins.reverse()
        
        var lastBloodPressureDate: NSDate = NSDate.distantFuture()
        var lastPulseDate: NSDate = NSDate.distantFuture()
        var lastWeightDate: NSDate = NSDate.distantFuture()
        var lastBodyMassIndexDate: NSDate = NSDate.distantFuture()
        var lastBodyFatDate: NSDate = NSDate.distantFuture()

        let calendar = NSCalendar.currentCalendar()
        
        for checkin in sortedCheckins {
            guard let checkinId = checkin.checkinId else { continue }
            let checkinTime = checkin.dateTime.timeIntervalSince1970
            
            if !(calendar.isDate(checkin.dateTime, inSameDayAsDate: lastBloodPressureDate)) {
                if let diastolic = checkin.diastolic, let systolic = checkin.systolic {
                    diastolicPoints.append(GraphPoint(identifier: checkinId, x: checkinTime, y: Double(diastolic)))
                    systolicPoints.append(GraphPoint(identifier: checkinId, x: checkinTime, y: Double(systolic)))
                    lastBloodPressureDate = checkin.dateTime
                }
            }

            if !(calendar.isDate(checkin.dateTime, inSameDayAsDate: lastPulseDate)) {
                if let pulseBpm = checkin.pulseBpm {
                    pulsePoints.append(GraphPoint(identifier: checkinId, x: checkinTime, y: Double(pulseBpm)))
                    lastPulseDate = checkin.dateTime
                }
            }
            
            if !(calendar.isDate(checkin.dateTime, inSameDayAsDate: lastWeightDate)) {
                if let weightLbs = checkin.weightLbs {
                    weightPoints.append(GraphPoint(identifier: checkinId, x: checkinTime, y: weightLbs))
                    lastWeightDate = checkin.dateTime
                }
            }
            
            if !(calendar.isDate(checkin.dateTime, inSameDayAsDate: lastBodyMassIndexDate)) {
                if let bodyMassIndex = checkin.bmi where bodyMassIndex != 0 {
                    bodyMassIndexPoints.append(GraphPoint(identifier: checkinId, x: checkinTime, y: bodyMassIndex))
                    lastBodyMassIndexDate = checkin.dateTime
                }
            }
            
            if !(calendar.isDate(checkin.dateTime, inSameDayAsDate: lastBodyFatDate)) {
                if let fatRatio = checkin.fatRatio where fatRatio != 0, let weightLbs = checkin.weightLbs {
                    bodyFatPoints.append(GraphPoint(identifier: checkinId, x: checkinTime, y: fatRatio))
                    let fatWeightLbs = weightLbs * fatRatio/100.0
                    fatWeightPoints.append(GraphPoint(identifier: checkinId, x: checkinTime, y: fatWeightLbs))
                    lastBodyFatDate = checkin.dateTime
                }
            }
        }
        
        let bloodPressure = BloodPressureMetricGraphPoints(systolicPoints: systolicPoints, diastolicPoints: diastolicPoints)
        let pulse = PulseMetricGraphPoints(pulsePoints: pulsePoints)
        let weight = WeightMetricGraphPoints(weightPoints: weightPoints)
        let bodyMassIndex = BodyMassIndexGraphPoints(bodyMassIndexPoints: bodyMassIndexPoints)
        let bodyFat = BodyFatMetricGraphPoints(bodyFatPoints: bodyFatPoints, fatWeightPoints: fatWeightPoints)
        return (bloodPressure, pulse, weight, bodyMassIndex, bodyFat)
    }
    
    func graphPoints(activitiesDictionary: [String: (totalPoints: Int, activities: [HigiActivity])]?) -> DailySummaryMetricGraphPoints {
        guard let activitiesDictionary = activitiesDictionary else { return DailySummaryMetricGraphPoints() }
        
        var activityPoints: [GraphPoint] = []
        for (dateString, activitySummary) in activitiesDictionary {
            guard let date = Constants.dateFormatter.dateFromString(dateString) else { continue }
            
            let activityDate = Double(date.timeIntervalSince1970)
            activityPoints.append(GraphPoint(identifier: dateString, x: activityDate, y: Double(activitySummary.totalPoints)))
        }
        activityPoints.sortInPlace({$0.x > $1.x})
        
        return DailySummaryMetricGraphPoints(activityPoints: activityPoints)
    }
}
