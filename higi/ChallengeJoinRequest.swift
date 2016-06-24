//
//  ChallengeJoinRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChallengeJoinRequest {}

extension ChallengeJoinRequest: HigiAPIRequest {

    static func request(joinURL URL: NSURL, user: User, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let bodyObject = ["userId" : user.identifier]
        let bodyData = try? NSJSONSerialization.dataWithJSONObject(bodyObject, options: NSJSONWritingOptions())
        
        let method = HTTPMethod.POST
        
        authenticatedRequest(URL, parameters: nil, method: method, completion: { (request, error) in
            if let request = request?.mutableCopy() as? NSMutableURLRequest {
                request.addValue(HTTPHeader.value.applicationJSON, forHTTPHeaderField: HTTPHeader.name.contentType)
                request.HTTPBody = bodyData
            }
            completion(request: request, error: error)
        })
    }
}
