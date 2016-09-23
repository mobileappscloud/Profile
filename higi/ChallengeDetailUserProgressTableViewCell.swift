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
    
    @IBOutlet var challengeProgressContainerView: UIView!
    @IBOutlet var challengeProgressView: ChallengeProgressView!
    
    @IBOutlet var dashedLineView: UIView!
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
    
    @IBOutlet var daysRemainingLabel: UILabel!
    
    @IBOutlet var goalReachedStackView: UIStackView!
    @IBOutlet var goalReachedLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maxPointsContainerView.cornerRadius = maxPointsContainerView.bounds.height / 2
    }
}
