//
//  ActivityDevice.swift
//  higi
//
//  Created by Dan Harms on 11/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ActivityDevice {
    
    var name, description, url, connectUrl, partnerHomepage, iconUrl, colorCode: NSString!;
    
    var enabled: Bool!;
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as NSString;
        description = dictionary["description"] as NSString;
        url = dictionary["url"] as NSString;
        connectUrl = dictionary["connectUrl"] as? NSString;
        partnerHomepage = dictionary["partnerHomepage"] as? NSString;
        colorCode = dictionary["colorCode"] as NSString;
        enabled = dictionary["enabled"] as Bool;
        var imageUrls = dictionary["imageUrls"] as NSDictionary;
        iconUrl = imageUrls["icon"] as? NSString;
    }
    
}