//
//  ChallengeCollectionRequest.swift
//  higi
//
//  Created by Remy Panicker on 5/16/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeCollectionRequest: ProtectedAPIRequest, ChallengeRequestConfigurable {

    private let entityType: EntityType
    private let entityId: String
    private let filters: [Filter]?
    private let pageSize: Int
    
    let gravityBoard: Int
    let participants: Int
    let comments: Int
    let teamComments: Int
    let winConditionWinners: Int
    
    private var filtersFormatted: String? {
        guard let filters = filters else { return nil }
        return filters.map{"[]=\($0)"}.joinWithSeparator(",")
    }
    
    required init(entityType: EntityType, entityId: String, gravityBoard: Int, participants: Int, comments: Int, teamComments: Int, winConditionWinners: Int, filters: [Filter]? = nil, pageSize: Int = 0) {
        self.entityType = entityType
        self.entityId = entityId
        self.gravityBoard = gravityBoard
        self.participants = participants
        self.comments = comments
        self.teamComments = teamComments
        self.winConditionWinners = winConditionWinners
        self.filters = filters
        self.pageSize = pageSize
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        
        let relativePath = "/challenge/\(entityType)/\(entityId)/challenges"
        
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
    
    enum EntityType: APIString {
        case user
        case communities
    }
}