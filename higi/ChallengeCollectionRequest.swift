//
//  ChallengeCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/16/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeCollectionRequest: ProtectedAPIRequest, ChallengeRequestConfigurable {

    let userId: String
    let gravityBoard: Int
    let participants: Int
    let comments: Int
    let teamComments: Int
    
    required init(userId: String, gravityBoard: Int, participants: Int, comments: Int, teamComments: Int) {
        self.userId = userId
        self.gravityBoard = gravityBoard
        self.participants = participants
        self.comments = comments
        self.teamComments = teamComments
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/challenge/user/\(userId)/challenges"
        
        let includes = "[gravityboard]=\(gravityBoard),[participants]=\(participants),[comments]=\(comments),[teams.comments]=\(teamComments)"
        let pageSize = 0
        let parameters = [
            "includes" : includes,
            "pageSize" : "\(pageSize)"
        ]
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
