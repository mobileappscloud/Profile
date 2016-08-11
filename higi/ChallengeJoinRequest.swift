//
//  ChallengeJoinRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeJoinRequest: ProtectedAPIRequest {

    let joinURL: NSURL
    let user: User
    
    required init(joinURL: NSURL, user: User) {
        self.joinURL = joinURL
        self.user = user
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let method = HTTPMethod.POST
        let body = ["userId" : user.identifier]
        
        authenticatedRequest(joinURL, parameters: nil, method: method, body: body, completion: completion)
    }
}
