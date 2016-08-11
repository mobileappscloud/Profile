//
//  UserRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserRequest: ProtectedAPIRequest {
    
    let userId: String
    
    required init(userId: String) {
        self.userId = userId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        let relativePath = "/user/users/\(userId)"
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
