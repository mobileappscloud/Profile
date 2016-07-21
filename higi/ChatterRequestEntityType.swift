//
//  ChatterRequestEntityType.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChatterRequest {
    
    enum EntityType: Int {
        case Achievement = 1
        case Challenge
        case Comment
        case Reward
        case FeedPost
        case Community
        
        static var mapping: [String : EntityType] = [
            "Acheivement" : .Achievement,
            "Challenge" : .Challenge,
            "Comment" : .Comment,
            "Reward" : .Reward,
            "Post" : .FeedPost,
            "Community" : .Community
        ]
    }
}
