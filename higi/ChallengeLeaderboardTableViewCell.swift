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
    @IBOutlet var avatarAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet var contentStackView: UIStackView!
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.textColor = Theme.Color.Challenge.UserProgress.nameLabel
        }
    }
    @IBOutlet var yourTeamLabel: UILabel! {
        didSet {
            yourTeamLabel.text = nil
            yourTeamLabel.textColor = Theme.Color.Challenge.UserProgress.yourTeamLabel
        }
    }
    @IBOutlet var chevronImageView: UIImageView! {
        didSet {
            chevronImageView.alpha = 0.0
            chevronImageView.image = ChevronDirection.right.image
            chevronImageView.tintColor = Theme.Color.Challenge.Detail.Participants.chevron
        }
    }
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

    var goalReached: Bool = false {
        didSet {
            challengeProgressView.wattsLabelPaddingEnabled = goalReached
        }
    }

    var isTeamCell: Bool = false {
        didSet {
            if isTeamCell {
                avatarImageView.cornerRadius = avatarTeamCornerRadius
                avatarAspectRatioConstraint.active = false
                avatarWidthConstraint.constant = avatarTeamWidth
            } else {
                avatarImageView.cornerRadius = avatarDefaultCornerRadius
                avatarAspectRatioConstraint.active = true
                avatarWidthConstraint.constant = avatarDefaultWidth
            }
        }
    }
    
    var isCompetitive: Bool = false {
        didSet {
            if isCompetitive {
                challengeProgressView.height = ChallengeProgressView.heightForCompetitiveBar
            } else {
                challengeProgressView.height = ChallengeProgressView.heightForNonCompetitiveBar
            }
        }
    }

    private var minimumProgressViewWidth: CGFloat {
        return challengeProgressView.height
    }
    
    private var chevronDirection: ChevronDirection = .right {
        didSet {
            chevronImageView.image = chevronDirection.image
        }
    }
    
    // Constants

    private let avatarDefaultCornerRadius: CGFloat = 20.0
    private let avatarTeamCornerRadius: CGFloat = 5.0
    
    private let avatarDefaultWidth: CGFloat = 40.0
    private let avatarTeamWidth: CGFloat = 50.0
}

// MARK: - API

extension ChallengeLeaderboardTableViewCell {
    
    func reset() {
        avatarImageView.image = UIImage(named: "profile-placeholder")
        nameLabel.text = nil
        placementLabel.text = nil
        challengeProgressView.wattsLabel.text = nil
        challengeProgressView.userImageView.image = nil
    }
    
    // This is how large the progress view should be relative to its superview
    func setProgressViewProportion(proportion: CGFloat) {
        self.proportion = proportion
    }
    
    func setProgressViewHidden(hidden: Bool) {
        contentStackView.arrangedSubviews[1].hidden = hidden
    }
    
    func toggleChevronDirection() {
        self.chevronDirection = self.chevronDirection.toggled
    }
    
}

// MARK: - Lifecycle

extension ChallengeLeaderboardTableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureProgressBarWidthConstraint()
    }
    
    private func configureProgressBarWidthConstraint() {
        challengeProgressViewContainer.layoutIfNeeded()
        var newProportion = proportion
        let potentialWidth = newProportion * challengeProgressViewContainer.bounds.width
        if potentialWidth < minimumProgressViewWidth {
            newProportion = minimumProgressViewWidth / challengeProgressViewContainer.bounds.width
        }

        let newWidth = newProportion * challengeProgressViewContainer.bounds.width
        if challengeProgressWidthConstraint.constant != newWidth {
            challengeProgressWidthConstraint.constant = newWidth
            challengeProgressView.setNeedsLayout()
            challengeProgressView.layoutIfNeeded()
        }
    }
}

// MARK: - Inner classes

extension ChallengeLeaderboardTableViewCell {
    private enum ChevronDirection {
        case right
        case down
        
        var imageName: String {
            switch self {
            case .right: return "chevron-right"
            case .down: return "chevron-down"
            }
        }
        
        var image: UIImage? {
            return UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysTemplate)
        }
        
        var toggled: ChevronDirection {
            switch self {
                case .right: return .down
                case .down: return .right
            }
        }
    }
}
