//
//  Challenge.Team.swift
//  higi
//
//  Created by Remy Panicker on 8/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Challenge {
    
    /**
     *  Provides information about the progress of a team during a challenge as well as information about the team's members.
     */
    struct Team: ChallengeParticipating {
        
        // MARK: Required
        
        /// Name of the team.
        let name: String

        /// Id of the team. Undocumented in Apiary atm. Only unique to other teams.
        let identifier: String

        /// Number of members on the team.
        let memberCount: Int
        
        /// Current score in the challenge.
        let units: Double
        
        // MARK: Optional
        
        /// Team logo.
        let image: MediaAsset?
        
        /// Present if current user is allowed to join this team.
        let joinURL: NSURL?
        
        func isAssociatedWithParticipant(participant: Challenge.Participant) -> Bool {
            return participant.team?.identifier == identifier
        }
    }
}

// MARK: - JSON

extension Challenge.Team: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let name = dictionary["name"] as? String,
            let identifier = dictionary["id"] as? String,
            let memberCount = dictionary["membersCount"] as? Int,
            let units = dictionary["units"] as? Double else { return nil }
        
        self.name = name
        self.identifier = identifier
        self.memberCount = memberCount
        self.units = units
        
        self.image = MediaAsset(fromLegacyJSONObject: dictionary)
        self.joinURL = NSURL(responseObject: dictionary["joinUrl"])
    }
}
