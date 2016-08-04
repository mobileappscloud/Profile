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
    @IBOutlet var joinButton: UIButton!
    
    @IBOutlet var challengeInformationContainerView: UIView!
    
    @IBOutlet var communityImageView: UIImageView!
    @IBOutlet var communityLabel: UILabel!
    
    private var challengeProgressView: ChallengeProgressView?
        
    func setModel(model: ChallengeTableViewCellModel) {
        titleLabel.text = model.titleText
        dateLabel.text = model.dateText
        participantCountLabel.text = model.participantCountText
        mainImageView.image = model.mainImageView
        communityImageView.image = model.communityImage
        communityLabel.text = model.communityText
        
        if model.showChallengeInformationProgress {
            displayChallengeProgressView(model: model)
        } else {
            displayChallengeInformationView(model: model)
        }
    }
    
    private func displayChallengeProgressView(model model: ChallengeTableViewCellModel) {
        let challengeProgressView = ChallengeProgressView()
        self.challengeProgressView = challengeProgressView
        challengeProgressView.translatesAutoresizingMaskIntoConstraints = false
        challengeInformationContainerView.addSubview(challengeProgressView)
        challengeInformationContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[subview]-30-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : challengeProgressView]))
        challengeInformationContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : challengeProgressView]))
        if let progressMilestones = model.progressMilestones {
            challengeProgressView.progressMilestones = progressMilestones
        }
    }
    
    private func displayChallengeInformationView(model model: ChallengeTableViewCellModel) {
        let challengeInformationView = ChallengeInformationView()
        challengeInformationView.upperLabel.attributedText = model.challengeInformationUpperText
        challengeInformationView.upperLabel.hidden = model.challengeInformationUpperText == nil
        
        challengeInformationView.lowerLabel.attributedText = model.challengeInformationLowerText
        challengeInformationView.lowerLabel.hidden = model.challengeInformationLowerText == nil
        
        challengeInformationView.rightImageView.image = model.challengeInformationImage
        challengeInformationView.rightImageView.hidden = model.challengeInformationImage == nil
        
        challengeInformationView.rightImageContainer.hidden = model.challengeInformationImage == nil
        
        challengeInformationContainerView.addSubview(challengeInformationView, pinToEdges: true)
    }
    
    @IBAction func joinButtonTapped(sender: UIButton) {
        challengeStatusIndicatorView.state = .cancelled
        let rand = CGFloat(arc4random_uniform(10))/9.0
        challengeProgressView?.progress = rand
    }
}
