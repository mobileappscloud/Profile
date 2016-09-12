//
//  LeaderboardMemberAnalysisAndRankings.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

struct LeaderboardMemberAnalysisAndRankings {
    let analysis: Leaderboard.Member.Analysis?
    let rankings: Leaderboard.Rankings?
    let paging: Paging?
}

extension LeaderboardMemberAnalysisAndRankings: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        self.analysis = Leaderboard.Member.Analysis(fromJSONObject: dictionary["analysis"])
        self.rankings = Leaderboard.Rankings(fromJSONObject: dictionary["rankings"])
        self.paging = Paging(fromJSONObject: dictionary["paging"])
    }
}
