//
//  ChallengeDetailUserProgressTableViewCell.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class ChallengeDetailUserProgressTableViewCell: UITableViewCell {
    
    // Outlets
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 70.0
            tableView.rowHeight = UITableViewAutomaticDimension
            
            tableView.tableFooterView = UIView()
            
            tableView.register(nibWithCellClass: ChallengeLeaderboardTableViewCell.self)
            tableView.register(nibWithCellClass: ChallengeProgressTableViewCell.self)
            tableView.register(nibWithCellClass: ChallengeProgressHeaderTableViewCell.self)
            
            tableView.separatorStyle = .None

            tableView.scrollEnabled = false
            
            tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: &self.kvoContext)
        }
    }
    
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var daysRemainingLabel: UILabel!
    
    @IBOutlet var goalReachedStackView: UIStackView!
    @IBOutlet var goalReachedLabel: UILabel!
    
    // Injected
    
    private var challengeParticipantController: ChallengeParticipantController!
    
    // Properties
    
    private var kvoContext = 1
    
    var sizeChangedCallback: (() -> ())?

    // Deinit
    
    deinit {
        tableView?.removeObserver(self, forKeyPath: "contentSize")
    }

}

// MARK: - Lifecycle

extension ChallengeDetailUserProgressTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        if tableViewHeightConstraint.constant != tableView.contentSize.height {
            tableViewHeightConstraint.constant = tableView.contentSize.height
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
            setNeedsLayout()
            layoutIfNeeded()
            sizeChangedCallback?()
        }
    }
}
// MARK: - Dependency Injection

extension ChallengeDetailUserProgressTableViewCell {
    
    func configure(withChallenge challenge: Challenge, challengeRepository: UserDataRepository<Challenge>) {
        if challengeParticipantController?.challenge === challenge { return }
        self.challengeParticipantController = ChallengeParticipantController(challenge: challenge, challengeRepository: challengeRepository, mode: .widget)
        challengeParticipantController.refreshCalculatedProperties()
        tableView.delegate = challengeParticipantController
        tableView.dataSource = challengeParticipantController
        tableView.reloadData()
    }
}

// MARK: - Helpers

extension ChallengeDetailUserProgressTableViewCell {
    private func updateTableHeightConstraint() {
        if tableViewHeightConstraint.constant != tableView.contentSize.height {
            tableViewHeightConstraint.constant = tableView.contentSize.height
        }
    }
}

// MARK: - KVO

extension ChallengeDetailUserProgressTableViewCell {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &kvoContext else { return }
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case "contentSize":
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
            updateTableHeightConstraint()
            sizeChangedCallback?()
        default:
            return
        }
    }
}