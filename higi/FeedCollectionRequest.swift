//
//  FeedCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct FeedCollectionRequest {}

extension FeedCollectionRequest: APIRequest {
    
    static func request(entity: Post.Entity, entityId: String, forceRefresh: Bool = true, pageNumber: Int = 1, pageSize: Int = 15, completion: APIRequestAuthenticatorCompletion) {
        
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
        request(relativePath: relativePath, forceRefresh: forceRefresh, pageNumber: pageNumber, pageSize: pageSize, completion: completion)
    }
    
    private static func request(relativePath relativePath: String, forceRefresh: Bool, pageNumber: Int, pageSize: Int, completion: APIRequestAuthenticatorCompletion) {
        
        let parameters = [
            "pageNumber" : String(pageNumber),
            "pageSize" : String(pageSize),
            "forceRefresh" : String(forceRefresh)
        ]
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
