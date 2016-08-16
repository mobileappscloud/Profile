//
//  NSDateFormatter+Utility.swift
//  higi
//
//  Created by Remy Panicker on 3/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension NSDateFormatter {
    
    // http://userguide.icu-project.org/formatparse/datetime
    
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

extension NSDateFormatter {
    
    /// Date formatter for parsing dates in the format MM/dd/yyyy.
    @nonobjc static var MMddyyyyDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
}

extension NSDateFormatter {
    
    /**
     Date formatter for parsing dates in the following [ISO 8601](http://www.iso.org/iso/home/standards/iso8601.htm) compatible format:
     
     _yyyy-MM-dd'T'HH:mm:ss.fffK_
     */
    @nonobjc static var ISO8601DateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()  
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.fffK"
        return formatter
    }()
}

extension NSDateFormatter {
    
    /// Date formatter for parsing dates in the format YYYY-MM-dd.
    @nonobjc static var YYYYMMddDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
}
