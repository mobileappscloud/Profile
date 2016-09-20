//
//  LeaderboardAAAController.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class LeaderboardAAAController {
    
    // Injected
    let ownerId: UniqueId
    
    // Properties
    var leaderboardMemberAnalysisAndRankings: LeaderboardMemberAnalysisAndRankings?
    
    // Lazy Properties
    private lazy var session: NSURLSession = APIClient.sharedSession
    
    init(leaderboardOwnerId: UniqueId) {
        ownerId = leaderboardOwnerId
    }
}

// MARK: Fetching a leaderboard

extension LeaderboardAAAController {
    func fetchLeaderboardAnalysisAndRankings(user: User, success: () -> Void, failure: (error: ErrorType) -> Void) {
        LeaderboardNetworkController.fetchLeaderboardAnalysisAndRankings(forOwnerId: ownerId, user: user, containerType: Leaderboard.Member.Analysis.Container.`Type`.aaa, session: session, success: {
            [weak self] leaderboard in
            self?.leaderboardMemberAnalysisAndRankings = leaderboard
            success()
        }, failure: failure)
    }
}