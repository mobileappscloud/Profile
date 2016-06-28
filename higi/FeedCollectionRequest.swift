//
//  FeedCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct FeedCollectionRequest {}

extension FeedCollectionRequest: HigiAPIRequest {
    
    static func request(entity: Post.Entity, entityId: String, forceRefresh: Bool = true, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let resource: String
        switch entity {
        case .Community:
            resource = "communities"
        case .Tag:
            resource = "tags"
        case .User: 
            resource = "users"
        }
        
        let relativePath = "/feed/\(resource)/\(entityId)/posts"
        request(relativePath: relativePath, forceRefresh: forceRefresh,completion: completion)
    }
    
    private static func request(relativePath relativePath: String, forceRefresh: Bool, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let page = 1
        let pageSize = 25
        let parameters = [
            "page" : String(page),
            "pageSize" : String(pageSize),
            "forceRefresh" : String(forceRefresh)
        ]
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
