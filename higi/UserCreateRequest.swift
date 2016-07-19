//
//  UserCreateRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct UserCreateRequest {}

extension UserCreateRequest: HigiAPIRequest {
    
    static func request(email: String, password: String) -> NSURLRequest? {
        
        let relativePath = "/authentication/users"
        let method = HTTPMethod.POST
        let body = [
            "email": email,
            "password": password
        ]
        
        return request(relativePath, parameters: nil, method: method, body: body)
    }
}
