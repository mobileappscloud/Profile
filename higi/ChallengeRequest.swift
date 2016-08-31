//
//  ChallengeRequest.swift
//  higi
//
//  Created by Remy Panicker on 6/3/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeRequest: ProtectedAPIRequest, ChallengeRequestConfigurable {

    let challenge: Challenge
    let gravityBoard: Int
    let participants: Int
    let comments: Int
    let teamComments: Int
    
    required init(challenge: Challenge, gravityBoard: Int, participants: Int, comments: Int, teamComments: Int) {
        self.challenge = challenge
        self.gravityBoard = gravityBoard
        self.participants = participants
        self.comments = comments
        self.teamComments = teamComments
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/challenge/challenges/\(challenge.identifier)"
        
        let parameters = ["includes" : includes]
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}

protocol ChallengeRequestConfigurable: HigiAPI2 {
    var gravityBoard: Int { get }
    var participants: Int { get }
    var comments: Int { get }
    var teamComments: Int { get }
    var includes: String { get }
}

extension ChallengeRequestConfigurable {
    /// Outputs a string like "[gravityboard]=1,[participants]=50,[comments]=50,[teams.comments]=10,[community]=0"
    var includes: String {
        let includesMapping = [
            ("gravityboard", gravityBoard),
            ("participants", participants),
            ("comments", comments),
            ("teams.comments", teamComments),
            ("community", 0)
        ]
        let includesMappingPieces = includesMapping.map { (includesPiece) -> String in
            return "[\(includesPiece.0)]=\(includesPiece.1)"
        }
        return includesMappingPieces.joinWithSeparator(",")
    }
}
