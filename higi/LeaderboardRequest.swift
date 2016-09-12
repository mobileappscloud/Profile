//
//  LeaderboardRequest.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class LeaderboardRequest: ProtectedAPIRequest {
    let leaderboardId: String
    
    required init(leaderboardId: String) {
        self.leaderboardId = leaderboardId
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        let relativePath = "/leaderboard/leaderboards/\(leaderboardId)"
        let parameters = [:] as [String: String]
        authenticatedRequest(relativePath, parameters: parameters, completion: completion)
    }
}
