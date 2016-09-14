//
//  Challenge.WinCondition.swift
//  higi
//
//  Created by Remy Panicker on 8/12/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

// MARK: - Win Condition

extension Challenge {
    
    /**
     *  Details for a way to win the challenge.
     */
    struct WinCondition {
        
        // MARK: Required
        
        /// Details about how to win.
        let goal: Goal
        
        /// Name or title for this condition.
        let name: String
        
        /// Explanation of how to win this condition.
        let description: String
        
        /// The order of importance of this condition relative to others. By default conditions will be ordered by this value.
        let displayOrder: Int
        
        /// Number of winners.
        let winnersCount: Int
        
        /// Type of participants the win condition is applicable to.
        let winnerType: Challenge.Winner.`Type`
        
        // MARK: Optional 
        
        /// Exists if there is a prize that will be awarded for winning.
        let prize: Prize?
        
        /// The number of winners to be randomly selected for drawing tieHandling.
        let drawingQuantity: Int?
        
        /// Winners of this condition. This will be `nil` until a challenge has completed.
        let winners: [Challenge.Winner]?
    }
}

// MARK: JSON

extension Challenge.WinCondition: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let goal = Goal(fromJSONObject: dictionary["goal"]),
            let name = dictionary["name"] as? String,
            let description = dictionary["description"] as? String,
            let displayOrder = dictionary["displayOrder"] as? Int,
            let winnersCount = dictionary["winnersCount"] as? Int,
            let winnerType = Challenge.Winner.`Type`(rawJSONValue: dictionary["winnerType"]) else { return nil }
        
        self.goal = goal
        self.name = name
        self.description = description
        self.displayOrder = displayOrder
        self.winnersCount = winnersCount
        self.winnerType = winnerType
        
        self.prize = Challenge.Prize(fromJSONObject: dictionary["prize"])
        self.drawingQuantity = dictionary["drawingQuantity"] as? Int
        self.winners = CollectionDeserializer.parse(JSONDictionaries: dictionary["winners"], forResource: Challenge.Winner.self)
    }
}

// MARK: - Goal

extension Challenge.WinCondition {
    
    /**
     Details about how to win. See the challenge's metric property to know the unit type of the Goal
     */
    struct Goal {
        
        // MARK: Required
        
        /// Type of goal.
        let type: Type
        
        // MARK: Optional
        
        /// Place needed to satisfy condition.
        let place: Int?
        
        /// Units needed to finish the challenge and satisfy the condition.
        let unitGoal: Int?
        
        /// Min units needed to satisfy condition.
        let minThreshold: Int?
        
        /// Max units allowed to satisfy condition.
        let maxThreshold: Int?
    }
}

extension Challenge.WinCondition.Goal {
    
    /**
     Details for a way to win a challenge.
     
     - mostPoints:       Earn the most units; `place` property will be set.
     - thresholdReached: Meet a certain unit value, `minThreshold` and/or `maxThreshold` will be set.
     - unitGoalReached:  Be first to reach the unit goal of the challenge. Challenge ends once reached by a participant.
     */
    enum Type: APIString {
        case mostPoints = "most_points"
        case thresholdReached = "threshold_reached"
        case unitGoalReached = "unit_goal_reached"
    }
}

// MARK: JSON

extension Challenge.WinCondition.Goal: JSONInitializable {
    
    init?(dictionary: NSDictionary) {
        guard let type = Type(rawJSONValue: dictionary["type"]) else { return nil }
        
        self.type = type
        
        self.place = dictionary["place"] as? Int
        self.unitGoal = dictionary["unit_goal"] as? Int
        self.minThreshold = dictionary["min_threshold"] as? Int
        self.maxThreshold = dictionary["max_threshold"] as? Int
    }
}
