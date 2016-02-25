//
//  CPTMutableLineStyle+Utility.swift
//  higi
//
//  Created by Remy Panicker on 2/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension CPTMutableLineStyle {
    
    convenience init(color: UIColor, lineWidth: CGFloat) {
        self.init()
        self.lineColor = CPTColor(CGColor: color.CGColor)
        self.lineWidth = lineWidth
    }
}
