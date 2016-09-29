//
//  ChallengeParticipantTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeParticipantTableViewController: UIViewController {

    // Outlets
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 70.0
            tableView.rowHeight = UITableViewAutomaticDimension
            
            tableView.tableFooterView = UIView()
            
            tableView.register(nibWithCellClass: ChallengeLeaderboardTableViewCell.self)
            tableView.register(nibWithCellClass: ChallengeProgressTableViewCell.self)
            tableView.register(nibWithCellClass: ChallengeProgressHeaderTableViewCell.self)
            
            tableView.separatorStyle = .None
        }
    }
    
    // Injected
    
    private var challengeParticipantController: ChallengeParticipantController!
}

// MARK: - Dependency Injection

extension ChallengeParticipantTableViewController {
    
    func configure(withChallenge challenge: Challenge, challengeRepository: UserDataRepository<Challenge>) {
        self.challengeParticipantController = ChallengeParticipantController(challenge: challenge, challengeRepository: challengeRepository, delegate: self)
    }
}

// MARK: - View Lifecycle

extension ChallengeParticipantTableViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        challengeParticipantController.refreshCalculatedProperties()
    }
}

// MARK: - Table Data Source

extension ChallengeParticipantTableViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection._count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch section {
        case TableSection.HeaderSection.rawValue:
            switch challengeParticipantController.challenge.template {
            case .individualGoalAccumulation: numberOfRows = 1
            case .individualGoalFrequency: break
            case .individualCompetitive: break
            case .individualCompetitiveGoal: numberOfRows = 1
            case .teamGoalAccumulation: numberOfRows = 1
            case .teamCompetitive: break
            case .teamCompetitiveGoal: numberOfRows = 1
            }
        case TableSection.ChallengeParticipaters.rawValue:
            return challengeParticipantController.rows.count
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
            switch challengeParticipantController.challenge.template {
            case .individualGoalAccumulation: cell = goalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            case .individualGoalFrequency: fatalError("No cell for section")
            case .individualCompetitive: fatalError("No cell for section")
            case .individualCompetitiveGoal: cell = goalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            case .teamGoalAccumulation: cell = goalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            case .teamCompetitive: fatalError("No cell for section")
            case .teamCompetitiveGoal: cell = goalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            }
            
        case TableSection.ChallengeParticipaters:
            switch challengeParticipantController.challenge.template {
            case .individualGoalAccumulation: cell = individualGoalAccumulationCell(for: tableView, indexPath: indexPath)
            case .individualGoalFrequency: fatalError("Not implemented")
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

extension ChallengeParticipantTableViewController {
    
    // MARK: individualGoalAccumulation
    
    private func goalAccumulationHeaderCell(for tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeProgressHeaderTableViewCell.self, forIndexPath: indexPath)
        cell.numberOfPointsLabel.text = "\(Int(challengeParticipantController.challenge.maxPoints ?? 0))"
        return cell
    }
    
    private func individualGoalAccumulationCell(for tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeProgressTableViewCell.self, forIndexPath: indexPath)
        cell.reset()
        
        let participater = challengeParticipantController.rows[indexPath.row].challengeParticipant
        
        cell.userNameLabel.text = participater.name
        
        if shouldShowProgress() {
            if let participatorImage = participater.image {
                cell.challengeProgressView.userImageView.setImage(withMediaAsset: participatorImage)
            }
            
            cell.challengeProgressView.progressColor = progressColorForParticipator(participater)
            
            if let maxUnits = challengeParticipantController.maxUnits {
                cell.challengeProgressView.progress = CGFloat(participater.units/maxUnits)
            }
            
            if let winConditionProportions = challengeParticipantController.challenge.winConditionProportions {
                cell.challengeProgressView.progressMilestones = winConditionProportions
            }
        }
        
        return cell
    }
    
    // MARK: individualCompetitiveCell

