//
//  ChallengeRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeRequest: ProtectedAPIRequest, ChallengeRequestConfigurable {

    let challenge: HigiChallenge
    let userId: String
    let gravityBoard: Int
    let participants: Int
    let comments: Int
    let teamComments: Int
    
    required init(challenge: HigiChallenge, userId: String, gravityBoard: Int, participants: Int, comments: Int, teamComments: Int) {
        self.challenge = challenge
        self.userId = userId
        self.gravityBoard = gravityBoard
        self.participants = participants
        self.comments = comments
        self.teamComments = teamComments
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/challenge/challenges/\(challenge.identifier)"
        
        let includes = "[gravityboard]=\(gravityBoard),[participants]=\(participants),[comments]=\(comments),[teams.comments]=\(teamComments)"
        let parameters = ["includes" : includes]
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}

protocol ChallengeRequestConfigurable: HigiAPI2 {
    
    var userId: String { get }
    var gravityBoard: Int { get }
    var participants: Int { get }
    var comments: Int { get }
    var teamComments: Int { get }
}
