//
//  UserCreateRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class UserCreateRequest: UnprotectedAPIRequest {

    let email: String
    let password: String
    
    required init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func request() -> NSURLRequest? {
        
        let relativePath = "/authentication/users"
        let method = HTTPMethod.POST
        let body = [
            "email": email,
            "password": password
        ]
        
        return request(relativePath, parameters: nil, method: method, body: body)
    }
}
