//
//  Challenge.swift
//  higi
//
//  Created by Remy Panicker on 8/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Crashlytics

/// This resource contains information about a challenge.
final class Challenge: UniquelyIdentifiable {
    
    // MARK: Required
    
    /// Unique identifier for a challenge.
    let identifier: String
    
    /// Name of a challenge.
    let name: String
    
    /**
     Full description for a challenge in `HTML`.
     
     - SeeAlso `shortDescription`
     */
    let description: String
    
    /**
     Text-only short description for a challenge.
     
     **Note** This property may need to be sanitized before it is display-ready.
     
     - SeeAlso `sanitizedShortDescription`
     */
    let shortDescription: String
    
    /// Logo image for a challenge
    let image: MediaAsset
    
    /// Metric type used for score in this challenge.
    let metric: Metric
    
    /// Template type for this challenge. Useful for determining characteristics about the challenge.
    let template: Template
    
    /// Status of a challenge
    let status: Status
    
    /**
     Daily point limit.
     
     Note: `0` means there is no limit.
     */
    let dailyLimit: Int
    
    /// Number of people participating in a challenge.
    let participantCount: Int
    
    /// List of devices allowed in this challenge.
    let devices: [ActivityDevice]
    
    /// Conditions which must be met in order for a participant to win a challenge. There must be at least 1 win condition for a challenge to be valid.
    let winConditions: [Challenge.WinCondition]
    
    /// Current user's relationship to the challenge.
    let userRelation: UserRelation
    
    /// Comments and comment related information for the challenge.
    let chatter: Chatter
    
    /// Start date for a challenge.
    let startDate: NSDate

    /// A description of the goal for this challenge.
    let goalDescription: String

    // MARK: Optional-Modified
    // These properties are optionally returned by the API, but can be modeled as non-optional properties
    
    /// Current participants for a challenge.
    let participants: [Participant]
    
    /// Conveys the state of the joinability of the challenge
    let joinableStatus: JoinableStatus
    
    // MARK: Optional
    
    /// Community a challenge belongs to if applicable
    let community: Community?

    /// Teams participating in challenge. Always included on team challenges; sorted by place if challenge started.
    let teams: [Team]?
    
    /// Legal terms and conditions. Contains HTML.
    let terms: String?
    
    /// End date for a challenge.
    let endDate: NSDate?
    
    /// Entree fee to join if a paid challenge.
    let entryFee: Double?

    /// A description of the prize for this challenge.
    let prizeDescription: String?

    // MARK: Init
    
    required init(identifier: String, name: String, description: String, let shortDescription: String, image: MediaAsset, metric: Metric, template: Template, status: Status, dailyLimit: Int, participantCount: Int, devices: [ActivityDevice], winConditions: [Challenge.WinCondition], userRelation: UserRelation, chatter: Chatter, startDate: NSDate, goalDescription: String, participants: [Participant], joinableStatus: JoinableStatus, community: Community? = nil, teams: [Team]? = nil, terms: String? = nil, endDate: NSDate? = nil, entryFee: Double? = nil, prizeDescription: String? = nil) {
        self.identifier = identifier
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
        self.image = image
        self.metric = metric
        self.template = template
        self.status = status
        self.dailyLimit = dailyLimit
        self.participantCount = participantCount
        self.devices = devices
        self.winConditions = winConditions
        self.userRelation = userRelation
        self.chatter = chatter
        self.startDate = startDate
        self.goalDescription = goalDescription
        self.participants = participants
        self.joinableStatus = joinableStatus
        
        self.community = community
        self.teams = teams
        self.terms = terms
        self.endDate = endDate
        self.entryFee = entryFee
        self.prizeDescription = prizeDescription
    }
}

// MARK: - Computed Properties

extension Challenge {
    
    var isJoinable: Bool {
        return isDirectlyJoinable || isJoinableAfterCommunityIsJoined
    }
    
    var isDirectlyJoinable: Bool {
        return joinableStatus == .joinable
    }
    
    var needToJoinCommunityFirst: Bool {
        return isJoinableAfterCommunityIsJoined
    }
    
    //TODO: Peter Ryszkiewicz: Validate/audit this logic
    var isJoinableAfterCommunityIsJoined: Bool {
        return joinableStatus == .joinCommunity
    }
    
    /// Returns a value in [0.0, 1.0] that corresponds to how far a user is in completing a challenge.
    /// Useful for progress views.
    var userProgressProportion: Double? {
        guard let userPoints = userRelation.participant?.units else { return nil }
        guard let maxPoints = maxPoints else { return nil }
        return userPoints / Double(maxPoints)
    }
    
