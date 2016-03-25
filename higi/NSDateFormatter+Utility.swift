//
//  NSDateFormatter+Utility.swift
//  higi
//
//  Created by Remy Panicker on 3/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    
    /**
     Returns a static date formatter.
     
     Specifies a `Medium` style, typically with abbreviated text, such as “Nov 23, 1937” or “3:30:32 PM”.
     */
    @nonobjc static var mediumStyleDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        return formatter
    }()
    
    /**
     Returns a static date formatter.
     
     Specifies a `Long` style, typically with full text, such as “November 23, 1937” or “3:30:32 PM PST”.
     */
    @nonobjc static var longStyleDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        return formatter
    }()
}

extension NSDateFormatter {
    
    /// Date formatter for higi activity date.
    @nonobjc static var activityDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSLocalizedString("DATE_FORMATTER_ACTIVITY_DATE_FORMAT", comment: "Date format for higi activities.")
        return formatter
    }()
}

extension NSDateFormatter {
    
    /// Date formatter which can handle higi check-in dates for display.
    @nonobjc static var checkinDisplayDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSLocalizedString("DATE_FORMATTER_CHECKIN_DISPLAY_DATE_FORMAT", comment: "Date format for displaying check-in dates.")
        return formatter
    }()
}
