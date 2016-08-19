//
//  ChallengeDetailController.swift
//  higi
//
//  Created by Remy Panicker on 8/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Responsible for data interaction related to challenge details.
final class ChallengeDetailController {
    
    /// Challenge to view details for.
    private(set) var challenge: Challenge
    
    // MARK: Init
    
    required init(challenge: Challenge) {
        self.challenge = challenge
    }
}
