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
    
    private(set) var challengeProgressView: ChallengeProgressView?
        
    func setModel(model: ChallengeTableViewCellModel) {
        titleLabel.text = model.titleText
        challengeStatusIndicatorView.state = model.challengeStatusState
        dateLabel.text = model.dateText
        participantCountLabel.text = model.participantCountText
        mainImageView.setImage(withMediaAsset: model.mainImageAsset, transition: true)
        communityImageView.setImage(withMediaAsset: model.communityImageAsset, transition: true)
        communityLabel.text = model.communityText
        
        switch model.challengeStatusState {
        case .unjoinedAndUnderway, .unjoinedAndNotUnderway, .joinedAndNotUnderway:
            displayChallengeInformationView(model: model)
        case .joinedAndUnderway:
            displayChallengeProgressView(model: model)
        case .tabulatingResults:
            displayTabulatingResults()
        case .challengeComplete:
            displayChallengeComplete()
        case .cancelled:
            displayChallengeCancelled()
        }
        
        gradientImageView.hidden = !model.isChallengeJoinable
        joinButton.hidden = !model.isChallengeJoinable
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
    
    private func displayTabulatingResults() {
        let challengeInformationView = ChallengeInformationView()
        challengeInformationView.upperLabel.attributedText = NSAttributedString(
            string: NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_TABULATING_RESULTS_TEXT", comment: "Text for Tabulating Results on the challenge card information view.")
        )
        challengeInformationView.upperLabel.hidden = false
        
        challengeInformationView.lowerLabel.hidden = true
        challengeInformationView.rightImageView.hidden = false //TODO: Peter Ryszkiewicz: Get assets, https://higidocs.atlassian.net/wiki/display/PD/Challenge+Card+Conditions
        challengeInformationView.rightImageContainer.hidden = false
        
        challengeInformationContainerView.addSubview(challengeInformationView, pinToEdges: true)
    }
    
    private func displayChallengeComplete() {
        let challengeInformationView = ChallengeInformationView()
        challengeInformationView.upperLabel.attributedText = NSAttributedString(
            string: NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_CHALLENGE_COMPLETE_TEXT", comment: "Text for Challenge is Complete on the challenge card information view.")
        )
        challengeInformationView.upperLabel.hidden = false
        
        challengeInformationView.lowerLabel.hidden = true
        challengeInformationView.rightImageView.hidden = true
        challengeInformationView.rightImageContainer.hidden = true
        
        challengeInformationContainerView.addSubview(challengeInformationView, pinToEdges: true)
    }

    private func displayChallengeCancelled() {
        let challengeInformationView = ChallengeInformationView()
        challengeInformationView.upperLabel.attributedText = NSAttributedString(
            string: NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_CHALLENGE_CANCELLED_TEXT", comment: "Text for Challenge is Cancelled on the challenge card information view.")
        )
        challengeInformationView.upperLabel.hidden = false
        
        challengeInformationView.lowerLabel.hidden = true
        challengeInformationView.rightImageView.hidden = true
        challengeInformationView.rightImageContainer.hidden = true
        
        challengeInformationContainerView.addSubview(challengeInformationView, pinToEdges: true)
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
    
    override func prepareForReuse() {
        challengeInformationContainerView.subviews.forEach { $0.removeFromSuperview() }
        challengeProgressView = nil
        mainImageView.image = nil
    }
}
