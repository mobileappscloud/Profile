//
//  Leaderboard.swift
//  higi
//
//  Created by Remy Panicker on 8/15/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/**
 *  Leaderboard with information about participants of a competitive event and rankings.
 */
struct Leaderboard: UniquelyIdentifiable {
    
    // MARK: Required
    
    /// Unique identifier.
    let identifier: String
    
    /// Owning object for the leaderboard.
    let owner: Leaderboard.Owner
    
    /// Label for what the score represents.
    let scoreType: ScoreType
    
    // TODO: Verify if needed as source might not matter
//    let source: CustomObject
    
    /// Date leaderboard started to track scores.
    let startDate: NSDate
    
    /// Whether or not the leaderboard is currently live.
    let isLive: Bool
    
    // MARK: Optional
    
    // TODO: Verify if needed
    /// Config options if leaderboard is recurring. Will be `nil` if not a recurring leaderboard.
//    let recurringOptions: CustomObject?
    
    /// Last day leaderboard will track scores. `nil` means scores are tracked indefinitely.
    let endDate: NSDate?
}

extension Leaderboard {
    
    /**
     The unit a score value represents on the leaderboard.
     
     - steps: Scores are recorded in steps.
     */
    enum ScoreType: APIString {
        case steps
    }
}

// MARK: - JSON

extension Leaderboard: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
        let owner = Owner(fromJSONObject: dictionary["owner"]),
        let scoreType = ScoreType(rawJSONValue: dictionary["scoreType"]),
        let startDate = NSDateFormatter.ISO8601DateFormatter.date(fromObject: dictionary["startDate"]),
            let isLive = dictionary["isLive"] as? Bool else { return nil }
        
        let endDate = NSDateFormatter.ISO8601DateFormatter.date(fromObject: dictionary["endDate"])
        
        self.identifier = identifier
        self.owner = owner
        self.scoreType = scoreType
        self.startDate = startDate
        self.isLive = isLive
        
        self.endDate = endDate
    }
}
