//
//  ChatterRequestEntityType.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChatterRequest {
    
    enum EntityType {
        case Achievement
        case Challenge
        case Comment
        case Reward
        case Post
        case Community
    }
}

extension ChatterRequest.EntityType {
    
    func string() -> String {
        let string: String
        switch self {
        case .Achievement:
            string = "Achievement"
        case .Challenge:
            string = "Challenge"
        case .Comment:
            string = "Comment"
        case .Reward:
            string = "Reward"
        case .Post:
            string = "Post"
        case .Community:
            string = "Community"
        }
        return string
    }
}

extension ChatterRequest.EntityType {
    
    func urlComponent() -> String {
        let string: String
        switch self {
        case .Achievement:
            string = "achievements"
        case .Challenge:
            string = "challenges"
        case .Comment:
            string = "comments"
        case .Reward:
            string = "rewards"
        case .Post:
            string = "posts"
        case .Community:
            string = "communities"
        }
        return string
    }
}
