//
//  HigiCheckin.swift
//  higi
//
//  Created by Dan Harms on 6/17/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class HigiCheckin {
    
    var checkinId, sourceVendorId, sourceType, sourceId, bmiClass, fatClass, bpClass, mapClass, pulseClass: NSString?;
    
    var weightKG, heightMeters, heightInches, bmi, map, fatRatio, weightLbs: Double?;
    
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
        if (heightMeters != nil) {
            heightInches = heightMeters! * 39.3701;
        }
        bmi = dictionary["bmi"] as? Double;
        fatRatio = dictionary["fatRatio"] as? Double;
        fatClass = dictionary["fatClass"] as? NSString;
        systolic = dictionary["systolic"] as? Int;
        diastolic = dictionary["diastolic"] as? Int;
        score = dictionary["score"] as? Int;
        pulseBpm = dictionary["pulseBpm"] as? Int;
        var date = dictionary["dateTime"] as? NSString;
        date = date!.substringWithRange(NSRange(location: 6, length: date!.length - 8));
        dateTime = NSDate(timeIntervalSince1970: date!.doubleValue / 1000);
        if (systolic != nil) {
            map = (Double(diastolic!) * 2.0 + Double(systolic!)) / 3.0;
            //mapClass = convertClass(mapClass);	TODO uncomment when implemented on API
            if (map < 70) {
                mapClass = "Low";
            } else if (map < 110) {
                mapClass = "Normal";
            } else {
                mapClass = "High";
            }
        }
        if (weightKG != nil) {
            weightLbs = weightKG! * 2.20462;
        }
        bpClass = convertClass(bpClass);
        bmiClass = convertClass(bmiClass);
        pulseClass = convertClass(pulseClass);
        fatClass = convertClass(fatClass);
        mapClass = convertClass(mapClass);
        let infoDict: NSDictionary? = dictionary["kioskInfo"] as? NSDictionary;
        if (infoDict != nil) {
            kioskInfo = KioskInfo(dictionary: infoDict!);
        }
        
        if (bpClass != nil && pulseClass == nil) {
            pulseBpm = 0;
            pulseClass = "";
        }
        
    }
    
    // TODO: Convert to enum
    func convertClass(MetricClass: NSString?) -> NSString? {
        var retVal: NSString;
        if (MetricClass != nil) {
            switch (MetricClass!) {
            case "normal":
                retVal = "Normal";
            case "low":
                retVal = "Low";
            case "high":
                retVal = "High";
            case "atrisk":
                retVal = "At risk";
            case "underweight":
                retVal = "Underweight";
            case "overweight":
                retVal = "Overweight";
            case "obese":
                retVal = "Obese";
            case "acceptable":
                retVal = "Acceptable";
            case "healthy":
                retVal = "Healthy";
            default:
                retVal = MetricClass!;
            }
            return retVal;
        } else {
            return nil;
        }
    }
    
}
