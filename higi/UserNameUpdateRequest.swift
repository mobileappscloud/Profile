//
//  UserNameUpdateRequest.swift
//  higi
//
//  Created by Remy Panicker on 8/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserNameUpdateRequest: ProtectedAPIRequest {
    
    let user: User
    let firstName: String
    let lastName: String
    
    required init(user: User, firstName: String, lastName: String) {
        self.user = user
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let parameters = NSMutableDictionary()
        parameters["firstName"] = firstName
        parameters["lastName"] = lastName
        
        UserUpdateRequest(user: user, parameters: parameters).request(completion)
    }
}
