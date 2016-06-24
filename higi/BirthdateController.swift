//
//  BirthdateController.swift
//  higi
//
//  Created by Remy Panicker on 5/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class BirthdateController {
    
    static let minimumAge = 13
    
    func defaultDate() -> NSDate {
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: NSDate())
        components.year -= BirthdateController.minimumAge
        return components.date ?? NSDate()
    }
    
    func validateAge(birthDate: NSDate) -> Bool {
        var meetsAgeRequirement = false
        let components = NSCalendar.currentCalendar().components(.Year, fromDate: birthDate, toDate: NSDate(), options: [])
        let age = components.year
        if (age > BirthdateController.minimumAge) {
            meetsAgeRequirement = true
        }
        return meetsAgeRequirement
    }
}
