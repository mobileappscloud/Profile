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
    
    @IBOutlet var dashedLineView: ChallengeVerticalDashedLineView!
    
    // Properties
    
    private var proportion: CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var hasGoal: Bool = false {
        didSet {
            dashedLineView.hidden = !hasGoal
        }
    }
    
    var minimumProgressViewWidth = ChallengeProgressView.heightForNonCompetitiveBar
}

// MARK: - Helpers

extension ChallengeLeaderboardTableViewCell {
    
    func reset() {
        avatarImageView.image = UIImage(named: "profile-placeholder")
        nameLabel.text = nil
        placementLabel.text = nil
        challengeProgressView.wattsLabel.text = nil
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
        configureProgressBarWidthConstraint()
    }
    
    private func configureProgressBarWidthConstraint() {
        var newProportion = proportion
        let potentialWidth = newProportion * challengeProgressViewContainer.bounds.width
        if potentialWidth < minimumProgressViewWidth {
            newProportion = minimumProgressViewWidth / challengeProgressViewContainer.bounds.width
        }

        let newWidth = newProportion * challengeProgressViewContainer.bounds.width
        if challengeProgressWidthConstraint.constant != newWidth {
            challengeProgressWidthConstraint.constant = newProportion * challengeProgressViewContainer.bounds.width
            challengeProgressView.setNeedsLayout()
            challengeProgressView.layoutIfNeeded()
        }
    }
}

