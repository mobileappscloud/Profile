//
//  LeaderboardNetworkController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct LeaderboardNetworkController { }

// MARK: - Subscriptions
extension LeaderboardNetworkController {
    
    static func fetchLeaderboardAnalysisAndRankings(forOwnerId ownerId: UniqueId, user: User, containerType: Leaderboard.Member.Analysis.Container.`Type`, session: NSURLSession = APIClient.sharedSession, success: (leaderboard: LeaderboardMemberAnalysisAndRankings) -> Void, failure: (error: ErrorType) -> Void) {
        LeaderboardMemberAnalysisAndRankingsRequest(ownerId: ownerId, user: user, containerType: containerType).request({(request, error) in
            guard let request = request else { return failure(error: error ?? Error.authentication) }
            
            let task = NSURLSessionTask.JSONTask(session, request: request, success: {(JSON, response) in
                if let leaderboardMemberAnalysisAndRankings = ResourceDeserializer.parse(JSON, resource: LeaderboardMemberAnalysisAndRankings.self) {
                    success(leaderboard: leaderboardMemberAnalysisAndRankings)
                } else {
                    failure(error: Error.parsing)
                }
            }, failure: { (error, response) in
                failure(error: error ?? Error.unknown)
            })
            task.resume()
        })
    }

}

// MARK: - Errors
extension LeaderboardNetworkController {
    enum Error: ErrorType {
        case unknown
        case authentication
        case parsing
    }
}