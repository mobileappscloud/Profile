//
//  ChallengeProgressHeaderTableViewCell.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 9/22/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeProgressHeaderTableViewCell: UITableViewCell {
    @IBOutlet var maxPointsContainerView: UIView! {
        didSet {
            maxPointsContainerView.backgroundColor = Theme.Color.Challenge.UserProgress.pointsContainerBackground
        }
    }
    @IBOutlet var numberOfPointsLabel: UILabel! {
        didSet {
            numberOfPointsLabel.textColor = Theme.Color.Challenge.UserProgress.pointsContainerText
        }
    }
    @IBOutlet var pointsTextLabel: UILabel! {
        didSet {
            pointsTextLabel.text = NSLocalizedString("CHALLENGE_DETAIL_VIEW_WATTS_TEXT", comment: "Text for watts in the challenge detail view")
            pointsTextLabel.textColor = Theme.Color.Challenge.UserProgress.pointsContainerText
        }
    }
    @IBOutlet var dashedLineView: UIView!
}

// MARK: - Lifecycle

extension ChallengeProgressHeaderTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        maxPointsContainerView.cornerRadius = maxPointsContainerView.bounds.height / 2
    }
}
