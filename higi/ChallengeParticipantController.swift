//
//  ChallengeParticipantController.swift
//  higi
//
//  Created by Remy Panicker on 9/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeParticipantController: NSObject {
    
    // Properties
    
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
    
    var maxUnits: Double? {
        return challenge.maxPoints
    }
    
    /// Provides a collection of participating entities based on the type of challenge.
    ///
    /// - note: The authenticated user or the team which the authenticated user belongs to will always be the first participater in the collection if said user has joined the challenge.
    private(set) var rows: [Row] = []
    
    private let displayMode: Mode
    
    // MARK: Init
    
    init(challenge: Challenge, challengeRepository: UserDataRepository<Challenge>, mode: Mode = .fullTable) {
        self.challengeRepository = challengeRepository
        self.challengeId = challenge.identifier
        self.displayMode = mode
        super.init()
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
        generateRows(forChallenge: challenge)
    }
    
    private func generateRows(forChallenge challenge: Challenge) {
        var rows: [Row] = []
        var userAssociatedRow: Row?
        
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
                userAssociatedRow = row
            }
            rows.append(row)
            rank += 1
        }
        
        switch displayMode {
        case .widget:
            rows = modifyRowsForWidget(rows, userAssociatedRow: userAssociatedRow)
        case .fullTable:
            rows = modifyRowsForFullTable(rows, userAssociatedRow: userAssociatedRow)
        }
        
        self.rows = rows
    }
    
    private func modifyRowsForWidget(originalRows: [Row], userAssociatedRow: Row?) -> [Row] {
        guard let userAssociatedRow = userAssociatedRow else { return [] }
        if originalRows.isEmpty { return [] }
        if originalRows.count == 1 { return originalRows } // User is associated with only participant and is in first
        
        // originalRows is guaranteed to have at least two rows here
        
        if !challenge.isCompetitive {
            return [userAssociatedRow]
        }
        
        guard let userAssociatedRank = userAssociatedRow.rank else { return [] } // bad state
        
        if userAssociatedRank == 1 {
            return [userAssociatedRow, originalRows[1]]
        }
        
        let indexOfUser = userAssociatedRank - 1
        let indexAboveUser = indexOfUser - 1
        let participantAboveUser = originalRows[indexAboveUser]
        
        return [participantAboveUser, userAssociatedRow]
    }
    
    private func modifyRowsForFullTable(originalRows: [Row], userAssociatedRow: Row?) -> [Row] {
        guard let userAssociatedRow = userAssociatedRow else { return originalRows }
        guard let userAssociatedRank = userAssociatedRow.rank else { return [] } // bad state
        var rows = originalRows
        let indexOfUser = userAssociatedRank - 1
        rows.removeAtIndex(indexOfUser)
        rows.insert(userAssociatedRow, atIndex: 0)
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

// MARK: - Table Data Source

extension ChallengeParticipantController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection._count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch section {
        case TableSection.HeaderSection.rawValue:
            guard shouldShowProgress() else { return 0 }
            guard rows.count > 0 else { return 0 } // can happen when in a widget, and the user is not in the challenge yet
            switch challenge.template {
            case .individualGoalAccumulation: numberOfRows = 1
            case .individualGoalFrequency: break
            case .individualCompetitive: break
            case .individualCompetitiveGoal: numberOfRows = 1
            case .teamGoalAccumulation: numberOfRows = 1
            case .teamCompetitive: break
            case .teamCompetitiveGoal: numberOfRows = 1
            }
        case TableSection.ChallengeParticipaters.rawValue:
            return rows.count
        case TableSection._count.rawValue:
            break
        default:
            break
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let sectionType = TableSection(rawValue: indexPath.section) else { fatalError("Invalid table section") }
        
        let cell: UITableViewCell
        switch sectionType {
        case TableSection.HeaderSection:
            switch challenge.template {
            case .individualGoalAccumulation: cell = goalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            case .individualGoalFrequency: fatalError("No cell for section")
            case .individualCompetitive: fatalError("No cell for section")
            case .individualCompetitiveGoal: cell = goalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            case .teamGoalAccumulation: cell = goalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            case .teamCompetitive: fatalError("No cell for section")
            case .teamCompetitiveGoal: cell = goalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            }
            
        case TableSection.ChallengeParticipaters:
            switch challenge.template {
            case .individualGoalAccumulation: cell = individualGoalAccumulationCell(for: tableView, indexPath: indexPath)
            case .individualGoalFrequency: fatalError("individualGoalFrequency is a planned feature, not implemented in the backend yet.")
            case .individualCompetitive: cell = individualCompetitiveCell(for: tableView, for: indexPath)
            case .individualCompetitiveGoal: cell = individualCompetitiveGoalCell(for: tableView, for: indexPath)
            case .teamGoalAccumulation: cell = teamGoalAccumulationCell(for: tableView, for: indexPath)
            case .teamCompetitive: cell = teamCompetitiveCell(for: tableView, for: indexPath)
            case .teamCompetitiveGoal: cell = teamCompetitiveGoalCell(for: tableView, for: indexPath)
            }
            
        case TableSection._count:
            fatalError("Invalid section")
        }
        
        cell.selectionStyle = .None
        return cell
    }
    
}

