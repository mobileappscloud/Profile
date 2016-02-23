//
//  CPTXYPlotSpace+Utility.swift
//  higi
//
//  Created by Remy Panicker on 2/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension CPTXYPlotSpace {
    
    func configure(points: [GraphPoint], maxY: Double, minY: Double, delegate: CPTPlotSpaceDelegate) {
        var firstPoint: GraphPoint
        var lastPoint: GraphPoint
        
        if (points.count > 0) {
            firstPoint = points[points.count - 1]
            lastPoint = points[0]
        } else {
            firstPoint = GraphPoint(x: 0, y: 0)
            lastPoint = GraphPoint(x: 0, y: 0)
        }
        let tickInterval = 10.0
        
        let yRange = maxY - minY > 0 ? maxY - minY : tickInterval
        let lowerBound = Utility.roundToLowest(minY - (yRange * 0.4), roundTo: tickInterval)
        
        var distance = Utility.roundToHighest(yRange * 1.8, roundTo: tickInterval)
        if lowerBound + distance < maxY {
            distance = maxY - lowerBound + tickInterval
        }
        var visibleMin = firstPoint
        if (points.count > 12) {
            visibleMin = points[12]
        }
        var marginX:Double = (lastPoint.x - visibleMin.x) * 0.1
        if (marginX == 0) {
            marginX = 2 * 86400 // x days
        }
        
        self.xRange = CPTPlotRange(location_: visibleMin.x - marginX, length: lastPoint.x - visibleMin.x + marginX * 2)
        self.yRange = CPTPlotRange(location_: lowerBound, length: distance)
        self.globalXRange = CPTPlotRange(location_: firstPoint.x - marginX, length: lastPoint.x - firstPoint.x + marginX * 2)
        self.globalYRange = self.yRange
        
        self.delegate = delegate
        self.allowsUserInteraction = true
    }
    
    
}
