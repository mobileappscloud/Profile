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
    let filters: [Filter]?
    
    private var filtersFormatted: String? {
        guard let filters = filters else { return nil }
        return filters.map{"[]=\($0)"}.joinWithSeparator(",")
    }
    
    required init(userId: String, gravityBoard: Int, participants: Int, comments: Int, teamComments: Int, filters: [Filter]?) {
        self.userId = userId
        self.gravityBoard = gravityBoard
        self.participants = participants
        self.comments = comments
        self.teamComments = teamComments
        self.filters = filters
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/challenge/user/\(userId)/challenges"
        
        let includes = "[gravityboard]=\(gravityBoard),[participants]=\(participants),[comments]=\(comments),[teams.comments]=\(teamComments)"
        let pageSize = 0
        var parameters = [
            "includes" : includes,
            "pageSize" : "\(pageSize)"
        ]
        
        if let filtersFormatted = filtersFormatted {
            parameters["filters"] = filtersFormatted
        }
        
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}

extension ChallengeCollectionRequest {
    enum Filter: APIString {
        case `public`
        case invited
        case upcoming
        case current
        case finished
    }
}