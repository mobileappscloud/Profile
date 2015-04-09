//
//  HigiActivity.swift
//  higi
//
//  Created by Dan Harms on 11/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class HigiActivity {
    
    var points: Int!;
    
    var description, errorDescription: NSString!;
    
    var device: ActivityDevice!;
    
    var startTime: NSDate!;
    
    var type: ActivityType!;
    
    init(dictionary: NSDictionary, type: ActivityType) {
        points = dictionary["points"] as Int;
        description = dictionary["description"] as NSString;
        var serverDevice = dictionary["device"] as NSDictionary?;
        if (serverDevice != nil) {
            device = ActivityDevice(dictionary: serverDevice!);
        }
        var formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        var dateString = dictionary["startTime"] as NSString;
        var time = formatter.dateFromString(dateString);
        startTime = formatter.dateFromString(dictionary["startTime"] as NSString);
        self.type = type;
        var error = dictionary["error"] as? NSDictionary;
        if (error != nil) {
            errorDescription = error!["description"] as NSString;
        }
    }
    
}

struct ActivityType {
    var category: NSString!;
    var checkinCategory: NSString?;
    var name: NSString!;
}