// MARK: - Cell Configuration

extension ChallengeParticipantController {
    
    // MARK: goalAccumulationHeaderCell
    
    private func goalAccumulationHeaderCell(for tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeProgressHeaderTableViewCell.self, forIndexPath: indexPath)
        cell.numberOfPointsLabel.text = "\(Int(challenge.maxPoints ?? 0))"
        return cell
    }
    
    // MARK: individualGoalAccumulation
    
    private func individualGoalAccumulationCell(for tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeProgressTableViewCell.self, forIndexPath: indexPath)
        cell.reset()
        
        let participater = rows[indexPath.row].challengeParticipant
        
        cell.userNameLabel.text = participater.name
        
        if shouldShowProgress() {
            if let participatorImage = participater.image {
                cell.challengeProgressView.userImageView.setImage(withMediaAsset: participatorImage)
            }
            
            cell.challengeProgressView.progressColor = progressColorForParticipator(participater)
            
            if let maxUnits = maxUnits {
                cell.challengeProgressView.progress = CGFloat(participater.units/maxUnits)
            }
            
            cell.challengeProgressView.progressMilestones = challenge.winConditionProportions
        }
        
        return cell
    }
    
    // MARK: individualCompetitiveCell
    
    private func individualCompetitiveCell(for tableView: UITableView, for indexPath: NSIndexPath) -> ChallengeLeaderboardTableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeLeaderboardTableViewCell.self, forIndexPath: indexPath)
        cell.reset()
        
        let row = rows[indexPath.row]
        let participater = row.challengeParticipant
        if let participatorImage = participater.image {
            cell.avatarImageView.setImage(withMediaAsset: participatorImage)
        }
        cell.nameLabel.text = participater.name
        
        configureCompetitiveProgressView(for: cell, participaterRow: row)
        return cell
    }
    
    private func configureCompetitiveProgressView(for cell: ChallengeLeaderboardTableViewCell, participaterRow: Row) {
        guard let maxUnits = maxUnits where shouldShowProgress() else {
            cell.setProgressViewHidden(true)
            cell.dashedLineView.hidden = true
            return
        }
        
        cell.challengeProgressView.progressColor = progressColorForParticipator(participaterRow.challengeParticipant)
        
        cell.isCompetitive = true
        
        let wattCountFormat = NSLocalizedString("CHALLENGE_LEADERBOARD_WATT_COUNT_SINGLE_PLURAL", comment: "Format for the number of watts a user has, like, '1500 watts'.")
        let wattsCountText = String(format: wattCountFormat, arguments: [Int(participaterRow.challengeParticipant.units)])
        cell.challengeProgressView.wattsLabel.text = wattsCountText
        
        if let rank = participaterRow.rank {
            cell.placementLabel.text = ChallengeUtility.getRankWithSuffix(rank)
        }
        cell.placementLabel.setNeedsLayout()
        cell.placementLabel.layoutIfNeeded() // Fixes label layout issues
        
        let progressViewWidthProportion = CGFloat(participaterRow.challengeParticipant.units/maxUnits)
        cell.setProgressViewProportion(progressViewWidthProportion)
        
        cell.challengeProgressView.setNeedsLayout() // need to layout to update bar and watts label truncation
    }
    
    private func progressColorForParticipator(participator: ChallengeParticipating) -> UIColor {
        let isCurrentUser = isUser(associatedWithChallengeParticipater: participator)
        return isCurrentUser ? Theme.Color.Challenge.Detail.Participants.userprogressTint : Theme.Color.Challenge.Detail.Participants.progressTint
    }
    
    // MARK: individualGoalCompetitiveCell
    
    private func individualCompetitiveGoalCell(for tableView: UITableView, for indexPath: NSIndexPath) -> UITableViewCell {
        let cell = individualCompetitiveCell(for: tableView, for: indexPath)
        cell.hasGoal = shouldShowProgress()
        if goalReached(for: rows[indexPath.row].challengeParticipant) {
            cell.goalReached = true
            let goalReachedText = NSLocalizedString("CHALLENGE_LEADERBOARD_GOAL_REACHED_TEXT", comment: "Text for telling the user they reached their goal.")
            cell.challengeProgressView.wattsLabel.text = goalReachedText
            cell.challengeProgressView.progressMilestones = [1.0]
        } else {
            cell.goalReached = false
            cell.challengeProgressView.progressMilestones = []
        }
        return cell
    }
    
    private func goalReached(for participator: ChallengeParticipating) -> Bool {
        let maxPoints = challenge.maxPoints ?? 0
        return participator.units >= maxPoints
    }
    
    // MARK: teamCompetitiveCell
    
    private func teamCompetitiveCell(for tableView: UITableView, for indexPath: NSIndexPath) -> ChallengeLeaderboardTableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeLeaderboardTableViewCell.self, forIndexPath: indexPath)
        cell.reset()
        
        let row = rows[indexPath.row]
        let participater = row.challengeParticipant
        if let participatorImage = participater.image {
            cell.avatarImageView.setImage(withMediaAsset: participatorImage)
        }
        
        if let teamParticipater = participater as? Challenge.Team {
            cell.isTeamCell = true
            let isUserAssociated = isUser(associatedWithChallengeParticipater: teamParticipater)
            cell.nameLabel.text = teamParticipater.name
            if isUserAssociated {
                cell.yourTeamLabel.text = NSLocalizedString("CHALLENGE_LEADERBOARD_YOUR_TEAM_TEXT", comment: "Text for telling the user that this is their team.")
            }
            
            cell.setProgressViewHidden(false)
            configureCompetitiveProgressView(for: cell, participaterRow: rows[indexPath.row])
            
            if teamParticipater.memberCount > 0 {
                cell.chevronImageView.alpha = 1.0
            }
        } else if participater is Challenge.Participant {
            cell.isTeamCell = false
            cell.nameLabel.text = participater.name
            cell.yourTeamLabel.text = nil
            
            cell.setProgressViewHidden(true)
            cell.chevronImageView.alpha = 0.0
        }
        
        if row.showingSubrows {
            cell.chevronDirection = .down
        } else {
            cell.chevronDirection = .right
        }
        
        return cell
    }
    
    // MARK: teamCompetitiveGoalCell
    private func teamCompetitiveGoalCell(for tableView: UITableView, for indexPath: NSIndexPath) -> UITableViewCell {
        let cell = teamCompetitiveCell(for: tableView, for: indexPath)
        cell.hasGoal = shouldShowProgress()
        return cell
    }
    
    // MARK: teamGoalAccumulationCell
    
    private func teamGoalAccumulationCell(for tableView: UITableView, for indexPath: NSIndexPath) -> UITableViewCell {
        let cell = teamCompetitiveCell(for: tableView, for: indexPath)
        cell.hasGoal = shouldShowProgress()
        cell.isCompetitive = false
        
        let participater = rows[indexPath.row].challengeParticipant
        
        if participater is Challenge.Team {
            cell.avatarImageView.hidden = true
        } else {
            cell.avatarImageView.hidden = false
        }
        
        if shouldShowProgress() && participater is Challenge.Team {
            cell.setProgressViewHidden(false)
            cell.challengeProgressView.userImageView.hidden = false
            if let participatorImage = participater.image {
                cell.challengeProgressView.userImageView.setImage(withMediaAsset: participatorImage)
            }
            
            cell.challengeProgressView.progressColor = progressColorForParticipator(participater)
            
            if let maxUnits = maxUnits {
                cell.challengeProgressView.progress = CGFloat(participater.units/maxUnits)
            }
            
            cell.challengeProgressView.progressMilestones = challenge.winConditionProportions
            
            cell.challengeProgressView.wattsLabel.text = ""
            
            cell.placementLabel.text = ""
            cell.placementLabel.setNeedsLayout()
            cell.placementLabel.layoutIfNeeded() // Fixes label layout issues
            
            cell.setProgressViewProportion(1.0)
        } else {
            cell.setProgressViewHidden(true)
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ChallengeParticipantController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        (tableView.cellForRowAtIndexPath(indexPath) as? ChallengeLeaderboardTableViewCell)?.toggleChevronDirection()
        
        let row = rows[indexPath.row]
        let subrows = row.subrows
        let indexPathsToModify = subrows.indices.map({
            return NSIndexPath(forRow: indexPath.row + 1 + $0, inSection: indexPath.section)
        })
        if row.showingSubrows {
            guard !indexPathsToModify.isEmpty else { return }
            let removalRange = (indexPath.row + 1)..<(indexPath.row + 1 + subrows.count)
            rows.removeRange(removalRange)
            tableView.deleteRowsAtIndexPaths(indexPathsToModify, withRowAnimation: .Automatic)
        } else {
            rows.insertContentsOf(row.subrows, at: indexPath.row + 1)
            tableView.insertRowsAtIndexPaths(indexPathsToModify, withRowAnimation: .Automatic)
        }
        rows[indexPath.row].showingSubrows = !row.showingSubrows
    }
}

// MARK: - Helpers

extension ChallengeParticipantController {
    private func shouldShowProgress() -> Bool {
        guard let maxUnits = maxUnits where challenge.status != .registration &&
            challenge.status != .canceled &&
            maxUnits > 0 else { return false}
        return true
    }
}

// MARK: - Inner classes

extension ChallengeParticipantController {
    enum TableSection: Int  {
        case HeaderSection
        case ChallengeParticipaters
        case _count
    }
    
    /// View model for each row in the partipants table
    struct Row {
        let challengeParticipant: ChallengeParticipating
        let subrows: [Row] // TODO: Peter Ryszkiewicz: Optimize with lazy lookup
        var showingSubrows = false
        let rank: Int? // Maybe we could make it non-optional
    }
    
    enum Mode {
        case fullTable
        case widget
    }
    
}
