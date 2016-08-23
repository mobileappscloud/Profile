//
//  Leaderboard.Owner.swift
//  higi
//
//  Created by Remy Panicker on 8/15/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Leaderboard {
    
    /**
     *  Object which owns the leaderboard.
     */
    struct Owner: UniquelyIdentifiable {
        
        /// Object type of the leaderboard owner.
        let type: Type
        
        /// Unique identifier.
        let identifier: String
    }
}

// MARK: Type

extension Leaderboard.Owner {
    
    /**
     Types of objects which can be leaderboard owners.
     
     - community: Represents a community.
     - profile:   Represents a user.
     */
    enum Type: APIString {
        case community
        case profile
    }
}

// MARK: - JSON

extension Leaderboard.Owner: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let type = Type(rawJSONValue: dictionary["type"]),
            let identifier = dictionary["id"] as? String else {return nil }
        
        self.type = type
        self.identifier = identifier
    }
}
