//
//  ChatterUnlikeRequest.swift
//  higi
//
//  Created by Remy Panicker on 8/2/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChatterUnlikeRequest: ProtectedAPIRequest {

    let entityType: ChatterRequest.EntityType
    let entityId: String
    
    required init(entityType: ChatterRequest.EntityType, entityId: String) {
        self.entityType = entityType
        self.entityId = entityId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let entityPath = entityType.urlComponent()
        let relativePath = "/chatter/\(entityPath)/\(entityId)/like/"
        let method = HTTPMethod.DELETE
        
        authenticatedRequest(relativePath, parameters: nil, method: method, completion: completion)
    }
}
