//
//  CPTXYPlotSpace+Utility.swift
//  higi
//
//  Created by Remy Panicker on 2/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension CPTXYPlotSpace {
    
    func configure(points: [GraphPoint], maxY: Double, minY: Double, delegate: CPTPlotSpaceDelegate) {

        let tickInterval = 10.0
        let visiblePoints = 12
        let defaultMarginX: Double = 2 * 86400 // 2 days
        
        // Guarantee that this array has atleast one point for preceding calculations
        let configurationPoints = points.count == 0 ? [GraphPoint(x: 0, y: 0)] : points
        
        let oldestPoint = configurationPoints.last!
        let mostRecentPoint = configurationPoints.first!

        let yRange = maxY - minY > 0 ? maxY - minY : tickInterval
        
        var visibleMin = oldestPoint
        if (configurationPoints.count > visiblePoints) {
            visibleMin = configurationPoints[visiblePoints]
        }
        
        var marginX: Double = (mostRecentPoint.x - visibleMin.x) * 0.1
        if (marginX == 0) {
            marginX = defaultMarginX
        }
        
        var marginY: Double = tickInterval
        let standardDeviationY = standardDeviation(configurationPoints.flatMap{$0.y}) ?? 0.0
        marginY = max(marginY, standardDeviationY * 2)
        
        self.xRange = CPTPlotRange(location_: visibleMin.x - marginX, length: mostRecentPoint.x - visibleMin.x + marginX * 2)
        self.yRange = CPTPlotRange(location_: minY - marginY, length: yRange + marginY * 2)
        
        self.globalXRange = CPTPlotRange(location_: oldestPoint.x - marginX, length: mostRecentPoint.x - oldestPoint.x + marginX * 2)
        self.globalYRange = self.yRange
        
        self.delegate = delegate
        self.allowsUserInteraction = true
    }
    
    private func standardDeviation(array : [Double]) -> Double
    {
        let length = Double(array.count)
        let avg = array.reduce(0, combine: {$0 + $1}) / length
        let sumOfSquaredAvgDiff = array.map { pow($0 - avg, 2.0)}.reduce(0, combine: {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
}
