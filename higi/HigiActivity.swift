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
    
    var startTime: NSDate!, utcStartTime: NSDate!;
    
    var distance: Double!, offset: Double = 0.0;
    
    var healthChecks: [String] = [];
    
    var type: ActivityCategory!;
    
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
        let typeObject = dictionary["type"] as! NSDictionary;
        typeCategory = typeObject["category"] as? NSString;
        checkinCategory = typeObject["checkinCategory"] as? NSString;
        category = typeObject["category"] as? NSString;
        typeName = typeObject["name"] as? NSString;
        
        if (category == "checkin") {
            if (healthChecks.count > 0) {
                type = ActivityCategory.Health;
            } else {
                type = ActivityCategory.Lifestyle;
            }
        } else {
            type = ActivityCategory.Fitness;
        }

        if let error = dictionary["error"] as? NSDictionary {
            errorDescription = error["description"] as! NSString;
        }
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let dateString = dictionary["startTime"] as! String;
        var time = formatter.dateFromString(dateString);
        startTime = formatter.dateFromString(dictionary["startTime"] as! String);
        if let serverOffset = dictionary["timezoneOffset"] as? String {
            if let timezoneOffset = Int(serverOffset) {
                if timezoneOffset != 0 {
                    offset = Double(NSTimeZone.localTimeZone().secondsFromGMTForDate(startTime));
                    offset -= Double(timezoneOffset * 60);
                    utcStartTime = NSDate(timeIntervalSince1970: startTime.timeIntervalSince1970 + offset);
                }
            }
            // must set category and health checks before determining type/category
        } else if type == ActivityCategory.Health {
            offset = Double(NSTimeZone.localTimeZone().secondsFromGMT);
            utcStartTime = NSDate(timeIntervalSince1970: startTime.timeIntervalSince1970 + Double(NSTimeZone.localTimeZone().secondsFromGMT));
        }
    }
}