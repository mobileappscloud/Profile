//
//  ChatterCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 7/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChatterCollectionRequest: ProtectedAPIRequest {

    let entityType: ChatterRequest.EntityType
    let entityId: String
    
    required init(entityType: ChatterRequest.EntityType, entityId: String) {
        self.entityType = entityType
        self.entityId = entityId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
                
        let relativePath = "/chatter/\(entityType.urlComponent())/\(entityId)/comments"
        
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
