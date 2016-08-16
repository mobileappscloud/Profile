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
    
    /// Full description for a challenge in `HTML`.
    let description: String
    
    /// Text-only short description for a challenge.
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
    
    // MARK: Init
    
    required init(identifier: String, name: String, description: String, let shortDescription: String, image: MediaAsset, metric: Metric, status: Status, dailyLimit: Int, participantCount: Int, devices: [ActivityDevice], winConditions: [Challenge.WinCondition], userRelation: UserRelation, chatter: Chatter, startDate: NSDate, participants: [Participant], community: Community? = nil, teams: [Team]? = nil, terms: String? = nil, endDate: NSDate? = nil, entryFee: Double? = nil) {
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
        
        self.participants = participants
        
        self.community = community
        self.teams = teams
        self.terms = terms
        self.endDate = endDate
        self.entryFee = entryFee
    }
}

// MARK: - Computed Properties

extension Challenge {
    
    /// Highest score amongst all team participants.
    var teamHighScore: Double {
        guard let teams = teams else { return 0.0 }
        return teams.map({$0.units}).maxElement() ?? 0.0
    }
}

extension Challenge {
    
    /// Highest score amongst all individual participants.
    var individualHighScore: Double {
        return participants.map({$0.units}).maxElement() ?? 0.0
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
            let devices = CollectionDeserializer.parse(dictionary["devices"], forResource: ActivityDevice.self),
            let winConditions = CollectionDeserializer.parse(dictionary["winConditions"], forResource: Challenge.WinCondition.self),
            let userRelation = Challenge.UserRelation(fromJSONObject: dictionary["userRelation"]),
            let chatter = Chatter(fromJSONObject: dictionary["comments"]),
            let startDate = NSDateFormatter.YYYYMMddDateFormatter.date(fromObject: dictionary["startDate"])
            else { return nil }
        
        var participants: [Participant] = []
        if let participantsResponseObject = dictionary["participants"] as? NSDictionary,
            let participantsDicts = participantsResponseObject["data"] as? [NSDictionary] {
            participants = CollectionDeserializer.parse(participantsDicts, forResource: Participant.self)
        }
        
        let community = Community(fromJSONObject: dictionary["community"])
        let teams: [Team] = CollectionDeserializer.parse(dictionary["teams"], forResource: Challenge.Team.self) ?? []
        let terms = dictionary["terms"] as? String
        let endDate = NSDateFormatter.YYYYMMddDateFormatter.date(fromObject: dictionary["endDate"])
        let entryFee = dictionary["entryFee"] as? Double
        
        self.init(identifier: identifier, name: name, description: description, shortDescription: shortDescription, image: image, metric: metric, status: status, dailyLimit: dailyLimit, participantCount: participantCount, devices: devices, winConditions: winConditions, userRelation: userRelation, chatter: chatter, startDate: startDate, participants: participants, community: community, teams: teams, terms: terms, endDate: endDate, entryFee: entryFee)
    }
}