    private func individualCompetitiveCell(for tableView: UITableView, for indexPath: NSIndexPath) -> ChallengeLeaderboardTableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeLeaderboardTableViewCell.self, forIndexPath: indexPath)
        cell.reset()
        
        let row = challengeParticipantController.rows[indexPath.row]
        let participater = row.challengeParticipant
        if let participatorImage = participater.image {
            cell.avatarImageView.setImage(withMediaAsset: participatorImage)
        }
        cell.nameLabel.text = participater.name
        
        configureCompetitiveProgressView(for: cell, participaterRow: row)
        return cell
    }
    
    private func configureCompetitiveProgressView(for cell: ChallengeLeaderboardTableViewCell, participaterRow: ChallengeParticipantController.Row) {
        guard let maxUnits = challengeParticipantController.maxUnits where shouldShowProgress() else { return }
        
        cell.challengeProgressView.progressColor = progressColorForParticipator(participaterRow.challengeParticipant)
        
        cell.isCompetitive = true

        let wattCountFormat = NSLocalizedString("CHALLENGE_LEADERBOARD_WATT_COUNT_SINGLE_PLURAL", comment: "Format for the number of watts a user has, like, '1500 watts'.")
        let wattsCountText = String(format: wattCountFormat, arguments: [Int(participaterRow.challengeParticipant.units)])
        cell.challengeProgressView.wattsLabel.text = wattsCountText
        
        if let rank = participaterRow.rank {
            cell.placementLabel.text = ChallengeUtility.getRankWithSuffix(rank)
        }

        let progressViewWidthProportion = CGFloat(participaterRow.challengeParticipant.units/maxUnits)
        cell.setProgressViewProportion(progressViewWidthProportion)
        
        cell.challengeProgressView.setNeedsLayout() // need to layout to update bar and watts label truncation
    }
    
    private func progressColorForParticipator(participator: ChallengeParticipating) -> UIColor {
        let isCurrentUser = challengeParticipantController.isUser(associatedWithChallengeParticipater: participator)
        return isCurrentUser ? Theme.Color.Challenge.Detail.Participants.userprogressTint : Theme.Color.Challenge.Detail.Participants.progressTint
    }
    
    // MARK: individualGoalCompetitiveCell

    private func individualCompetitiveGoalCell(for tableView: UITableView, for indexPath: NSIndexPath) -> UITableViewCell {
        let cell = individualCompetitiveCell(for: tableView, for: indexPath)
        cell.hasGoal = true
        if goalReached(for: challengeParticipantController.rows[indexPath.row].challengeParticipant) {
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
        let maxPoints = challengeParticipantController.challenge.maxPoints ?? 0
        return participator.units >= maxPoints
    }
    
    // MARK: teamCompetitiveCell

    private func teamCompetitiveCell(for tableView: UITableView, for indexPath: NSIndexPath) -> ChallengeLeaderboardTableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeLeaderboardTableViewCell.self, forIndexPath: indexPath)
        cell.reset()
        
        let participater = challengeParticipantController.rows[indexPath.row].challengeParticipant
        if let participatorImage = participater.image {
            cell.avatarImageView.setImage(withMediaAsset: participatorImage)
        }
        
        if let teamParticipater = participater as? Challenge.Team {
            cell.isTeamCell = true
            let isUserAssociated = challengeParticipantController.isUser(associatedWithChallengeParticipater: teamParticipater)
            cell.nameLabel.text = teamParticipater.name
            if isUserAssociated {
                cell.yourTeamLabel.text = NSLocalizedString("CHALLENGE_LEADERBOARD_YOUR_TEAM_TEXT", comment: "Text for telling the user that this is their team.")
            }
            
            cell.setProgressViewHidden(false)
            configureCompetitiveProgressView(for: cell, participaterRow: challengeParticipantController.rows[indexPath.row])
            
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

        return cell
    }
    
    // MARK: teamCompetitiveGoalCell
    private func teamCompetitiveGoalCell(for tableView: UITableView, for indexPath: NSIndexPath) -> UITableViewCell {
        let cell = teamCompetitiveCell(for: tableView, for: indexPath)
        cell.hasGoal = true
        return cell
    }

    // MARK: teamGoalAccumulationCell
    
    private func teamGoalAccumulationCell(for tableView: UITableView, for indexPath: NSIndexPath) -> UITableViewCell {
        let cell = teamCompetitiveCell(for: tableView, for: indexPath)
        cell.hasGoal = true
        cell.isCompetitive = false
        
        let participater = challengeParticipantController.rows[indexPath.row].challengeParticipant
        
        if participater is Challenge.Team {
            cell.avatarImageView.hidden = true
        } else {
            cell.avatarImageView.hidden = false
        }

        if shouldShowProgress() && participater is Challenge.Team {
            cell.setProgressViewHidden(false)
            if let participatorImage = participater.image {
                cell.challengeProgressView.userImageView.setImage(withMediaAsset: participatorImage)
            }
            
            cell.challengeProgressView.progressColor = progressColorForParticipator(participater)
            
            if let maxUnits = challengeParticipantController.maxUnits {
                cell.challengeProgressView.progress = CGFloat(participater.units/maxUnits)
            }
            
            if let winConditionProportions = challengeParticipantController.challenge.winConditionProportions {
                cell.challengeProgressView.progressMilestones = winConditionProportions
            }
            
            cell.challengeProgressView.wattsLabel.text = ""
            cell.setProgressViewProportion(1.0)
        } else {
            cell.setProgressViewHidden(true)
        }

        return cell
    }

}

// MARK: - UITableViewDelegate

extension ChallengeParticipantTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        (tableView.cellForRowAtIndexPath(indexPath) as? ChallengeLeaderboardTableViewCell)?.toggleChevronDirection()
        
        challengeParticipantController.didSelectRowAtIndexPath(indexPath)
    }
}

// MARK: - ChallengeParticipantControllerDelegate

extension ChallengeParticipantTableViewController: ChallengeParticipantControllerDelegate {
    func insertRowsAt(indexPaths indexPaths: [NSIndexPath]) {
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    func removeRowsAt(indexPaths indexPaths: [NSIndexPath]) {
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
}

// MARK: - Helpers

extension ChallengeParticipantTableViewController {
    private func shouldShowProgress() -> Bool {
        guard let maxUnits = challengeParticipantController.maxUnits where challengeParticipantController.challenge.status != .registration &&
            challengeParticipantController.challenge.status != .canceled &&
            maxUnits > 0 else { return false}
        return true
    }
}

extension ChallengeParticipantTableViewController {
    enum TableSection: Int  {
        case HeaderSection
        case ChallengeParticipaters
        case _count
    }
}

