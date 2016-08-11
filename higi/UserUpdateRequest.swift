//
//  UserUpdateRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserUpdateRequest: ProtectedAPIRequest {

    let user: User
    let parameters: NSDictionary
    
    required init(user: User, parameters: NSDictionary) {
        self.user = user
        self.parameters = parameters
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        guard let userDictionary = user.JSONDictionary().mutableCopy() as? NSMutableDictionary else {
            completion(request: nil, error: nil)
            return
        }
        
        for key in parameters.allKeys {
            guard let key = key as? String else { continue }
            userDictionary[key] = parameters[key]
        }
        guard let body = userDictionary.copy() as? NSDictionary else {
            completion(request: nil, error: nil)
            return
        }
        
        let relativePath = "/user/users/\(user.identifier)"
        let method = HTTPMethod.PUT
        
        authenticatedRequest(relativePath, parameters: nil, method: method, body: body, completion: completion)
    }
}
