//
//  MetricGraphPoints.swift
//  higi
//
//  Created by Remy Panicker on 9/26/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

// Eventually these models should be removed from the app as we continue refactoring metrics and are able to specify a generic data source for a metric.

struct MetricGraphPoints {
    var dailySummary = DailySummaryMetricGraphPoints()
    var bloodPressure = BloodPressureMetricGraphPoints()
    var pulse = PulseMetricGraphPoints()
    var weight = WeightMetricGraphPoints()
    var bodyMassIndex = BodyMassIndexGraphPoints()
    var bodyFat = BodyFatMetricGraphPoints()
}

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
    /// Pulse readings stored in beats per minute.
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
    /// Portion of body weight comprised of body fat. _Ex: 45.12 lbs_
    var fatWeightPoints: [GraphPoint] = []
}
