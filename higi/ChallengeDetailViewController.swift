//
//  ChallengeDetailViewController.swift
//  higi
//
//  Created by Remy Panicker on 8/17/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

/// Detail view for a chalenge.
final class ChallengeDetailViewController: UIViewController {
    
    // MARK: IBOutlets
    
    /// Image view for challenge banner image.
    @IBOutlet private var bannerImageView: UIImageView! {
        didSet {
            bannerImageView.image = nil
        }
    }
    
    /// Label which displays the challenge title.
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    
    /// View which depicts the status of a challenge using colors and symbols.
    @IBOutlet private var challengeStatusIndicatorView: ChallengeStatusIndicatorView!
    
    /// Label which displays the date range a challenge is active.
    @IBOutlet private var dateLabel: UILabel! {
        didSet {
            dateLabel.text = nil
        }
    }
    
    /// Label which displays the number of challenge participants.
    @IBOutlet private var participantLabel: UILabel! {
        didSet {
            participantLabel.text = nil
        }
    }
    
    /// Container view for call to action. Ex: Join button, invite button, etc.
    @IBOutlet private var callToActionContainerView: UIView!
    
    // MARK: Segmented Page
    
    /// Segmented control with container which toggles between detail views.
    private var segmentedPageViewController: SegmentedPageViewController!
    
    /// View controller for detail segment embedded in the `segmentedPageViewController`.
    private lazy var challengeDetailTableViewController: ChallengeDetailTableViewController = {
        let storyboard = UIStoryboard(name: Storyboard.name, bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Storyboard.Scene.DetailTable.identifier) as! ChallengeDetailTableViewController
        
        viewController.configure(withUserController: self.userController, challengeDetailController: self.challengeDetailController, targetPresentationViewController: self)
        
        return viewController
    }()
    
    // TODO: Remy - Add view controllers when they become available
    
    /// View controller for prizes segment embedded in the `segmentedPageViewController`.
    private lazy var prizeViewController: UIViewController = {
        return UIViewController()
    }()
    
    /// View controller for chatter segment embedded in the `segmentedPageViewController`.
    private lazy var chatterViewController: UIViewController = {
        return UIViewController()
    }()
    
    /// View controller for participants segment embedded in the `segmentedPageViewController`.
    private lazy var participantsViewController: UIViewController = {
        return UIViewController()
    }()
    
    /// View controller for leaderboard segment embedded in the `segmentedPageViewController`.
    private lazy var leaderboardViewController: UIViewController = {
        return UIViewController()
    }()
    
    // MARK: Dependencies
    
    /// Controller for current authenticated user.
    private(set) var userController: UserController!
    
    /// Controller for challenge details.
    private var challengeDetailController: ChallengeDetailController!
    
    private var userDidJoinChallengeCallback: (() -> ())?
    
    lazy private var blurredLoadingViewController: BlurredLoadingViewController = {
        let storyboard = UIStoryboard(name: "BlurredLoading", bundle: nil)
        return storyboard.instantiateInitialViewController() as! BlurredLoadingViewController
    }()
    
}

// MARK: - Dependency Injection

extension ChallengeDetailViewController {
    
    /**
     Configures the view controller with dependencies necessary for the view controller to function properly.
     
     - parameter userController: Controller for current authenticated user.
     - parameter challenge:      Challenge to view details for.
     */
    func configure(withUserController userController: UserController, challenge: Challenge, userDidJoinChallengeCallback: (() -> ())?) {
        self.userController = userController
        self.challengeDetailController = ChallengeDetailController(challenge: challenge)
        self.userDidJoinChallengeCallback = userDidJoinChallengeCallback
    }
}

// MARK: - View Lifecycle

extension ChallengeDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView(forChallenge: challengeDetailController.challenge)
    }
}

// MARK: - View Configuration

private extension ChallengeDetailViewController {
    
    /**
     Configures the view based on the challenge.
     
     - parameter challenge: Challenge to view details for.
     */
    func configureView(forChallenge challenge: Challenge) {
        title = challenge.name
        
        bannerImageView.setImage(withMediaAsset: challenge.image, transition: true)
        titleLabel.text = challenge.name
        
        // TODO: Remy - update status indicator after state is refactored
        challengeStatusIndicatorView.state = challenge.userState
        dateLabel.text = NewChallengeUtility.formattedDateRange(forStartDate: challenge.startDate, endDate: challenge.endDate)
        participantLabel.text = NewChallengeUtility.formattedParticipantCount(forParticipantCount: challenge.participantCount)
        
        if challenge.userRelation.status.isJoined {
            addCallToAction(inviteButton())
        } else {
            addCallToAction(joinButton())
        }
    }
    
