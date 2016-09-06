//
//  Challenge.Participant.swift
//  higi
//
//  Created by Remy Panicker on 8/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Challenge {
    
    /**
     Represents an entity (team/individual) participating in a challenge. Contains information about a user's progress in a challenge along with a participant's team information when applicable.
     */
    struct Participant: UniquelyIdentifiable {
        
        // MARK: Required
        
        /// Unique identifier.
        let identifier: String
        
        /// Display-ready name for a challenge participant.
        let displayName: String
        
        /// Avatar for the challenge participant.
        let image: MediaAsset
        
        /// User's score in the challenge. See challenge to know what type of units are being used.
        let units: Double
        
        // MARK: Optional
        
        /// Team which the current participant is a member of.
        let team: Team?
    }
}

// MARK: - JSON

extension Challenge.Participant: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let userPublicDict = dictionary["userPublic"] as? NSDictionary,
            let identifier = userPublicDict["id"] as? String,
            let displayName = userPublicDict["displayName"] as? String,
            let image = MediaAsset(fromLegacyJSONObject: userPublicDict),
            let units = dictionary["units"] as? Double
            else { return nil }

        self.identifier = identifier
        self.displayName = displayName
        self.image = image
        self.units = units
        self.team = Challenge.Team(fromJSONObject: dictionary["team"])
    }
}
