//
//  Challenge.Prize.swift
//  higi
//
//  Created by Remy Panicker on 8/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension Challenge {
    
    /**
     *  Prize awarded to challenge winners.
     */
    struct Prize {
        
        /// Name of the prize.
        let name: String
        
        /// Default image for prize.
        let image: MediaAsset
    }
}

// MARK: - JSON

extension Challenge.Prize: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let name = dictionary["name"] as? String,
            let image = MediaAsset(fromLegacyJSONObject: dictionary) else { return nil }
        
        self.name = name
        self.image = image
    }
}
