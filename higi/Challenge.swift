//
//  Challenge.swift
//  higi
//
//  Created by Remy Panicker on 8/9/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

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
    
    /// Conditions which must be met in order for a participant to win a challenge.
    let winConditions: [Challenge.WinCondition]
    
    /// Current user's relationship to the challenge.
    let userRelation: UserRelation
    
    /// Comments and comment related information for the challenge.
    let chatter: Chatter
    
    /// Start date for a challenge.
    let startDate: NSDate

    /// A description of the goal for this challenge.
    let goalDescription: String

    /// Determines whether the challenge can be joined by the user. Private so that clients do not use this. Instead, use any of the isJoinable[...] properties.
    private let canBeJoined: Bool

    // MARK: Optional-Modified
    // These properties are optionally returned by the API, but can be modeled as non-optional properties
    
    /// Current participants for a challenge.
    let participants: [Participant]
    
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
    
    required init(identifier: String, name: String, description: String, let shortDescription: String, image: MediaAsset, metric: Metric, status: Status, dailyLimit: Int, participantCount: Int, devices: [ActivityDevice], winConditions: [Challenge.WinCondition], userRelation: UserRelation, chatter: Chatter, startDate: NSDate, goalDescription: String, canBeJoined: Bool, participants: [Participant], community: Community? = nil, teams: [Team]? = nil, terms: String? = nil, endDate: NSDate? = nil, entryFee: Double? = nil, prizeDescription: String? = nil) {
        self.identifier = identifier
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
        self.image = image
        self.metric = metric
        self.status = status
        self.dailyLimit = dailyLimit
        self.participantCount = participantCount
        self.devices = devices
        self.winConditions = winConditions
        self.userRelation = userRelation
        self.chatter = chatter
        self.startDate = startDate
        self.goalDescription = goalDescription
        self.canBeJoined = canBeJoined
        
        self.participants = participants
        
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
    
    /// Highest score amongst all team participants.
    var teamHighScore: Double {
        guard let teams = teams else { return 0.0 }
        return teams.map({$0.units}).maxElement() ?? 0.0
    }
    
    var isJoinable: Bool {
        return isDirectlyJoinable || isJoinableAfterCommunityIsJoined
    }
    
    var isDirectlyJoinable: Bool {
        return canBeJoined && userRelation.joinURL != nil && status != .finished && status != .canceled && status != .calculating
    }
    
    var needToJoinCommunityFirst: Bool {
        return !isDirectlyJoinable && isJoinableAfterCommunityIsJoined
    }
    
    //TODO: Peter Ryszkiewicz: Validate/audit this logic
    var isJoinableAfterCommunityIsJoined: Bool {
        return community != nil && userRelation.participant == nil && status != .finished && status != .canceled && status != .calculating
    }
}

extension Challenge {
    
    /// Highest score amongst all individual participants.
    var individualHighScore: Double {
        return participants.map({$0.units}).maxElement() ?? 0.0
    }
}

extension Challenge {
    
    /// Sanitizes `shortDescription` by removing `HTML` entities and select whitespace characters to produce a display-ready string.
    var sanitizedShortDescription: String {
        var sanitizedShortDescription = shortDescription.stringByDecodingHTMLEntities();
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
            let status = Status(rawJSONValue: dictionary["status"]),
            let dailyLimit = dictionary["dailyLimit"] as? Int,
            let participantCount = dictionary["participantsCount"] as? Int,
            let devices = CollectionDeserializer.parse(JSONDictionaries: dictionary["devices"], forResource: ActivityDevice.self),
            let winConditions = CollectionDeserializer.parse(JSONDictionaries: dictionary["winConditions"], forResource: Challenge.WinCondition.self),
            let userRelation = Challenge.UserRelation(fromJSONObject: dictionary["userRelation"]),
            let chatter = Chatter(fromJSONObject: dictionary["comments"]),
            let startDate = NSDateFormatter.yyyyMMddDateFormatter.date(fromObject: dictionary["startDate"]),
            let goalDescription = dictionary["goalDescription"] as? String,
            let canBeJoined = dictionary["canBeJoined"] as? Bool
            else { return nil }
        
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
        
        self.init(identifier: identifier, name: name, description: description, shortDescription: shortDescription, image: image, metric: metric, status: status, dailyLimit: dailyLimit, participantCount: participantCount, devices: devices, winConditions: winConditions, userRelation: userRelation, chatter: chatter, startDate: startDate, goalDescription: goalDescription, canBeJoined: canBeJoined, participants: participants, community: community, teams: teams, terms: terms, endDate: endDate, entryFee: entryFee, prizeDescription: prizeDescription)
    }
}
