//
//  ChallengeLeaderboardTableViewCell.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/26/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeLeaderboardTableViewCell: UITableViewCell {
    
    /// MARK: Outlets
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var placementLabel: UILabel!
    @IBOutlet var challengeProgressViewContainer: UIView!
    @IBOutlet var challengeProgressView: ChallengeProgressView! {
        didSet {
            challengeProgressView.userImageView.hidden = true
        }
    }
    
    @IBOutlet var challengeProgressWidthConstraint: NSLayoutConstraint!
    
    private var proportion: CGFloat = 1.0 {
        didSet {
            configureProgressBarConstraint()
        }
    }
}

// MARK: - Helpers

extension ChallengeLeaderboardTableViewCell {
    
    func reset() {
        avatarImageView.image = UIImage(named: "profile-placeholder")
        nameLabel.text = nil
    }
    
    // This is how large the progress view should be relative to its superview
    func setProgressViewProportion(proportion: CGFloat) {
        self.proportion = proportion
    }
}

// MARK: - Lifecycle

extension ChallengeLeaderboardTableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureProgressBarConstraint()
    }
    
    private func configureProgressBarConstraint() {
        layoutIfNeeded()
        challengeProgressWidthConstraint.constant = proportion * challengeProgressViewContainer.bounds.width
    }
}

