//
//  TokenRevokeRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct TokenRevokeRequest {}

extension TokenRevokeRequest: HigiAPIRequest {
    
    static func request(completion: HigiAPIRequestAuthenticatorCompletion) {
        
        guard let authorization = HigiAPIClient.authorization where authorization.accessToken.isExpired(),
            let userId = authorization.accessToken.subject() else {
            completion(request: nil, error: nil)
            return
        }
        
        let clientId = HigiAPIClient.clientId
        
        let relativePath = "/authentication/users/\(userId)/clients/\(clientId)/refreshToken"
        let method = HTTPMethod.DELETE
        
        authenticatedRequest(relativePath, parameters: nil, method: method, refreshThreshold: 0.0, completion: completion)
    }
}
