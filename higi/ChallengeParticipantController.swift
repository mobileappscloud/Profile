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
    
    private var _participaters: [RankedChallengeParticipating] = []
    
    private var _maxUnits: Double? = 0.0
    
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
    var participaters: [RankedChallengeParticipating] {
        get {
            return _participaters
        }
    }
    
    var maxUnits: Double? {
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
        if let challengeParticipater = challengeParticipater as? Challenge.Team {
            // There is no unique identifier on `Challenge.Team`, so we'll use the team name as the basis for equality.
            isUserAssociated = userTeam?.name == challengeParticipater.name
        } else if let challengeParticipater = challengeParticipater as? Challenge.Participant {
            isUserAssociated = user?.identifier == challengeParticipater.identifier
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
    
    private func participaters(forChallenge challenge: Challenge) -> [RankedChallengeParticipating] {
        var participaters: [RankedChallengeParticipating] = []
        var originalParticipators: [ChallengeParticipating]
        if challenge.isTeamChallenge, let teams = challenge.teams {
            originalParticipators = teams.map({$0 as ChallengeParticipating})
        } else {
            originalParticipators = challenge.participants.map({$0 as ChallengeParticipating})
        }
        var rank = 1
        for participator in originalParticipators {
            if isUser(associatedWithChallengeParticipater: participator) {
                participaters.insert(RankedChallengeParticipating(challengeParticipating: participator, rank: rank), atIndex: 0)
            } else {
                participaters.append(RankedChallengeParticipating(challengeParticipating: participator, rank: rank))
            }
            rank += 1
        }
        return participaters
    }
    
    private func calculate(maxUnitsForChallenge challenge: Challenge) -> Double? {
        return challenge.maxPoints
    }
}
