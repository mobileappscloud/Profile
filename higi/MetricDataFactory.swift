//
//  MetricDataFactory.swift
//  higi
//
//  Created by Remy Panicker on 12/15/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import Foundation

/// Class with methods to extract, transform, and load graph points from activities.
final class MetricDataFactory {
   
    class func updateGraphPoints(fromActivities activities: [Activity], forMetricsType metricsType: MetricsType, inout metricGraphPoints: MetricGraphPoints) {
        
        switch metricsType {
        case .DailySummary:
            break
        case .BloodPressure:
            metricGraphPoints.bloodPressure.diastolicPoints = graphPoints(fromActivities: activities, forActivityMetric: .diastolic)
            metricGraphPoints.bloodPressure.systolicPoints = graphPoints(fromActivities: activities, forActivityMetric: .systolic)
        case .Pulse:
            metricGraphPoints.pulse.pulsePoints = graphPoints(fromActivities: activities, forActivityMetric: .pulse)
        case .Weight:
            metricGraphPoints.weight.weightPoints = graphPoints(fromActivities: activities, forActivityMetric: .weight)
        case .BodyMassIndex: 
            metricGraphPoints.bodyMassIndex.bodyMassIndexPoints = graphPoints(fromActivities: activities, forActivityMetric: .bodyMassIndex)
        case .BodyFat:
            metricGraphPoints.bodyFat.bodyFatPoints = graphPoints(fromActivities: activities, forActivityMetric: .fatRatio)
            metricGraphPoints.bodyFat.fatWeightPoints = graphPoints(fromActivities: activities, forActivityMetric: .fatMass)
        }
    }
    
    private class func graphPoints(fromActivities activities: [Activity], forActivityMetric activityMetric: Activity.Metric.Identifier) -> [GraphPoint] {
        return activities.flatMap({ graphPoint(forActivity: $0, activityMetric: activityMetric) })
    }
    
    private class func graphPoint(forActivity activity: Activity, activityMetric: Activity.Metric.Identifier) -> GraphPoint? {
        
        var metricValue: Double?
        switch activityMetric {
        case .diastolic:
            metricValue = activity.metadata.diastolic
        case .systolic:
            metricValue = activity.metadata.systolic
        case .pulse:
            metricValue = activity.metadata.pulse
        case .weight:
            metricValue = activity.metadata.weight
        case .fatRatio:
            metricValue = activity.metadata.fatRatio
        case .fatMass:
            metricValue = activity.metadata.fatMass
        case .bodyMassIndex:
            metricValue = activity.metadata.bodyMassIndex
        case .checkinFitnessLocation, .steps:
            break
        }
        
        guard let value = metricValue else { return nil }
        
        return graphPoint(forActivity: activity, value: value)
    }
    
    private class func graphPoint(forActivity activity: Activity, value: Double) -> GraphPoint {
        return GraphPoint(identifier: activity.identifier, x: activity.dateUTC.timeIntervalSince1970, y: value)
    }
}
