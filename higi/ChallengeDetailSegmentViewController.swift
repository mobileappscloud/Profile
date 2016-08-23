//
//  ChallengeDetailSegmentViewController.swift
//  higi
//
//  Created by Remy Panicker on 8/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

/// View controller for the 'detail' segment of a challenge detail.
final class ChallengeDetailSegmentViewController: UIViewController {
    
    // MARK: IBOutlets
    
    /// Container for challenge leaderboard widget.
    @IBOutlet private var leaderboardContainer: UIView!
    
    /// Label for heading of the challenge description section.
    @IBOutlet private var descriptionHeaderLabel: UILabel! {
        didSet {
            descriptionHeaderLabel.text = NSLocalizedString("CHALLENGE_DETAIL_SEGMENT_HEADER_DESCRIPTION", comment: "Header for description section within the detail segment on challenge details.")
        }
    }
    
    /// Label for body of the challenge description section.
    @IBOutlet private var descriptionBodyLabel: UILabel! {
        didSet {
            descriptionBodyLabel.text = nil
        }
    }
    
    /// Label for heading of the challenge goal section.
    @IBOutlet private var goalHeaderLabel: UILabel! {
        didSet {
            goalHeaderLabel.text = NSLocalizedString("CHALLENGE_DETAIL_SEGMENT_HEADER_GOAL", comment: "Header for goal section within the detail segment on challenge details.")
        }
    }
    
    /// Label for body of the challenge goal section.
    @IBOutlet private var goalBodyLabel: UILabel! {
        didSet {
            goalBodyLabel.text = nil
        }
    }
    
    /// Container for official rules info.
    @IBOutlet private var officialRulesContainer: UIView!
    
    /// View with supplemental info regarding official rules for a challenge.
    @IBOutlet private var officialRulesSupplementalInfoView: ChallengeDetailSupplementalInfoView!
    
    /// Container for community info. Hidden if there is no community.
    @IBOutlet private var communityContainer: UIView!
    
    /// View with supplemental information regarding a linked community.
    @IBOutlet private var communitySupplementalInfoView: ChallengeDetailSupplementalInfoView!
    
    /// Container for sponsored content (where applicable).
    @IBOutlet private var sponsoredContentContainer: UIView!
    
    // MARK: Tap Gestures
    
    /// Gesture recognizer to handle taps on the official rules container.
    private lazy var officialRulesTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(self.didTapOfficialRulesContainer(_:)))
    }()
    
    /// Gesture recognizer to handle taps on the community container.
    private lazy var communityTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(self.didTapCommunityContainer(_:)))
    }()
    
    // MARK: Dependencies
    
    /// Controller for current authenticated user.
    private(set) var userController: UserController!
    
    /// Controller for challenge details.
    private(set) var challengeDetailController: ChallengeDetailController!
    
    /// View controller to target for presentation of views. This property should be set when this view controller is a child view controller.
    private(set) weak var targetPresentationViewController: UIViewController?
}

// MARK: - Dependency Injection

extension ChallengeDetailSegmentViewController {

    /**
     Configures the view controller with dependencies necessary for the view controller to function properly.
     
     - parameter userController:            Controller for current authenticated user.
     - parameter challengeDetailController: Controller for challenge details.
     */
    func configure(withUserController userController: UserController, challengeDetailController: ChallengeDetailController, targetPresentationViewController: UIViewController?) {
        self.userController = userController
        self.challengeDetailController = challengeDetailController
        self.targetPresentationViewController = targetPresentationViewController
    }
}

// MARK: - View Lifecycle

extension ChallengeDetailSegmentViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView(forChallenge: challengeDetailController.challenge)
    }
}

// MARK: - View Configuration

extension ChallengeDetailSegmentViewController {
    
    private func configureView(forChallenge challenge: Challenge) {
        descriptionBodyLabel.text = challenge.sanitizedShortDescription
        goalBodyLabel.text = challenge.goalDescription
        
        if let _ = challenge.terms {
            let title = NSLocalizedString("CHALLENGE_DETAIL_SEGMENT_OFFICIAL_RULES_TITLE", comment: "Title for view within challenge detail segment which navigates the user to the official rules.")
            officialRulesSupplementalInfoView.configureView(withLeftMediaAsset: nil, title: title, isInteractive: true)
            officialRulesSupplementalInfoView.titleLabel.font = UIFont.systemFontOfSize(16.0)
            officialRulesSupplementalInfoView.titleLabel.textColor = Theme.Color.Challenge.Detail.Segment.officialRulesText
            officialRulesContainer.addGestureRecognizer(officialRulesTapGesture)
        } else {
            officialRulesContainer.hidden = true
        }
        
        if let community = challenge.community {
            communitySupplementalInfoView.configureView(withLeftMediaAsset: community.logo, title: community.name, isInteractive: community.isMember)
            communityContainer.addGestureRecognizer(communityTapGesture)
        } else {
            communityContainer.hidden = true
        }
    }
}

// MARK: - Action

extension ChallengeDetailSegmentViewController {
    
    @objc private func didTapOfficialRulesContainer(sender: UITapGestureRecognizer) {
        let challenge = challengeDetailController.challenge
        guard let terms = challenge.terms else { return }
        guard targetPresentationViewController != nil else { return }
        
        let termsViewController = TermsAndConditionsViewController(nibName: "TermsAndConditionsView", bundle: nil);
//        termsViewController.html = terms
        let navigationController = UINavigationController(rootViewController: termsViewController)
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.targetPresentationViewController?.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
            })
    }
    
    @objc private func didTapCommunityContainer(sender: UITapGestureRecognizer) {
        let storyboardName = CommunitiesViewController.Storyboard.name
        let detailIdentifier = CommunitiesViewController.Storyboard.Scene.Detail.identifier
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let community = challengeDetailController.challenge.community,
            let communityDetailViewController = storyboard.instantiateViewControllerWithIdentifier(detailIdentifier) as? CommunityDetailViewController else { return }
        
        communityDetailViewController.configure(community, userController: userController, communitySubscriptionDelegate: nil)
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.targetPresentationViewController?.navigationController?.presentViewController(communityDetailViewController, animated: true, completion: nil)
            })
    }
}