    /// The maximum number of points for this challenge for winning the highest win condition.
    /// Guaranteed to be finite and > 0, if it exists
    var maxPoints: Double? {
        guard let primaryWinCondition = winConditions.first else { fatalError("Challenge (\(name)) with id \(identifier) does not contain any win conditions.") }
        
        var maxUnits: Double? = nil
        switch primaryWinCondition.goal.type {
        case .mostPoints:
            // Teams and participants are sorted in descending order by  `units`, so the first element should contain the highest value for `units`.
            let participatingEntity: ChallengeParticipating? = isTeamChallenge ? teams?.first : participants.first
            maxUnits = participatingEntity?.units
        case .thresholdReached:
            if let threshold = primaryWinCondition.goal.minThreshold ?? primaryWinCondition.goal.maxThreshold {
                maxUnits = Double(threshold)
            }
        case .unitGoalReached:
            if let unitGoal = primaryWinCondition.goal.unitGoal {
                maxUnits = Double(unitGoal)
            }
        }
        if let maxUnits = maxUnits where maxUnits.isFinite && maxUnits > 0 {
            return maxUnits
        }
        return nil
    }
    
    /// Returns values in [0.0, 1.0] that corresponds to how far the win conditions are relative to the highest win condition.
    /// Useful for progress views.
    var winConditionProportions: [CGFloat]? {
        guard let maxPoints = maxPoints else { return nil }
        var winConditionProportions: [CGFloat] = []
        for winCondition in winConditions {
            switch winCondition.goal.type {
            case .mostPoints: break;
            case .thresholdReached:
                if let threshold = winCondition.goal.minThreshold ?? winCondition.goal.maxThreshold {
                    winConditionProportions.append(CGFloat(threshold) / CGFloat(maxPoints))
                }
            case .unitGoalReached:
                if let unitGoal = winCondition.goal.unitGoal {
                    winConditionProportions.append(CGFloat(unitGoal) / CGFloat(maxPoints))
                }
            }
        }
        return winConditionProportions
    }

}

extension Challenge {
    
    /// Highest score amongst all team participants.
    var teamHighScore: Double {
        guard let teams = teams else { return 0.0 }
        return teams.map({$0.units}).maxElement() ?? 0.0
    }
    
    /// Highest score amongst all individual participants.
    var individualHighScore: Double {
        return participants.map({$0.units}).maxElement() ?? 0.0
    }
}

extension Challenge {
    
    /**
     Whether or not a challenge is competitive.
     
     - note: There may be win conditions for both teams and individuals, but this property informs whether or not the primary experience of the challenge should be competitive.
     */
    var isCompetitive: Bool {
        let isCompetitive: Bool
        switch template {
        case .individualCompetitive, .individualCompetitiveGoal, .teamCompetitive, .teamCompetitiveGoal:
            isCompetitive = true
        case .individualGoalAccumulation, .individualGoalFrequency, .teamGoalAccumulation:
            isCompetitive = false
        }
        return isCompetitive
    }
}

extension Challenge {
    
    /**
     Whether or not a challenge is primarily intended to be participated by teams. If `false`, it can be assumed that the challenge is primarily intended to be participated by individuals.
     
     - note: There may be win conditions for both teams and individuals, but this property informs whether or not the primary experience of the challenge should emphasize the team.
     */
    var isTeamChallenge: Bool {
        let isTeamChallenge: Bool
        switch template {
        case .teamCompetitive, .teamGoalAccumulation, .teamCompetitiveGoal:
            isTeamChallenge = true
        case .individualGoalAccumulation, .individualGoalFrequency, .individualCompetitiveGoal, .individualCompetitive:
            isTeamChallenge = false
        }
        return isTeamChallenge
    }
}

extension Challenge {
    
    /// Sanitizes `shortDescription` by removing `HTML` entities and select whitespace characters to produce a display-ready string.
    var sanitizedShortDescription: String {
        var sanitizedShortDescription = shortDescription.stringByDecodingHTMLEntities()
        sanitizedShortDescription = sanitizedShortDescription.stringByReplacingOccurrencesOfString("\r", withString: "", options: .LiteralSearch, range: nil)
        sanitizedShortDescription = sanitizedShortDescription.stringByReplacingOccurrencesOfString("\t", withString: "", options: .LiteralSearch, range: nil)
        return sanitizedShortDescription
    }
}

// MARK: - Types

extension Challenge {
    
    /**
     Metric type used for score in this challenge.
     
     - steps:  Challenge is step based.
     - points: Challenge is points based.
     */
    enum Metric: APIString {
        case steps
        case points
    }
}

extension Challenge {
    
    /**
     Current state a challenge is in.
     
     - registration: The challenge is accepting participants for registration.
     - running:      The challenge is running.
     - calculating:  The results for the challenge are being calculated.
     - finished:     The challenge has finished.
     - canceled:     The challenge has been canceled.
     */
    enum Status: APIString {
        case registration
        case running
        case calculating
        case finished
        case canceled
    }
}

extension Challenge {
    
