//
//  ChallengeJoinRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChallengeJoinRequest {}

extension ChallengeJoinRequest: APIRequest {

    static func request(joinURL URL: NSURL, user: User, completion: APIRequestAuthenticatorCompletion) {
        
        let method = HTTPMethod.POST
        let body = ["userId" : user.identifier]
        
        authenticatedRequest(URL, parameters: nil, method: method, body: body, completion: completion)
    }
}
