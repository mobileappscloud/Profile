//
//  ChallengeWinnerTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/1/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeWinnerTableViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.estimatedSectionHeaderHeight = 60.0
            tableView.sectionHeaderHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 70.0
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.sectionFooterHeight = CGFloat.min
                        
            tableView.register(nibWithHeaderFooterClass: ChallengeWinnerTableViewHeaderView.self)
            tableView.register(nibWithCellClass: ChallengeParticipantTableViewCell.self)
            tableView.separatorStyle = .None
            tableView.allowsSelection = false
        }
    }
    
    private var challengeWinnerController: ChallengeWinnerController!
}

extension ChallengeWinnerTableViewController {
    
    func configure(withChallenge challenge: Challenge) {
        self.challengeWinnerController = ChallengeWinnerController(challenge: challenge)
    }
}

// MARK: - Table Data Source

extension ChallengeWinnerTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return challengeWinnerController.challenge.winConditions.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let winCondition = challengeWinnerController.challenge.winConditions[section]
        let rowCount = winCondition.winners?.count ?? 0
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let winCondition = challengeWinnerController.challenge.winConditions[indexPath.section]
        guard let winners = winCondition.winners else { fatalError("Attempted to produce cell for challenge winner, but winCondition.winners is nil.") }
        
        let participantCell = tableView.dequeueReusableCell(withClass: ChallengeParticipantTableViewCell.self, forIndexPath: indexPath)
        participantCell.reset()
        
        let winner = winners[indexPath.row]
        let winnerParticipater: ChallengeParticipating?
        switch winCondition.winnerType {
        case .individual:
            winnerParticipater = winner.participant
        case .team:
            winnerParticipater = winner.team
        }
        guard let participater = winnerParticipater else { fatalError("Unable to produce the expected challenge participating entity.") }
        
        participantCell.avatarImageView.setImage(withMediaAsset: participater.image)
        participantCell.nameLabel.text = participater.name
        
        if let prize = winCondition.prize {
            let prizeLabel = UILabel()
            prizeLabel.numberOfLines = 0
            prizeLabel.text = prize.name
            participantCell.contentStackView.addArrangedSubview(prizeLabel)
        }
        
        return participantCell
    }
}

// MARK: - Table Delegate

extension ChallengeWinnerTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueResuableHeaderFooterView(withClass: ChallengeWinnerTableViewHeaderView.self) else { return nil }
        
        let winCondition = challengeWinnerController.challenge.winConditions[section]
        headerView.headerLabel.text = winCondition.name
        headerView.detailLabel.text = winCondition.prize?.name
        
        return headerView
    }
}
