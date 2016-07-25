//
//  ChatterCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 7/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChatterCollectionRequest {}

extension ChatterCollectionRequest: APIRequest {
    
    static func request(entity: ChatterMessage.Entity, completion: APIRequestAuthenticatorCompletion) {
        
        let entityType: String
        switch entity.type {
        case .Achievement:
            entityType = "achievements"
        case .Challenge:
            entityType = "challenges"
        case .Comment:
            entityType = "comments"
        case .Reward:
            entityType = "rewards"
        case .FeedPost:
            entityType = "posts"
        case .Community:
            entityType = "communities"
        }
        
        let relativePath = "/chatter/\(entityType)/\(entity.identifier)/comments"
        
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