    // MARK: Call to Action
    
    private func addCallToAction(button: UIButton) {
        callToActionContainerView.addSubview(button, pinToEdges: true)
    }
    
    private func callToActionButton(withTitle title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .System)
        button.titleLabel?.font = UIFont.systemFontOfSize(15.0, weight: UIFontWeightSemibold)
        button.setTitleColor(Theme.Color.Challenge.Detail.buttonText, forState: .Normal)
        button.setTitle(title, forState: .Normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 5.0
        return button
    }
    
    private func joinButton() -> UIButton {
        let title = NSLocalizedString("CHALLENGE_DETAIL_BUTTON_TITLE_JOIN", comment: "Title for join button on challenge detail.")
        let backgroundColor = Theme.Color.Challenge.Detail.joinButton
        let button = callToActionButton(withTitle: title, backgroundColor: backgroundColor)
        button.addTarget(self, action: #selector(didTapJoinButton(_:)), forControlEvents: .TouchUpInside)
        return button
    }
    
    private func inviteButton() -> UIButton {
        let title = NSLocalizedString("CHALLENGE_DETAIL_BUTTON_TITLE_INVITE", comment: "Title for invite button on challenge detail.")
        let backgroundColor = Theme.Color.Challenge.Detail.inviteButton
        let button = callToActionButton(withTitle: title, backgroundColor: backgroundColor)
        button.addTarget(self, action: #selector(didTapInviteButton(_:)), forControlEvents: .TouchUpInside)
        return button
    }
}

// MARK: - UI Action

extension ChallengeDetailViewController {
    
    func didTapJoinButton(sender: UIButton) {
        joinChallenge()
    }
    
    func didTapInviteButton(sender: UIButton) {
        
    }
}

// MARK: - Share

extension ChallengeDetailViewController {
    
    @IBAction func didTapShareBarButtonItem(sender: UIBarButtonItem) {
        // TODO: Remy - Implement
    }
}

// MARK: - Storyboard Identifiers

extension ChallengeDetailViewController {
    
    /// Convenience type for managing storyboard identifiers
    struct Storyboard {
        static let name = "ChallengeDetail"
        
        struct Scene {
            struct Detail {
                static let identifier = "ChallengeDetailViewController"
            }
            
            struct DetailTable {
                static let identifier = "ChallengeDetailTableViewController"
            }
        }
        
        struct Segue {
            struct SegmentedPage {
                static let identifier = "challengeDetailSegmentedPageEmbedSegue"
            }
        }
    }
}

// MARK: - Segue

extension ChallengeDetailViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == Storyboard.Segue.SegmentedPage.identifier {
            guard let viewController = segue.destinationViewController as? SegmentedPageViewController else { return }
            
            segmentedPageViewController = viewController
            configure(segmentedPageViewController: segmentedPageViewController)
        }
    }
    
    private func configure(segmentedPageViewController segmentedPageViewController: SegmentedPageViewController) {
        let detailTitle = NSLocalizedString("CHALLENGE_DETAIL_SEGMENTED_PAGE_SEGMENT_TITLE_DETAIL", comment: "Title for 'detail' segment on segmented control within the challenge detail view.")
        let prizesTitle = NSLocalizedString("CHALLENGE_DETAIL_SEGMENTED_PAGE_SEGMENT_TITLE_PRIZES", comment: "Title for 'prizes' segment on segmented control within the challenge detail view.")
        let chatterTitle = NSLocalizedString("CHALLENGE_DETAIL_SEGMENTED_PAGE_SEGMENT_TITLE_CHATTER", comment: "Title for 'chatter' segment on segmented control within the challenge detail view.")
        
        let participantsTitle = NSLocalizedString("CHALLENGE_DETAIL_SEGMENTED_PAGE_SEGMENT_TITLE_PARTICIPANTS", comment: "Title for 'participants' segment on segmented control within the challenge detail view.")
        let leaderboardTitle = NSLocalizedString("CHALLENGE_DETAIL_SEGMENTED_PAGE_SEGMENT_TITLE_LEADERBOARD", comment: "Title for 'leaderboard' segment on segmented control within the challenge detail view.")
        
        var titles = [detailTitle, prizesTitle, chatterTitle]
        var viewControllers = [challengeDetailTableViewController, prizeViewController, chatterViewController]
        if challengeDetailController.challenge.status == .registration {
            titles.append(participantsTitle)
            viewControllers.append(participantsViewController)
        } else {
            titles.append(leaderboardTitle)
            viewControllers.append(leaderboardViewController)
        }
        
        segmentedPageViewController.set(viewControllers, titles: titles)
        segmentedPageViewController.view.backgroundColor = UIColor.clearColor()
        segmentedPageViewController.segmentedControlHorizontalMargin = 15.0
    }
}

