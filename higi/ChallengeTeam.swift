//
//  ChallengeTeam.swift
//  higi
//
//  Created by Dan Harms on 11/14/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChallengeTeam {
    
    var name, imageUrl: NSString!;
    
    var memberCount: Int!;
    
    var units: Double!;
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as NSString;
        memberCount = dictionary["membersCount"] as Int;
        units = dictionary["units"] as Double;
        var imageUrls = dictionary["imageUrl"] as NSDictionary;
        imageUrl = imageUrls["default"] as NSString;
    }
    
}