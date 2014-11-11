//
//  HigiCheckin.swift
//  higi
//
//  Created by Dan Harms on 6/17/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class HigiCheckin {
    
    var checkinId, sourceVendorId, sourceType, sourceId, bmiClass, bpClass, pulseClass: NSString?;
    
    var weightKG, heightMeters, bmi, map, weightLbs: Double?;
    
    var systolic, diastolic, score, pulseBpm: Int?;
    
    var dateTime: NSDate;
    
    var kioskInfo: KioskInfo?;
    
    var prevBpCheckin, prevBmiCheckin: HigiCheckin?;
    
    init(dictionary: NSDictionary) {
        checkinId = dictionary["id"] as? NSString;
        sourceVendorId = (dictionary["sourceVendorID"] ?? "") as? NSString;
        sourceType = dictionary["sourceType"] as? NSString;
        sourceId = dictionary["sourceId"] as? NSString;
        bmiClass = dictionary["bmiClass"] as? NSString;
        bpClass = dictionary["bpClass"] as? NSString;
        pulseClass = dictionary["pulseClass"] as? NSString;
        weightKG = dictionary["weightKG"] as? Double;
        heightMeters = dictionary["heightMeters"] as? Double;
        bmi = dictionary["bmi"] as? Double;
        systolic = dictionary["systolic"] as? Int;
        diastolic = dictionary["diastolic"] as? Int;
        score = dictionary["score"] as? Int;
        pulseBpm = dictionary["pulseBpm"] as? Int;
        var date = dictionary["dateTime"] as? NSString;
        date = date!.substringWithRange(NSRange(location: 6, length: date!.length - 8));
        dateTime = NSDate(timeIntervalSince1970: date!.doubleValue / 1000);
        if (systolic != nil) {
            map = (Double(diastolic!) * 2.0 + Double(systolic!)) / 3.0;
        }
        if (weightKG != nil) {
            weightLbs = weightKG! * 2.20462;
        }
        bpClass = convertClass(bpClass);
        bmiClass = convertClass(bmiClass);
        pulseClass = convertClass(pulseClass);
        
        var infoDict: NSDictionary? = dictionary["kioskInfo"] as? NSDictionary;
        if (infoDict != nil) {
            kioskInfo = KioskInfo(dictionary: infoDict!);
        }
        
        if (bpClass != nil && pulseClass == nil) {
            pulseBpm = 0;
            pulseClass = "";
        }
        
    }
    
    func convertClass(bodyStatClass: NSString?) -> NSString? {
        var retVal: NSString;
        if (bodyStatClass != nil) {
            switch (bodyStatClass!) {
            case "normal":
                retVal = "Normal";
            case "low":
                retVal = "Low";
            case "high":
                retVal = "High";
            case "atrisk":
                retVal = "At Risk";
            case "underweight":
                retVal = "Underweight";
            case "overweight":
                retVal = "Overweight";
            case "obese":
                retVal = "Obese";
            default:
                retVal = bodyStatClass!;
            }
            return retVal;
        } else {
            return nil;
        }
    }
    
}
