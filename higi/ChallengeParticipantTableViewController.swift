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
            tableView.delegate = challengeParticipantController
            tableView.dataSource = challengeParticipantController
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