    /**
     Template which guides the experience of a challenge.
     
     - individualGoalAccumulation: Get users to work towards a goal over a period of time.
     - individualCompetitive:      Get users to compete for one of the top spot over a period of time.
     - individualCompetitiveGoal:  Get users to compete to be the first to complete a goal.
     - teamGoalAccumulation:       Get users to work collectively towards a goal over a period of time.
     - teamCompetitive:            Get users to work collectively for one of the top spot over a period of time.
     - teamCompetitiveGoal:        Get users to work collectively to be the first to complete a goal.
     */
    enum Template: APIString {
        case individualGoalAccumulation = "individual-goal-accumulation"
        case individualGoalFrequency = "individual-goal-frequency"
        case individualCompetitive = "individual-competitive"
        case individualCompetitiveGoal = "individual-competitive-goal"
        case teamGoalAccumulation = "team-goal-accumulation"
        case teamCompetitive = "team-competitive"
        case teamCompetitiveGoal = "team-competitive-goal"
    }
}

// MARK: - States

extension Challenge {
    enum UserState {
        case unjoinedAndUnderway
        case unjoinedAndNotUnderway
        case joinedAndUnderway
        case joinedAndNotUnderway
        case tabulatingResults
        case challengeComplete
        case cancelled
    }
    
    enum JoinableStatus: APIString {
        case joinable
        case notJoinable
        case joinCommunity
    }
    
    /// An abstraction for the combination of the user state and the challenge state.
    var userState: UserState {
        if status == .canceled {
            return .cancelled
        }
        if status == .finished {
            return .challengeComplete
        }
        if status == .calculating {
            return .tabulatingResults
        }
        if status == .running {
            if userRelation.status.isJoined {
                return .joinedAndUnderway
            }
            return .unjoinedAndUnderway
        }
        if userRelation.status.isJoined {
            return .joinedAndNotUnderway
        }
        return .unjoinedAndNotUnderway
    }
}

// MARK: - JSON

extension Challenge: JSONInitializable {
    
    convenience init?(dictionary: NSDictionary) {
        guard let identifier = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let description = dictionary["description"] as? String,
            let shortDescription = dictionary["shortDescription"] as? String,
            let image = MediaAsset(fromLegacyJSONObject: dictionary),
            let metric = Metric(rawJSONValue: dictionary["metric"]),
            let template = Template(rawJSONValue: dictionary["challengeTemplate"]),
            let status = Status(rawJSONValue: dictionary["status"]),
            let dailyLimit = dictionary["dailyLimit"] as? Int,
            let participantCount = dictionary["participantsCount"] as? Int,
            let devices = CollectionDeserializer.parse(JSONDictionaries: dictionary["devices"], forResource: ActivityDevice.self),
            let winConditions = CollectionDeserializer.parse(JSONDictionaries: dictionary["winConditions"], forResource: Challenge.WinCondition.self),
            let userRelation = Challenge.UserRelation(fromJSONObject: dictionary["userRelation"]),
            let chatter = Chatter(fromJSONObject: dictionary["comments"]),
            let startDate = NSDateFormatter.yyyyMMddDateFormatter.date(fromObject: dictionary["startDate"]),
            let goalDescription = dictionary["goalDescription"] as? String,
            let joinableStatus = JoinableStatus(rawJSONValue: dictionary["joinableStatus"])
            else {
                CLSLogv("Challenge parse error", getVaList([]))
                return nil
        }
        
        var participants: [Participant] = []
        if let participantsResponseObject = dictionary["participants"] as? NSDictionary,
            let participantsDicts = participantsResponseObject["data"] as? [NSDictionary] {
            participants = CollectionDeserializer.parse(dictionaries: participantsDicts, forResource: Participant.self)
        }
        
        let community = Community(fromJSONObject: dictionary["community"])
        let teams: [Team] = CollectionDeserializer.parse(JSONDictionaries: dictionary["teams"], forResource: Challenge.Team.self) ?? []
        let terms = dictionary["terms"] as? String
        let endDate = NSDateFormatter.yyyyMMddDateFormatter.date(fromObject: dictionary["endDate"])
        let entryFee = dictionary["entryFee"] as? Double
        let prizeDescription = dictionary["prizeDescription"] as? String
        
        if winConditions.isEmpty {
            CLSLogv("Challenge parse error: missing win conditions", getVaList([]))
            return nil
        }
        
        self.init(identifier: identifier, name: name, description: description, shortDescription: shortDescription, image: image, metric: metric, template: template,status: status, dailyLimit: dailyLimit, participantCount: participantCount, devices: devices, winConditions: winConditions, userRelation: userRelation, chatter: chatter, startDate: startDate, goalDescription: goalDescription, participants: participants, joinableStatus: joinableStatus, community: community, teams: teams, terms: terms, endDate: endDate, entryFee: entryFee, prizeDescription: prizeDescription)
    }
}

// MARK: - Protocol

/**
 *  Protocol for types which can participate in a challenge.
 */
protocol ChallengeParticipating {
    
    /// Name of the participating entity.
    var name: String { get }
    
    /// Participating entity's score in the challenge. See challenge to know what type of units are being used.
    var units: Double { get }
    
    /// Avatar for the participating entity.
    var image: MediaAsset? { get }
    
    var identifier: String { get }
    
    func isAssociatedWithParticipant(participant: Challenge.Participant) -> Bool
}
