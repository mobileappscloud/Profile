//
//  ChallengeRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChallengeRequest {}

extension ChallengeRequest: HigiAPIRequest {
    
    static func request(challenge: HigiChallenge, user: User, gravityBoard: Int, participants: Int, comments: Int, teamComments: Int, completion: HigiAPIRequestAuthenticatorCompletion) {
        
        let relativePath = "/challenge/challenges/\(challenge.identifier)"
        
        let includes = "[gravityboard]=\(gravityBoard),[participants]=\(participants),[comments]=\(comments),[teams.comments]=\(teamComments)"
        let parameters = ["includes" : includes]
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
