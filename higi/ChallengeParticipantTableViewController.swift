//
//  ChallengeParticipantTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeParticipantTableViewController: UIViewController {
    
    // Properties
    
    lazy var progressViewHeight: CGFloat = 10
    lazy var progressViewCornerRadius: CGFloat = self.progressViewHeight / 2

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
            tableView.allowsSelection = false
        }
    }
    
    // Injected
    
    private var challengeParticipantController: ChallengeParticipantController!
}

// MARK: - Dependency Injection

extension ChallengeParticipantTableViewController {
    
    func configure(withChallenge challenge: Challenge, challengeRepository: UserDataRepository<Challenge>) {
        self.challengeParticipantController = ChallengeParticipantController(challenge: challenge, challengeRepository: challengeRepository)
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
            case .teamGoalAccumulation: break
            case .teamCompetitive: break
            case .teamCompetitiveGoal: break
            }
        case TableSection.ChallengeParticipaters.rawValue:
            return challengeParticipantController.participaters.count
        case TableSection._count.rawValue:
            break
        default:
            break
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let sectionType = TableSection(rawValue: indexPath.section) else { fatalError("Invalid table section") }

        switch sectionType {
        case TableSection.HeaderSection:
            switch challengeParticipantController.challenge.template {
            case .individualGoalAccumulation: return individualGoalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            case .individualGoalFrequency: fatalError("No cell for section")
            case .individualCompetitive: fatalError("No cell for section")
            case .individualCompetitiveGoal: return individualGoalAccumulationHeaderCell(for: tableView, indexPath: indexPath)
            case .teamGoalAccumulation: fatalError("No cell for section")
            case .teamCompetitive: fatalError("No cell for section")
            case .teamCompetitiveGoal: fatalError("No cell for section")
            }
            
        case TableSection.ChallengeParticipaters:
            switch challengeParticipantController.challenge.template {
            case .individualGoalAccumulation: return individualGoalAccumulationCell(for: tableView, indexPath: indexPath)
            case .individualGoalFrequency: fatalError("Not implemented")
            case .individualCompetitive: return individualCompetitiveCell(for: tableView, for: indexPath)
            case .individualCompetitiveGoal: return individualCompetitiveGoalCell(for: tableView, for: indexPath)
            case .teamGoalAccumulation: fatalError("Not implemented")
            case .teamCompetitive: fatalError("Not implemented")
            case .teamCompetitiveGoal: fatalError("Not implemented")
            }
            
        case TableSection._count:
            fatalError("Invalid section")
        }

    }
    
}

// MARK: - Cell Configuration

extension ChallengeParticipantTableViewController {
    
    // MARK: individualGoalAccumulation
    
    private func individualGoalAccumulationHeaderCell(for tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeProgressHeaderTableViewCell.self, forIndexPath: indexPath)
        cell.numberOfPointsLabel.text = "\(Int(challengeParticipantController.challenge.maxPoints ?? 0))"
        return cell
    }
    
    private func individualGoalAccumulationCell(for tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChallengeProgressTableViewCell.self, forIndexPath: indexPath)
        cell.reset()
        
        let participater = challengeParticipantController.participaters[indexPath.row]
        
        cell.userNameLabel.text = participater.name
        if let participatorImage = participater.image {
            cell.challengeProgressView.userImageView.setImage(withMediaAsset: participatorImage)
        }
        
        let isCurrentUser = challengeParticipantController.isUser(associatedWithChallengeParticipater: participater)
        cell.challengeProgressView.progressColor = isCurrentUser ? Theme.Color.Challenge.Detail.Participants.userprogressTint : Theme.Color.Challenge.Detail.Participants.progressTint
        
        if let maxUnits = challengeParticipantController.maxUnits {
            cell.challengeProgressView.progress = CGFloat(participater.units/maxUnits)
        }
        
        if let winConditionProportions = challengeParticipantController.challenge.winConditionProportions {
            cell.challengeProgressView.progressMilestones = winConditionProportions
        }
        
        return cell
    }
    
    // MARK: individualCompetitiveCell

    private func individualCompetitiveCell(for tableView: UITableView, for indexPath: NSIndexPath) -> ChallengeLeaderboardTableViewCell {
        let participantCell = tableView.dequeueReusableCell(withClass: ChallengeLeaderboardTableViewCell.self, forIndexPath: indexPath)
        participantCell.reset()
        
        let participater = challengeParticipantController.participaters[indexPath.row]
        if let participatorImage = participater.image {
            participantCell.avatarImageView.setImage(withMediaAsset: participatorImage)
        }
        participantCell.nameLabel.text = participater.name
        
        if challengeParticipantController.challenge.status != .registration &&
            challengeParticipantController.challenge.status != .canceled &&
            challengeParticipantController.maxUnits > 0 {
            
            let isCurrentUser = challengeParticipantController.isUser(associatedWithChallengeParticipater: participater)
            if let maxUnits = challengeParticipantController.maxUnits {
                configureProgressView(for: participantCell, participater: participater, maxValue: maxUnits, isCurrentUser: isCurrentUser)
            }
        }
        return participantCell
    }
    
    private func configureProgressView(for cell: ChallengeLeaderboardTableViewCell, participater: RankedChallengeParticipating, maxValue: Double, isCurrentUser: Bool) {
        cell.challengeProgressView.height = ChallengeProgressView.heightForCompetitiveBar
        let wattCountFormat = NSLocalizedString("CHALLENGE_LEADERBOARD_WATT_COUNT_SINGLE_PLURAL", comment: "Format for the number of watts a user has, like, '1500 watts'.")
        let wattsCountText = String(format: wattCountFormat, arguments: [Int(participater.units)])
        cell.challengeProgressView.wattsLabel.text = wattsCountText
        cell.challengeProgressView.progressColor = isCurrentUser ? Theme.Color.Challenge.Detail.Participants.userprogressTint : Theme.Color.Challenge.Detail.Participants.progressTint
        
        cell.placementLabel.text = ChallengeUtility.getRankWithSuffix(participater.rank)
        
        let progressViewWidthProportion = CGFloat(participater.units/maxValue)
        cell.minimumProgressViewWidth = ChallengeProgressView.heightForCompetitiveBar
        cell.setProgressViewProportion(progressViewWidthProportion)
        
        cell.challengeProgressView.setNeedsLayout() // need to layout to update bar and watts label truncation
    }
    
    // MARK: individualGoalCompetitiveCell

    private func individualCompetitiveGoalCell(for tableView: UITableView, for indexPath: NSIndexPath) -> UITableViewCell {
        let participantCell = individualCompetitiveCell(for: tableView, for: indexPath)
        participantCell.hasGoal = true
        return participantCell
    }

}

extension ChallengeParticipantTableViewController {
    enum TableSection: Int  {
        case HeaderSection
        case ChallengeParticipaters
        case _count
    }
}

