//
//  ChallengeParticipant.swift
//  higi
//
//  Created by Dan Harms on 11/14/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChallengeParticipant {
    
    var displayName, imageUrl: NSString!;
    
    var identifier: String!
    
    var units: Double!;
    
    var team: ChallengeTeam!;
    
    init?(dictionary: NSDictionary) {
        let userObject = dictionary["userPublic"] as! NSDictionary;
        guard let identifier = userObject["id"] as? String else {
            return nil
        }
        self.identifier = identifier
        
        if let teamObject = dictionary["team"] as? NSDictionary {
            team = ChallengeTeam(dictionary: teamObject)
        }
        
        displayName = userObject["displayName"] as! NSString;
        units = (dictionary["units"] ?? 0) as! Double;
        let imageUrls = userObject["imageUrl"] as! NSDictionary;
        imageUrl = imageUrls["default"] as! NSString;
    }
}