// MARK: - Joining a challenge

extension ChallengeDetailViewController {
    func joinChallenge() {
        if challengeDetailController.challenge.isDirectlyJoinable {
            showTermsAndConditions()
        } else if challengeDetailController.challenge.isJoinableAfterCommunityIsJoined {
            showJoinCommunityAlert()
        } else {
            //TODO: Log bad state
        }
    }
    
    private func showJoinCommunityAlert() {
        guard let community = challengeDetailController.challenge.community else { return }
        let communityMembershipTitleString = NSLocalizedString("CHALLENGES_DETAIL_JOIN_COMMUNITY_COMMUNITY_MEMBERSHIP_TITLE", comment: "Text for the title of the join community message to the user, Community Membership.")
        let communityMembershipMessageFormat = NSLocalizedString("CHALLENGES_DETAIL_JOIN_COMMUNITY_MESSAGE_FORMAT", comment: "Format for the join community message displayed to the user.")
        let communityMembershipMessageString = String(format: communityMembershipMessageFormat, arguments: [community.name])
        let alertViewController = UIAlertController(title: communityMembershipTitleString, message: communityMembershipMessageString, preferredStyle: .Alert)
        let cancelString = NSLocalizedString("CHALLENGES_DETAIL_JOIN_COMMUNITY_CANCEL_STRING", comment: "Text for the cancel button of the join community prompt to the user.")
        let cancelAction = UIAlertAction(title: cancelString, style: .Cancel, handler: nil)
        let okString = NSLocalizedString("CHALLENGES_DETAIL_JOIN_COMMUNITY_OK_STRING", comment: "Text for the OK button of the join community prompt to the user.")
        let okAction = UIAlertAction(title: okString, style: .Default) { (_) in
            self.showTermsAndConditions()
        }
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(okAction)
        presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    private func showTermsAndConditions() {
        guard let challengeTerms = challengeDetailController.challenge.terms else {
            // bad state, user attempted to join non-joinable challenge
            return
        }
        let termsViewController = TermsAndConditionsViewController(nibName: "TermsAndConditionsView", bundle: nil)
        termsViewController.configure(withHTML: challengeTerms, responseRequired: true, acceptanceDelegate: self)
        presentViewController(termsViewController, animated: true, completion: nil)
    }
    
    private func joinChallengeApiCall(withChallenge challenge: Challenge) {
        guard let user = userController?.user else { return }
        blurredLoadingViewController.show(self)
        
        if challengeDetailController.challenge.needToJoinCommunityFirst {
            //TODO: Peter Ryszkiewicz: Once the challenge api gets fixed and returns the community inside of it, join community and update community model
            // On success, join challenge; on failure, tbd
        }
        
        challengeDetailController.join(challenge, user: user, success: {
            [weak self] in
            self?.challengeDetailController.refreshChallenge(success: { (_) in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.userDidJoinChallengeCallback?()
                    //TODO: Peter Ryszkiewicz: Update State of Detail VC, hide join and show invite button
                    self?.blurredLoadingViewController.hide()
                }
            }, failure: { (error) in
                dispatch_async(dispatch_get_main_queue()) {
                    //TODO: Peter Ryszkiewicz: Better handling
                    self?.blurredLoadingViewController.hide()
                }
            })
            }, failure: {
                [weak self] in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.blurredLoadingViewController.hide()
                    //TODO: Peter Ryszkiewicz
                }
            })
    }

}

// MARK: - Terms & Condition Delegate

extension ChallengeDetailViewController: TermsAndConditionsAcceptanceDelegate {
    
    func acceptTerms(withValue accepted: Bool) {
        dismissViewControllerAnimated(true, completion: {
            guard accepted else { return }
            self.joinChallengeApiCall(withChallenge: self.challengeDetailController.challenge)
        })
    }
}
