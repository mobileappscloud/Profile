//
//  UserRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/4/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct UserRequest {}

extension UserRequest: APIRequest {
    
    static func request(userId: String, completion: APIRequestAuthenticatorCompletion) {
        let relativePath = "/user/users/\(userId)"
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
