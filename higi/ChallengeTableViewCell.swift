//
//  ChallengeTableViewCell.swift
//  higi
//
//  Created by Peter Ryszkiewicz on 7/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class ChallengeTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var challengeStatusIndicatorView: ChallengeStatusIndicatorView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var participantCountLabel: UILabel!
    
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var gradientImageView: UIImageView!
    
    @IBOutlet var challengeInformationView: ChallengeInformationView!
    
    @IBOutlet var communityImageView: UIImageView!
    @IBOutlet var communityLabel: UILabel!
        
    func setModel(model: ChallengeTableViewCellModel) {
        titleLabel.text = model.titleText
        dateLabel.text = model.dateText
        participantCountLabel.text = model.participantCountText
        mainImageView.image = model.mainImageView
        communityImageView.image = model.communityImage
        communityLabel.text = model.communityText
        
        challengeInformationView.upperLabel.attributedText = model.challengeInformationUpperText
        challengeInformationView.lowerLabel.attributedText = model.challengeInformationLowerText
        challengeInformationView.rightImageView.image = model.challengeInformationImage
        challengeInformationView.goalProgressView.hidden = !model.showChallengeInformationStatus
    }
    
    @IBAction func joinButtonTapped(sender: UIButton) {
        challengeStatusIndicatorView.state = .cancelled
    }
}
