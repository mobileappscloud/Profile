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
    
    /**
     Date formatter for parsing dates in the following [ISO 8601](http://www.iso.org/iso/home/standards/iso8601.htm) compatible format:
     
     - seealso [Unicode Technical Standard](http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns)
     
     _yyyy-MM-dd'T'HH:mm:ss.SSSZ_
     */
    @nonobjc static var ISO8601DateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()  
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
}

extension NSDateFormatter {
    
    /// Date formatter for parsing dates in the format yyyy-MM-dd.
    @nonobjc static var yyyyMMddDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// MARK: - For Challenge cards
extension NSDateFormatter {
    
    @nonobjc static var challengeCardStartDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSLocalizedString("DATE_FORMATTER_CHALLENGE_CARD_START_DATE_FORMAT", comment: "Date format for displaying the start date of a challenge.")
        return formatter
    }()

    @nonobjc static var challengeCardEndDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSLocalizedString("DATE_FORMATTER_CHALLENGE_CARD_END_DATE_FORMAT", comment: "Date format for displaying the end date of a challenge.")
        return formatter
    }()

    @nonobjc static var challengeCardEndDateNoMonthFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSLocalizedString("DATE_FORMATTER_CHALLENGE_CARD_END_DATE_NO_MONTH_FORMAT", comment: "Date format for displaying the end date of a challenge, omitting the month.")
        return formatter
    }()

}