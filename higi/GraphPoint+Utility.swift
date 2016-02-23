//
//  GraphPoint+Utility.swift
//  higi
//
//  Created by Remy Panicker on 2/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

extension GraphPoint {
    
    static func maxY(pointsCollections: [[GraphPoint]]) -> Double {
        var allPoints: [GraphPoint] = []
        for pointsCollection in pointsCollections {
            allPoints.appendContentsOf(pointsCollection)
        }
        
        var maxY = 0.0
        
        let pointsY = allPoints.flatMap{$0.y}
        maxY = pointsY.maxElement() ?? maxY
        
        return maxY
    }
    
    static func minY(pointsCollections: [[GraphPoint]]) -> Double {
        var allPoints: [GraphPoint] = []
        for pointsCollection in pointsCollections {
            allPoints.appendContentsOf(pointsCollection)
        }
        
        var minY = 0.0
        
        let pointsY = allPoints.flatMap{$0.y}
        minY = pointsY.minElement() ?? minY
        
        return minY
    }
}