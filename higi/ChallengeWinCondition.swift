//
//  ChallengeWinConditions.swift
//  higi
//
//  Created by Dan Harms on 11/4/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChallengeWinCondition {
    
    struct Goal {
        
        var type: NSString!;
        
        var place, minThreshold, maxThreshold: Int!;
    }
    
    var name, description, tieHandling, winnerType, prizeName, prizeImageUrl: NSString!;
    
    var winnersCount, displayOrder: Int!;
    
    var goal: Goal!;
    
    
    init(dictionary: NSDictionary) {
        displayOrder = dictionary["displayOrder"] as! Int;
        name = dictionary["name"] as! NSString;
        description = dictionary["description"] as! NSString;
        winnersCount = dictionary["winnersCount"] as! Int;
        winnerType = dictionary["winnerType"] as! NSString;
        
        let goalObject = dictionary["goal"] as! NSDictionary;
        goal = Goal(type: goalObject["type"] as! NSString, place: (goalObject["place"] ?? 0) as! Int, minThreshold: (goalObject["min_threshold"] ?? 0) as! Int, maxThreshold: (goalObject["max_threshold"] ?? 0) as! Int);
        
        let prizeObject = dictionary["prize"] as! NSDictionary?;
        if (prizeObject != nil) {
            prizeName = prizeObject!["name"] as! NSString;
            prizeImageUrl = prizeObject!["imageUrl"] as? NSString!;
        }
    }
    
}