//
//  PasswordUpdateRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class PasswordUpdateRequest: ProtectedAPIRequest {

    let currentPassword: String
    let newPassword: String
    
    required init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        guard let authorization = APIClient.authorization where authorization.accessToken.isExpired(),
            let userId = authorization.accessToken.subject() else {
                completion(request: nil, error: nil)
                return
        }
        
        let relativePath = "/authentication/users/\(userId)/passwordChange"
        let method = HTTPMethod.POST
        let body = [
            "oldPassword" : currentPassword,
            "newPassword" : newPassword
        ]
        
        authenticatedRequest(relativePath, parameters: nil, method: method, body: body, completion: completion)
    }
}
