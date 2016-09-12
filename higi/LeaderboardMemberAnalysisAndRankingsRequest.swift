//
//  LeaderboardMemberAnalysisAndRankingsRequest.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 8/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class LeaderboardMemberAnalysisAndRankingsRequest: ProtectedAPIRequest {
    let ownerId: UniqueId
    let user: User
    let containerType: Leaderboard.Member.Analysis.Container.`Type`
    
    required init(ownerId: UniqueId, user: User, containerType: Leaderboard.Member.Analysis.Container.`Type`) {
        self.ownerId = ownerId
        self.user = user
        self.containerType = containerType
    }
    
    func request(completion: APIRequestAuthenticatorCompletion) {
        let relativePath = "/leaderboard/mobile/owner/\(ownerId)/members/\(user.identifier)/analysis/\(containerType)" // FIXME: apiary docs
        authenticatedRequest(relativePath, parameters: nil, completion: completion)
    }
}
