//
//  PasswordUpdateRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct PasswordUpdateRequest {}

extension PasswordUpdateRequest: HigiAPIRequest {
    
    static func request(currentPassword: String, newPassword: String, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        guard let authorization = HigiAPIClient.authorization where authorization.accessToken.isExpired(),
            let userId = authorization.accessToken.subject() else {
                completion(request: nil, error: nil)
                return
        }
        
        let relativePath = "/authentication/users/\(userId)/passwordchange"
        let method = HTTPMethod.POST
        let body = [
            "oldpassword" : currentPassword,
            "newpassword" : newPassword
        ]
        
        authenticatedRequest(relativePath, parameters: nil, method: method, body: body, completion: completion)
    }
}
