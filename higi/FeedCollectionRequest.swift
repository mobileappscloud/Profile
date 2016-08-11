//
//  FeedCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class FeedCollectionRequest: ProtectedAPIRequest {

    let entity: Post.Entity
    let entityId: String
    var forceRefresh: Bool
    var pageNumber: Int
    var pageSize: Int
    
    required init(entity: Post.Entity, entityId: String, forceRefresh: Bool = true, pageNumber: Int = 1, pageSize: Int = 15) {
        self.entity = entity
        self.entityId = entityId

        self.forceRefresh = forceRefresh
        self.pageNumber = pageNumber
        self.pageSize = pageSize
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
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
    
    private func request(relativePath relativePath: String, forceRefresh: Bool, pageNumber: Int, pageSize: Int, completion: APIRequestAuthenticatorCompletion) {
        
        let parameters = [
            "pageNumber" : String(pageNumber),
            "pageSize" : String(pageSize),
            "forceRefresh" : String(forceRefresh)
        ]
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
