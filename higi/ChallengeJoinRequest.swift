//
//  ChallengeJoinRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeJoinRequest: ProtectedAPIRequest {

    let challenge: Challenge
    let user: User
    
    required init(challenge: Challenge, user: User) {
        self.challenge = challenge
        self.user = user
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        let method = HTTPMethod.POST
        let body = ["userId" : user.identifier]
        let relativePath = "/challenge/challenges/\(challenge.identifier)/participants"
        
        authenticatedRequest(relativePath, parameters: nil, method: method, body: body, completion: completion)
    }
}
