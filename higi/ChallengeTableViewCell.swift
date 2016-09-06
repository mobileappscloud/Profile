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
    @IBOutlet var communityInformationView: UIView!
    
    private var challengeProgressView: ChallengeProgressView?
    
    private var joinButtonTappedCallback: (() -> ())?
    
    func configure(withModel model: ChallengeTableViewCellModel, joinButtonTappedCallback: () -> (), userPhoto: MediaAsset?) {
        setModel(model)
        self.joinButtonTappedCallback = joinButtonTappedCallback
        challengeProgressView?.userImageView.setImage(withMediaAsset: userPhoto, transition: true)
    }
    
    func setModel(model: ChallengeTableViewCellModel) {
        titleLabel.text = model.titleText
        challengeStatusIndicatorView.state = model.challenge.userState
        dateLabel.text = model.dateText
        participantCountLabel.text = model.participantCountText
        mainImageView.setImage(withMediaAsset: model.mainImageAsset, transition: true)
        communityImageView.setImage(withMediaAsset: model.communityImageAsset, transition: true)
        communityLabel.text = model.communityText
        
        switch model.challenge.userState {
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
        
        gradientImageView.hidden = !model.challenge.isJoinable
        joinButton.hidden = !model.challenge.isJoinable

        communityInformationView.hidden = model.hideCommunityInfo || model.communityText == nil || model.communityImageAsset == nil
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
        challengeInformationView.rightImageView.image = UIImage(named: "challenge-card-tabulating-results") //TODO: Peter Ryszkiewicz: Get updated assets with better resolution
        challengeInformationView.rightImageContainer.hidden = false
        
        challengeInformationContainerView.addSubview(challengeInformationView, pinToEdges: true)
    }
    
    private func displayChallengeComplete() {
        let challengeInformationView = ChallengeInformationView()
        challengeInformationView.upperLabel.attributedText = NSAttributedString(
            string: NSLocalizedString("CHALLENGES_VIEW_CARD_INFORMATION_CHALLENGE_COMPLETE_TEXT", comment: "Text for Challenge is Complete on the challenge card information view.")
        ) //TODO: Fix this text; look at challenge completed wires https://higidocs.atlassian.net/wiki/display/PD/Challenge+Card+Conditions
        challengeInformationView.upperLabel.hidden = false
        
        challengeInformationView.lowerLabel.hidden = true
        challengeInformationView.rightImageView.image = UIImage(named: "challenge-card-checker-flag")
        challengeInformationView.rightImageContainer.hidden = false
        
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
    
    func userDidJoinChallenge() {
        hideJoinButtonAndGradient()
    }
    
    private func hideJoinButtonAndGradient() {
        gradientImageView.hidden = true
        joinButton.hidden = true
    }
    
    @IBAction func joinButtonTapped(sender: UIButton) {
        joinButtonTappedCallback?()
    }
    
    override func prepareForReuse() {
        challengeInformationContainerView.subviews.forEach { $0.removeFromSuperview() }
        challengeProgressView = nil
        mainImageView.image = nil
    }
}
