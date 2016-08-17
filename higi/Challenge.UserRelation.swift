//
//  Challenge.UserRelation.swift
//  higi
//
//  Created by Remy Panicker on 8/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Challenge {
    
    /**
     *  Details the current user's relationship to the challenge.
     */
    struct UserRelation {
        
        // MARK: Required
        
        /// Status of user with respect to the challenge.
        let status: Status
        
        // MARK: Optional
        
        /// `Challenge.Participant` representation of the current user. This is `nil` if the current user is not participating in the challenge.
        let participant: Participant?
        
        /**
         Present if user allowed to join.
         
         Note: If challenge is a team challenge, the join URL will exist on joinable-team-userRelation objects instead of being populated here.
         */
        let joinURL: NSURL?
        
        /// A leaderboard centered around the user.
        let gravityBoard: GravityBoard?
    }
}

extension Challenge.UserRelation {
    
    /**
     Status of the challenge in relation to the current user.
     
     - \`public\`:  Challenge is public, but the user has not joined.
     - invited:  User has been invited to the challenge, but has not joined.
     - upcoming: User has joined the challenge and the challenge is currently in `registration` status.
     - current:  User has joined the challenge and the challenge is either in `running`, `calculating`, or `finished` status and has been finished for <= 7 days.
     - finished: User has joined the challenge and the challenge is in `finished` status.
     */
    enum Status: APIString {
        case `public`
        case invited
        case upcoming
        case current
        case finished
        
        var isJoined: Bool {
            switch self {
            case .`public`, .invited:
                return false
            case .upcoming, .current, .finished:
                return true
            }
        }
    }
}

// MARK: JSON

extension Challenge.UserRelation: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let status = Status(rawJSONValue: dictionary["status"]) else { return nil }
        
        self.status = status
        self.gravityBoard = GravityBoard(fromJSONObject: dictionary)
        self.participant = Challenge.Participant(fromJSONObject: dictionary["participant"])
        self.joinURL = NSURL(responseObject: dictionary["joinURL"])
    }
}

// MARK: - GravityBoard

extension Challenge.UserRelation {
    
    /**
     *  A leaderboard centered around the user.
     */
    struct GravityBoard {
        
        typealias Participant = (participant: Challenge.Participant, position: Int)
        
        /// Challenge participants and their position (ranking) amongst all challenge participants.
        let participants: [Participant]
    }
}

// MARK: JSON

extension Challenge.UserRelation.GravityBoard: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let gravityBoardElements = dictionary["gravityBoard"] as? [NSDictionary] else { return nil }
        
        var gravityParticipants: [Participant] = []
        for gravityBoardElement in gravityBoardElements {
            guard let participant = Challenge.Participant(fromJSONObject: gravityBoardElement["participant"]),
                let position = gravityBoardElement["position"] as? Int else { continue }
            
            let gravityParticipant = (participant, position)
            gravityParticipants.append(gravityParticipant)
        }
        self.participants = gravityParticipants
    }
}
