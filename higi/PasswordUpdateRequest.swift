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
        
        authenticatedRequest(relativePath, parameters: nil, method: method, completion: { (request, error) in
            
            if let mutableRequest = request?.mutableCopy() as? NSMutableURLRequest {
                do {
                    let JSONBody = [
                        "oldpassword" : currentPassword,
                        "newpassword" : newPassword
                    ] as NSDictionary
                    mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(JSONBody, options: [])
                    mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let fullRequest = mutableRequest.copy() as! NSURLRequest
                    completion(request: fullRequest, error: nil)
                } catch {
                    completion(request: nil, error: nil)
                }
            } else {
                completion(request: nil, error: error)
            }
        })
    }
}
