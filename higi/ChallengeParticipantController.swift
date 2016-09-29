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
    unowned private let delegate: ChallengeParticipantControllerDelegate
    
    var maxUnits: Double? {
        return challenge.maxPoints
    }
    
    /// Provides a collection of participating entities based on the type of challenge.
    ///
    /// - note: The authenticated user or the team which the authenticated user belongs to will always be the first participater in the collection if said user has joined the challenge.
    private(set) var rows: [Row] = []
    
    // MARK: Init
    
    init(challenge: Challenge, challengeRepository: UserDataRepository<Challenge>, delegate: ChallengeParticipantControllerDelegate) {
        self.challengeRepository = challengeRepository
        self.challengeId = challenge.identifier
        self.delegate = delegate
        self.challenge = challenge
    }
}

// MARK: - Computed Properties

extension ChallengeParticipantController {
    
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
        guard let user = user else { return false }
        return challengeParticipater.isAssociatedWithParticipant(user)
    }
}

// MARK: - Calculation

extension ChallengeParticipantController {
    
    func refreshCalculatedProperties() {
        rows = rows(forChallenge: challenge)
    }
    
    private func rows(forChallenge challenge: Challenge) -> [Row] {
        var rows: [Row] = []
        var participators: [ChallengeParticipating]
        if challenge.isTeamChallenge, let teams = challenge.teams {
            participators = teams.map({$0 as ChallengeParticipating})
        } else {
            participators = challenge.participants.map({$0 as ChallengeParticipating})
        }
        var rank = 1
        for participator in participators {
            let subrows = subrowsForParticipator(participator)
            let row = Row(challengeParticipant: participator, subrows: subrows, showingSubrows: false, rank: rank)
            if isUser(associatedWithChallengeParticipater: participator) {
                rows.insert(row, atIndex: 0)
            } else {
                rows.append(row)
            }
            rank += 1
        }
        return rows
    }
    
    private func subrowsForParticipator(participator: ChallengeParticipating) -> [Row] {
        var rows = [Row]()
        
        if let team = participator as? Challenge.Team, let teamParticipants = teamIdToParticipantsMap[team.identifier] {
            teamParticipants.forEach({ (participant) in
                rows.append(Row(challengeParticipant: participant, subrows: [], showingSubrows: false, rank: nil))
            })
            rows.sortInPlace({ (row1, row2) -> Bool in // by design
                return row1.challengeParticipant.name < row2.challengeParticipant.name
            })
        }
        
        return rows
    }
    
    private var teamIdToParticipantsMap: [String: [Challenge.Participant]] {
        var teamMap: [String: [Challenge.Participant]] = [:]
        challenge.participants.forEach({ (participant) in
            guard let team = participant.team else { return }
            if let _ = teamMap[team.identifier] {
                teamMap[team.identifier]!.append(participant)
            } else {
                teamMap[team.identifier] = [participant]
            }
        })

        return teamMap
    }
}

// MARK: - Delegation

extension ChallengeParticipantController {
    func didSelectRowAtIndexPath(indexPath: NSIndexPath) {
        let row = rows[indexPath.row]
        let subrows = row.subrows
        let indexPathsToModify = subrows.indices.map({
            return NSIndexPath(forRow: indexPath.row + 1 + $0, inSection: indexPath.section)
        })
        if row.showingSubrows {
            guard !indexPathsToModify.isEmpty else { return }
            let removalRange = (indexPath.row + 1)..<(indexPath.row + 1 + subrows.count)
            rows.removeRange(removalRange)
            delegate.removeRowsAt(indexPaths: indexPathsToModify)
        } else {
            rows.insertContentsOf(row.subrows, at: indexPath.row + 1)
            delegate.insertRowsAt(indexPaths: indexPathsToModify)
        }
        rows[indexPath.row].showingSubrows = !row.showingSubrows
    }
}

// MARK: - Inner classes

extension ChallengeParticipantController {
    
    /// View model for each row in the partipants table
    struct Row {
        let challengeParticipant: ChallengeParticipating
        let subrows: [Row] // TODO: Peter Ryszkiewicz: Optimize with lazy lookup
        var showingSubrows = false
        let rank: Int? // Maybe we could make it non-optional
    }
    
}

protocol ChallengeParticipantControllerDelegate: class {
    func insertRowsAt(indexPaths indexPaths: [NSIndexPath])
    func removeRowsAt(indexPaths indexPaths: [NSIndexPath])
}
