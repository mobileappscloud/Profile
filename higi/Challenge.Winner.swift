//
//  Challenge.Winner.swift
//  higi
//
//  Created by Remy Panicker on 8/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

// MARK: - Winner

extension Challenge {
    
    /**
     *  A winner of a challenge.
     */
    struct Winner {
        
        /// Present if winner is a participant.
        let participant: Participant?
        
        /// Present if winner is a team.
        let team: Team?
    }
}

// MARK: JSON

extension Challenge.Winner: JSONInitializable {
   
    init?(dictionary: NSDictionary) {
        self.participant = Challenge.Participant(fromJSONObject: dictionary["participant"])
        self.team = Challenge.Team(fromJSONObject: dictionary["team"])
    }
}

// MARK: - Winner Type

extension Challenge.Winner {
    
    /**
     Type of winner.
     
     - individual: Winner is an individual challenge participant.
     - team:       Winner is a team of challenge participants.
     */
    enum `Type`: APIString {
        case individual
        case team
    }
}
