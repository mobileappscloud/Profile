//
//  KioskInfo.swift
//  higi
//
//  Created by Dan Harms on 6/17/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class KioskInfo: Equatable {
    
    var organizations: [NSString];
    
    var kioskId: Int?;
    
    var address1, address2, city, state, zip, type, fullAddress, cityStateZip, group: NSString!;
    
    var latitude, longitude: Double?;
    
    var isMapVisible = false;
    
    var position: CLLocationCoordinate2D?;
    
    var hours: NSDictionary?;
    
    init(dictionary: NSDictionary) {
        kioskId = dictionary["KioskId"] as? Int;
        if (dictionary["Organizations"] != nil) {
            organizations = dictionary["Organizations"] as [NSString];
            organizations[0] = organizations[0].stringByConvertingHTMLToPlainText();
        } else {
            organizations = [""];
        }
        address1 = (dictionary["Address1"] ?? "") as NSString;
        address2 = (dictionary["Address2"] ?? "") as NSString;
        city = (dictionary["City"] ?? "") as NSString;
        state = (dictionary["State"] ?? "") as NSString;
        zip = (dictionary["Zip"] ?? "") as NSString;
        isMapVisible = (dictionary["MapVisible"] as? NSString) == "true";
        group =  (dictionary["Groups"] ?? "") as NSString;
        fullAddress = address1;
        if (address2 != nil && address2!.length > 0) {
            fullAddress = "\(fullAddress), \(address2)";
        }
        fullAddress = "\(fullAddress), \(city), \(state) \(zip)";
        
        cityStateZip = "\(city), \(state) \(zip)";
        
        var gps = dictionary["GPS"] as? NSDictionary;
        if (gps != nil) {
            latitude = gps!["Latitude"] as? Double;
            longitude = gps!["Longitude"] as? Double;
            position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!);
        }
        
        var hoursString = dictionary["Hours"] as? NSString;
        if (hoursString != nil && hoursString! != "") {
            hoursString = hoursString?.stringByReplacingOccurrencesOfString("&quot;", withString: "\"").stringByReplacingOccurrencesOfString("-", withString: " - ", options: nil, range: nil);
            hours = NSJSONSerialization.JSONObjectWithData(hoursString!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers, error: NSErrorPointer.null()) as? NSDictionary;
        }
    }
    
}

func == (lhs: KioskInfo, rhs: KioskInfo) -> Bool {
    return lhs.kioskId == rhs.kioskId;
}