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
        
        /// Number of members on the team.
        let memberCount: Int
        
        /// Current score in the challenge.
        let units: Double
        
        // MARK: Optional
        
        /// Team logo.
        let image: MediaAsset?
        
        /// Present if current user is allowed to join this team.
        let joinURL: NSURL?
    }
}

// MARK: - JSON

extension Challenge.Team: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let name = dictionary["name"] as? String,
            let memberCount = dictionary["memberCount"] as? Int,
            let units = dictionary["units"] as? Double else { return nil }
        
        self.name = name
        self.memberCount = memberCount
        self.units = units
        
        self.image = MediaAsset(fromLegacyJSONObject: dictionary)
        self.joinURL = NSURL(responseObject: dictionary["joinUrl"])
    }
}
