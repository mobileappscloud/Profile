//
//  ChallengeParticipantTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 9/6/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ChallengeParticipantTableViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 70.0
            tableView.rowHeight = UITableViewAutomaticDimension
            
            tableView.tableFooterView = UIView()
            
            tableView.register(nibWithCellClass: ChallengeParticipantTableViewCell.self)
            tableView.separatorStyle = .None
            tableView.allowsSelection = false
        }
    }
    
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challengeParticipantController.participaters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let participantCell = tableView.dequeueReusableCell(withClass: ChallengeParticipantTableViewCell.self, forIndexPath: indexPath)
        participantCell.reset()
        
        let participater = challengeParticipantController.participaters[indexPath.row]
        participantCell.avatarImageView.setImage(withMediaAsset: participater.image)
        participantCell.nameLabel.text = participater.name
        
        if challengeParticipantController.challenge.status != .registration &&
            challengeParticipantController.challenge.status != .canceled &&
            challengeParticipantController.maxUnits > 0 {
            
            let isCurrentUser = challengeParticipantController.isUser(associatedWithChallengeParticipater: participater)
            let progressBar = progressView(forParticipater: participater, maxValue: challengeParticipantController.maxUnits, isCurrentUser: isCurrentUser)
            participantCell.contentStackView.addArrangedSubview(progressBar)
        }
        
        return participantCell
    }
    
    private func progressView(forParticipater participater: ChallengeParticipating, maxValue: Double, isCurrentUser: Bool) -> UIProgressView {
        
        let progressViewHeight: CGFloat = 16.0
        let cornerRadius = progressViewHeight/2
        
        let progressView = UIProgressView(progressViewStyle: .Bar)
        progressView.heightAnchor.constraintEqualToConstant(progressViewHeight).active = true
        progressView.layer.cornerRadius = cornerRadius
        progressView.layer.masksToBounds = true
        progressView.progress = Float(participater.units/maxValue)
        progressView.progressTintColor = isCurrentUser ? Theme.Color.Challenge.Detail.Participants.userprogressTint : Theme.Color.Challenge.Detail.Participants.progressTint
        return progressView
    }
}
