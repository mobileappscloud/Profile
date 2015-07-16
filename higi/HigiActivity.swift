//
//  HigiActivity.swift
//  higi
//
//  Created by Dan Harms on 11/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class HigiActivity {
    
    var points, steps, duration, calories: Int!;
    
    var description, errorDescription, typeCategory, category, checkinCategory, typeName: NSString!;
    
    var device: ActivityDevice!;
    
    var startTime: NSDate!;
    
    var distance: Double!;
    
    var healthChecks: [String] = [];
    
    init(dictionary: NSDictionary) {
        points = dictionary["points"] as! Int;
        if let metricsObject = dictionary["metrics"] as? NSDictionary {
            steps = metricsObject["steps"] as? Int;
            distance = metricsObject["distance"] as? Double;
            calories = metricsObject["calories"] as? Int;
            duration = metricsObject["duration"] as? Int;
        }
        description = dictionary["description"] as! NSString;
        if let serverDevice = dictionary["device"] as? NSDictionary {
            device = ActivityDevice(dictionary: serverDevice);
        }
        if let checks = dictionary["healthChecks"] as? NSArray {
            if (checks.count > 0) {
                healthChecks = checks as! [String];
            }
        }
        var formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        var dateString = dictionary["startTime"] as! String;
        var time = formatter.dateFromString(dateString);
        startTime = formatter.dateFromString(dictionary["startTime"] as! String);
        if let serverOffset = dictionary["timezoneOffset"] as? String {
            if let timezoneOffset = serverOffset.toInt() {
                if timezoneOffset != 0 {
                    var offset = Double(NSTimeZone.localTimeZone().secondsFromGMTForDate(startTime));
                    offset -= Double(timezoneOffset * 60);
                    startTime = NSDate(timeIntervalSince1970: startTime.timeIntervalSince1970 + offset);
                }
            }
        }
        let typeObject = dictionary["type"] as! NSDictionary;
        typeCategory = typeObject["category"] as? NSString;
        checkinCategory = typeObject["checkinCategory"] as? NSString;
        category = typeObject["category"] as? NSString;
        typeName = typeObject["name"] as? NSString;
        if let error = dictionary["error"] as? NSDictionary {
            errorDescription = error["description"] as! NSString;
        }
    }
}