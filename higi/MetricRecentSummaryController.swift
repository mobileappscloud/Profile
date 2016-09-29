//
//  MetricRecentSummaryController.swift
//  higi
//
//  Created by Remy Panicker on 9/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class MetricRecentSummaryController {
    
    private let maxActivities = 30
    private let monthsToInclude = 6
    
    private(set) var activities: [Activity] = []
}

// MARK: - Network Request

extension MetricRecentSummaryController {
    
    func fetch(activitiesForMetric metric: MetricRecentSummaryViewController.Metric, forUser user: User, success: () -> Void, failure: (error: ErrorType) -> Void) {
        
        let today = NSDate()
        guard let startDate = date(byAddingMonthComponent: -monthsToInclude, toDate: today) else {
            failure(error: Error.unknownDate)
            return
        }
        let endDate = today
        
        let pageSize = maxActivities
        let sortDescending = true
        let includeWatts = metric == .watts
        
        let activityMetrics = activityMetricIds(forMetric: metric)
        ActivityNetworkController.fetch(activitiesForUser: user, withMetrics: activityMetrics, startDate: startDate, endDate: endDate, includeWatts: includeWatts, sortDescending: sortDescending, pageSize: pageSize, success: { [weak self] (activities, paging) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.activities = activities
            success()
            
            }, failure: { [weak self] (error) in
                guard self != nil else { return }
                
                failure(error: error)
            })
    }
}

// MARK: - Metric Type Mapping

private extension MetricRecentSummaryController {
    
    func activityMetricIds(forMetric metric: MetricRecentSummaryViewController.Metric) -> [Activity.Metric.Identifier] {
        var activityMetricIds: [Activity.Metric.Identifier] = []
        switch metric {
        case .watts:
            break
        case .bloodPressure:
            activityMetricIds.appendContentsOf([.systolic, .diastolic])
        case .pulse:
            activityMetricIds.append(.pulse)
        case .weight:
            activityMetricIds.appendContentsOf([.weight, .fatRatio])
        }
        return activityMetricIds
    }
}

// MARK: Date Helper

private extension MetricRecentSummaryController {
    
    func date(byAddingMonthComponent month: Int, toDate: NSDate) -> NSDate? {
        let dateComponents = NSDateComponents()
        dateComponents.month = month
        return NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: toDate, options: NSCalendarOptions())
    }
}

// MARK: Graph Point ETL

extension MetricRecentSummaryController {
    
    func points(forMetric metric: MetricRecentSummaryViewController.Metric) -> [GraphPoint] {
        return dataSets(forMetric: metric).first ?? []
    }
    
    func altPoints(forMetric metric: MetricRecentSummaryViewController.Metric) -> [GraphPoint] {
        let metricDataSets = dataSets(forMetric: metric)
        return (metricDataSets.count > 1) ? metricDataSets[1] : []
    }
    
    private func dataSets(forMetric metric: MetricRecentSummaryViewController.Metric) -> [[GraphPoint]] {
        var dataSets: [[GraphPoint]] = []
        if metric == .watts {
            let graphPoints: [GraphPoint] = activities.flatMap({ activity in
                if let watts = activity.watts {
                    return MetricDataFactory.graphPoint(forActivity: activity, value: Double(watts))
                }
                return nil
            })
            dataSets.append(graphPoints)
        } else {
            let graphPointDictionary = graphPoints(forMetric: metric)
            activityMetricIds(forMetric: metric).forEach({ metricId in
                let graphPoints: [GraphPoint] = graphPointDictionary[metricId] ?? []
                dataSets.append(graphPoints)
            })
        }
        return dataSets
    }
 
    private func graphPoints(forMetric metric: MetricRecentSummaryViewController.Metric) -> [Activity.Metric.Identifier : [GraphPoint]] {
        var graphPoints: [Activity.Metric.Identifier : [GraphPoint]] = [:]

        let activityMetrics = activityMetricIds(forMetric: metric)
        activityMetrics.forEach({ activityMetric in
            graphPoints[activityMetric] = MetricDataFactory.graphPoints(fromActivities: activities, forActivityMetric: activityMetric)
        })
        
        return graphPoints
    }
}

// MARK: - Errors

extension MetricRecentSummaryController {
    
    enum Error: ErrorType {
        case unknownDate
    }
}
