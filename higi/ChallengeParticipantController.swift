//
//  ChallengeParticipantController.swift
//  higi
//
//  Created by Remy Panicker on 9/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeParticipantController {
    
    private let challengeRepository: UserDataRepository<Challenge>
    private let challengeId: UniqueId
    private(set) var challenge: Challenge {
        get {
            return challengeRepository.object(forId: challengeId)!
        }
        set {
            challengeRepository.add(object: newValue)
        }
    }
    
    // Backing store for calculated variables
    
    private var _participaters: [ChallengeParticipating] = []
    
    private var _maxUnits: Double = 0.0
    
    // MARK: Init
    
    init(challenge: Challenge, challengeRepository: UserDataRepository<Challenge>) {
        self.challengeRepository = challengeRepository
        self.challengeId = challenge.identifier
        self.challenge = challenge
    }
}

// MARK: - Computed Properties

extension ChallengeParticipantController {
    
    
    /// Provides a collection of participating entities based on the type of challenge.
    ///
    /// - note: The authenticated user or the team which the authenticated user belongs to will always be the first participater in the collection if said user has joined the challenge.
    var participaters: [ChallengeParticipating] {
        get {
            return _participaters
        }
    }
    
    var maxUnits: Double {
        get {
            return _maxUnits
        }
    }
    
    private var user: Challenge.Participant? {
        get {
            return challenge.userRelation.participant
        }
    }
    
    private var userTeam: Challenge.Team? {
        get {
            return user?.team
        }
    }
}

extension ChallengeParticipantController {
    
    /**
     Evaluates whether or not the current authenticated user is associated with the challenge-participating-entity. Ex: Returns `true` if the challenge participater is the current user or a team which the current user is a member of.
     
     - parameter challengeParticipater: Entity which is participating in the challenge.
     
     - returns: `true` if the current authenticated user is associated with the participating entity, otherwise `false`.
     */
    func isUser(associatedWithChallengeParticipater challengeParticipater: ChallengeParticipating) -> Bool {
        var isUserAssociated = false
        if challengeParticipater is Challenge.Team {
            // There is no unique identifier on `Challenge.Team`, so we'll use the team name as the basis for equality.
            isUserAssociated = userTeam?.name == (challengeParticipater as! Challenge.Team).name
        } else if challengeParticipater is Challenge.Participant {
            isUserAssociated = user?.identifier == (challengeParticipater as! Challenge.Participant).identifier
        }
        return isUserAssociated
    }
}

// MARK: - Calculation

extension ChallengeParticipantController {
    
    func refreshCalculatedProperties() {
        _participaters = participaters(forChallenge: challenge)
        _maxUnits = calculate(maxUnitsForChallenge: challenge)
    }
    
    private func participaters(forChallenge challenge: Challenge) -> [ChallengeParticipating] {
        var participaters: [ChallengeParticipating] = []
        if challenge.isTeamChallenge, let teams = challenge.teams {
            if let userTeam = userTeam {
                participaters.append(userTeam as ChallengeParticipating)
            }
            for team in teams {
                if isUser(associatedWithChallengeParticipater: team) { continue }
                
                let participater = team as ChallengeParticipating
                participaters.append(participater)
            }
        } else {
            if let user = user {
                participaters.append(user as ChallengeParticipating)
            }
            for participant in challenge.participants {
                if isUser(associatedWithChallengeParticipater: participant) { continue }
                
                let participater = participant as ChallengeParticipating
                participaters.append(participater)
            }
        }
        return participaters
    }
    
    private func calculate(maxUnitsForChallenge challenge: Challenge) -> Double {
        guard let primaryWinCondition = challenge.winConditions.first else { fatalError("Challenge (\(challenge.name)) with id \(challenge.identifier) does not contain any win conditions.") }
        
        // Teams and participants are sorted in descending order by  `units`, so the first element should contain the highest value for `units`.
        let participatingEntity: ChallengeParticipating? = challenge.isTeamChallenge ? challenge.teams?.first : challenge.participants.first
        guard let participater = participatingEntity else { fatalError("Unable to obtain the required participating entity for challenge: (\(challenge.name)) with id \(challenge.identifier).") }
        
        let maxUnits: Double
        switch primaryWinCondition.goal.type {
        case .mostPoints:
            maxUnits = participater.units
        case .thresholdReached:
            let threshold = (primaryWinCondition.goal.minThreshold ?? primaryWinCondition.goal.maxThreshold) ?? 0
            maxUnits = Double(threshold)
        case .unitGoalReached:
            let unitGoal = primaryWinCondition.goal.unitGoal ?? 0
            maxUnits = Double(unitGoal)
        }
        return maxUnits
    }
}
