//
//  GraphPoint.swift
//  higi
//
//  Created by Dan Harms on 10/28/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

struct GraphPoint {
    
    // This property was added as a shortcut to help identify the source of a graph point (activity/checkin).
    var identifier: String?
    
    var x: Double
    var y: Double
    
    init(x: Double, y: Double) {
        self.init(identifier: nil, x: x, y: y)
    }
    
    init(identifier: String?, x: Double, y: Double) {
        self.identifier = identifier
        self.x = x
        self.y = y
    }
    
    init(identifier: NSString?, x: Double, y: Double) {
        let identifier = identifier as? String ?? nil
        self.identifier = identifier
        self.x = x
        self.y = y
    }
}
