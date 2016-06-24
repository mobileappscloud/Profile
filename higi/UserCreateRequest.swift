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
        
        guard let mutableRequest = request(relativePath, parameters: nil, method: method)?.mutableCopy() as? NSMutableURLRequest else { return nil }
        
        mutableRequest.addValue(HTTPHeader.value.applicationJSON, forHTTPHeaderField: HTTPHeader.name.contentType)
        
        let bodyObject = [
            "email": email,
            "password": password
        ]
        do {
            mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyObject, options: [])
        } catch {
            return nil
        }
        
        return mutableRequest.copy() as? NSURLRequest
    }
}
