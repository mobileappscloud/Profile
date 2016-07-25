//
//  ChallengeCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/16/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct ChallengeCollectionRequest {}

extension ChallengeCollectionRequest: APIRequest {
    
    static func request(user: User, gravityBoard: Int, participants: Int, comments: Int, teamComments: Int, completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/challenge/user/\(user.identifier)/challenges"
        
        let includes = "[gravityboard]=\(gravityBoard),[participants]=\(participants),[comments]=\(comments),[teams.comments]=\(teamComments)"
        let pageSize = 0
        let parameters = [
            "includes" : includes,
            "pageSize" : "\(pageSize)"
        ]
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
