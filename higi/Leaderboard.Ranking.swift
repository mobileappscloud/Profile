//
//  Leaderboard.Ranking.swift
//  higi
//
//  Created by Remy Panicker on 8/15/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Leaderboard {
    
    struct Rankings: JSONInitializable {
        let rankings: [Ranking]
        let paging: Paging
        let renderInfo: Leaderboard.Member.Analysis.RenderInfo

        init?(dictionary: NSDictionary) {
            guard let rankingsArray = dictionary["data"] as? NSArray,
                let paging = Paging(fromJSONObject: dictionary["paging"]),
                let renderInfo = Leaderboard.Member.Analysis.RenderInfo(fromJSONObject: dictionary["renderInfo"]) else { return nil }
            
            self.rankings = rankingsArray.flatMap(Leaderboard.Rankings.Ranking.init)
            self.paging = paging
            self.renderInfo = renderInfo
        }
    }
}

// MARK: JSON

extension Leaderboard.Rankings {
    /**
     *  Represents a user and their ranking within a leaderboard.
     */
    struct Ranking: JSONInitializable {
        
        /// The overall ranking for a user.
        let ranking: Int
        
        /// The percentile of this ranking which = (people ahead of you / total people) * 100 ... then rounded down.
        let percentile: Int
        
        /// The score for a user.
        let score: Int
        
        /// Publicly consumable representation of a user.
        let user: PublicUser
        
        init?(dictionary: NSDictionary) {
            guard let ranking = dictionary["ranking"] as? Int,
                let percentile = dictionary["percentage"] as? Int, //TODO: update apiary docs of difference
                let score = dictionary["score"] as? Int,
                let user = PublicUser(fromJSONObject: dictionary["user"]) else { return nil }
            
            self.ranking = ranking
            self.percentile = percentile
            self.score = score
            self.user = user
        }
    }
    
    
}
