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
    private lazy var challengeDetailSegmentViewController: ChallengeDetailSegmentViewController = {
        let storyboard = UIStoryboard(name: Storyboard.name, bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Storyboard.Scene.DetailSegment.identifier) as! ChallengeDetailSegmentViewController
        
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
    
    func configureView(forChallenge challenge: Challenge) {
        title = challenge.name
        
        bannerImageView.setImage(withMediaAsset: challenge.image, transition: true)
        titleLabel.text = challenge.name
        
        // TODO: Remy - Implement view config with shared function
        challengeStatusIndicatorView.state = ChallengeTableViewCellModel.State(withChallenge: challenge)
        dateLabel.text = NSDateFormatter.challengeCardStartDateFormatter.stringFromDate(challenge.startDate)
        participantLabel.text = String(challenge.participantCount) + " Participants"
        
        if challenge.userRelation.status.isJoined {
            // TODO: Remy - Add invite button
        } else {
            // TODO: Remy - Add join button
        }
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
            
            struct DetailSegment {
                static let identifier = "ChallengeDetailSegmentViewController"
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
        var viewControllers = [challengeDetailSegmentViewController, prizeViewController, chatterViewController]
        if challengeDetailController.challenge.status == .registration {
            titles.append(participantsTitle)
            viewControllers.append(participantsViewController)
        } else {
            titles.append(leaderboardTitle)
            viewControllers.append(leaderboardViewController)
        }
        
        segmentedPageViewController.set(viewControllers, titles: titles)
        segmentedPageViewController.view.backgroundColor = UIColor.clearColor()
        segmentedPageViewController.segmentedControlHorizontalMargin = 0.0
    }
}

//MARK: - Joining a challenge

extension ChallengeDetailViewController: TermsAndConditionsDelegate {
    func joinChallenge() {
        showTermsAndConditions()
    }
    
    private func showTermsAndConditions() {
        guard let challengeTerms = challengeDetailController.challenge.terms else {
            // bad state, user attempted to join non-joinable challenge
            return
        }
        let termsViewController = TermsAndConditionsViewController(nibName: "TermsAndConditionsView", bundle: nil)
        termsViewController.configure(delegate: self, html: challengeTerms, responseRequired: true)
        presentViewController(termsViewController, animated: true, completion: nil)
    }
    
    func acceptTerms(withValue accepted: Bool) {
        dismissViewControllerAnimated(true, completion: {
            guard accepted else { return }
            self.joinChallengeApiCall(withChallenge: self.challengeDetailController.challenge)
        })
    }
    
    func closeTerms() {} // should never happen from this, since a response is required

    private func joinChallengeApiCall(withChallenge challenge: Challenge) {
        guard let user = userController?.user else { return }
        blurredLoadingViewController.show(self)
        challengeDetailController.join(challenge, user: user, success: {
            [weak self] in
            dispatch_async(dispatch_get_main_queue()) {
                self?.userDidJoinChallengeCallback?()
                self?.blurredLoadingViewController.hide()
            }
            //TODO: Peter Ryszkiewicz: hide join and show invite button
        }, failure: {
            [weak self] in
            dispatch_async(dispatch_get_main_queue()) {
                self?.blurredLoadingViewController.hide()
                //TODO: Peter Ryszkiewicz
            }
        })
    }
}
