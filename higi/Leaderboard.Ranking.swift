//
//  Leaderboard.Ranking.swift
//  higi
//
//  Created by Remy Panicker on 8/15/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Leaderboard {
    
    /**
     *  Represents a user and their ranking within a leaderboard.
     */
    struct Ranking {
        
        /// The overall ranking for a user.
        let ranking: Int
        
        /// The percentile of this ranking which = (people ahead of you / total people) * 100 ... then rounded down.
        let percentile: Int
        
        /// The score for a user.
        let score: Int
        
        /// Publicly consumable representation of a user.
        let user: PublicUser
    }
}

// MARK: JSON

extension Leaderboard.Ranking: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let ranking = dictionary["ranking"] as? Int,
            let percentile = dictionary["percentile"] as? Int,
            let score = dictionary["score"] as? Int,
            let userDict = dictionary["user"] as? NSDictionary,
            let user = PublicUser.init(dictionary: userDict) else { return nil }
        
        self.ranking = ranking
        self.percentile = percentile
        self.score = score
        self.user = user
    }
}
