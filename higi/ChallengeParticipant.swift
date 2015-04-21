//
//  ChallengeParticipant.swift
//  higi
//
//  Created by Dan Harms on 11/14/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChallengeParticipant {
    
    var displayName, imageUrl, url: NSString!;
    
    var units: Double!;
    
    var team: ChallengeTeam!;
    
    init(dictionary: NSDictionary) {
        var userObject = dictionary["userPublic"] as! NSDictionary;
        var teamObject = dictionary["team"] as? NSDictionary;
        url = dictionary["url"] as! NSString;
        if (teamObject != nil) {
            team = ChallengeTeam(dictionary: teamObject!);
        }
        displayName = userObject["displayName"] as! NSString;
        units = (dictionary["units"] ?? 0) as! Double;
        var imageUrls = userObject["imageUrl"] as! NSDictionary;
        imageUrl = imageUrls["default"] as! NSString;
    }
    
}