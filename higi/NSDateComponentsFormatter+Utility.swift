//
//  NSDateComponentsFormatter+Utility.swift
//  higi
//
//  Created by Remy Panicker on 6/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension NSDateComponentsFormatter {
    
    /**
     Returns a static date formatter.
     
     Specifies an `Abbreviated` style for a single date component unit. (Ex: `1w`, `5d`, `3h`, `23s`, etc.)
     */
    @nonobjc static var abbreviatedSingleUnitFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    /**
    Returns a static date formatter.
 
    Ideal for formatting time intervals to show video duration. 
    */
    @nonobjc static var videoDurationFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = [.Pad]
        formatter.allowedUnits = [.Minute, .Second]
        return formatter
    }()
}
