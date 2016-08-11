//
//  ChatterCommentCreateRequest.swift
//  higi
//
//  Created by Remy Panicker on 7/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChatterCommentCreateRequest: ProtectedAPIRequest {

    let text: String
    let userId: String
    let entityType: ChatterRequest.EntityType
    let entityId: String
    
    required init(text: String, userId: String, entityType: ChatterRequest.EntityType, entityId: String) {
        self.text = text
        self.userId = userId
        self.entityType = entityType
        self.entityId = entityId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/chatter/comments"
        let method = HTTPMethod.POST
        let JSONBody: [String: String] = [
            "userId" : userId,
            "entityType" : entityType.string(),
            "entityId" : entityId,
            "text" : text
        ]
        
        authenticatedRequest(relativePath, parameters: nil, method: method, body: JSONBody, completion: completion)
    }
}
