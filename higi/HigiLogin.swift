//
//  HigiLogin.swift
//  higi
//
//  Created by Dan Harms on 6/17/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

final class HigiLogin {
    
    var token: NSString;
    
    var user: HigiUser?;
    
    init(dictionary: NSDictionary) {
        token = (dictionary["Token"] ?? "") as! NSString;
        user = HigiUser(dictionary: dictionary["User"] as! NSDictionary);
    }
    
}