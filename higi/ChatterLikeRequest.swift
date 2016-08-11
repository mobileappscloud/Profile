//
//  ChatterLikeRequest.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChatterLikeRequest: ProtectedAPIRequest {

    let userId: String
    let entityType: ChatterRequest.EntityType
    let entityId: String
    
    required init(userId: String, entityType: ChatterRequest.EntityType, entityId: String) {
        self.userId = userId
        self.entityType = entityType
        self.entityId = entityId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/chatter/likes/"
        let method = HTTPMethod.POST
        let body = [
            "userId" : userId,
            "entityType" : entityType.string(),
            "entityId" : entityId
        ]
        
        authenticatedRequest(relativePath, parameters: nil, method: method, body: body, completion: completion)
    }
}
