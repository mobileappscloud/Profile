//
//  CommunityDetailViewController.swift
//  higi
//
//  Created by Remy Panicker on 4/17/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunityDetailViewController: UIViewController {
    
    enum SegmentedControl: Int {
        case Feed
        case Challenges
        case Chatter
        case Rewards
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBOutlet private var bannerContainer: CommunityBannerView!
    
    @IBOutlet private var titleContainer: UIView! {
        didSet {
            titleContainer.addGestureRecognizer(self.descriptionToggleTapGestureRecognizer())
        }
    }
    @IBOutlet private var logoMemberView: CommunityLogoMemberView!
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    @IBOutlet private var descriptionToggleButton: UIButton! {
        didSet {
            descriptionToggleButton.tintColor = Theme.Color.primary
        }
    }
    
    @IBOutlet private var descriptionContainer: UIView! {
        didSet {
            descriptionContainer.addGestureRecognizer(self.descriptionToggleTapGestureRecognizer())
        }
    }
    @IBOutlet private var descriptionContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = nil
        }
    }
    @IBOutlet private var descriptionLabelTopSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private var descriptionLabelBottomSpacingConstraint: NSLayoutConstraint!
    
    private func descriptionToggleTapGestureRecognizer() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(CommunityDetailViewController.didTapDescriptionToggle(_:)))
    }
    
    @IBOutlet private var pageViewContainer: UIView!
    @IBOutlet private var pageViewContainerHeightConstraint: NSLayoutConstraint!
    
    lazy private var blurredLoadingViewController: BlurredLoadingViewController = {
        let storyboard = UIStoryboard(name: "BlurredLoading", bundle: nil)
        return storyboard.instantiateInitialViewController() as! BlurredLoadingViewController
    }()
    
    private(set) var userController: UserController!
    private(set) var communityDetailController: CommunityDetailController!
    private var community: Community {
        get {
            return communityDetailController.community
        }
    }
    
    weak var communitySubscriptionDelegate: CommunitySubscriptionDelegate?
    
    lazy private var textNotificationCoordinator: TextNotificationCoordinator = {
        let textNotificationCoordinator = TextNotificationCoordinator()
        textNotificationCoordinator.sourceView = self.view
        return textNotificationCoordinator
    }()
    
    func configure(community: Community, userController: UserController, communitySubscriptionDelegate: CommunitySubscriptionDelegate?) {
        self.communityDetailController = CommunityDetailController(community: community)
        self.userController = userController
        self.communitySubscriptionDelegate = communitySubscriptionDelegate
    }
}

// Navigation Bar Button Item

extension CommunityDetailViewController {
    
    private func navigationOverflowBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "ellipses-nav-bar-icon"), style: .Plain, target: self, action: #selector(didTapOverflowButton(_:)))
    }
}

// MARK: - View Lifecycle

extension CommunityDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = community.name
        
        self.navigationItem.rightBarButtonItem = navigationOverflowBarButtonItem()
        
        configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        Flurry.logEvent("\(community.name)Comm_Viewed")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateDescriptionContainerHeight()
    }
}

// MARK: - Layout

extension CommunityDetailViewController {
    
    /**
     Ensure description container has the correct height.
     
     **Note: This method must be called after the view has been laid out to ensure the correct constraint values are used.**
     */
    private func updateDescriptionContainerHeight() {
        let isCollapsed = self.descriptionContainerHeightConstraint.constant == 0.0
        if !isCollapsed {
            self.descriptionContainerHeightConstraint.constant = self.descriptionContainerHeight()
        }
    }
}

// MARK: - View Config

extension CommunityDetailViewController {
    
    private func configureView() {
        
        bannerContainer.imageView.setImage(withMediaAsset: community.header)
        
        logoMemberView.configure(community.memberCount)
        logoMemberView.imageView.setImage(withMediaAsset: community.logo)
        
        titleLabel.text = community.name
        
        descriptionLabel.text = community.desc
        
        for subview in bannerContainer.accessoryContainer.subviews {
            subview.removeFromSuperview()
        }        
        if community.isMember {
            if community.isShareable {
                let button = CommunitiesUtility.inviteButton()
                button.addTarget(self, action: #selector(didTapInviteFriendsButton), forControlEvents: .TouchUpInside)
                CommunitiesUtility.addButton(button, toBannerContainer: bannerContainer, height: 30.0, width: 110.0)
            } else {
                if community.isWellnessGroup {
                    let button = CommunitiesUtility.privateCommunityButton()
                    button.addTarget(self, action: #selector(didTapPrivateCommunityOverlay), forControlEvents: .TouchUpInside)
                    CommunitiesUtility.addButton(button, toBannerContainer: bannerContainer, height: 40.0, width: 40.0)
                }
            }
        } else {
            let button = CommunitiesUtility.joinButton()
            button.addTarget(self, action: #selector(didTapJoinButton), forControlEvents: .TouchUpInside)
            CommunitiesUtility.addButton(button, toBannerContainer: bannerContainer, height: 30.0, width: 90.0)
        }
        
        // If a user has not joined the community, do not allow them to interact with the view
        if !community.isMember {
            descriptionContainerHeightConstraint.constant = descriptionContainerHeight()
            descriptionToggleButton.hidden = true
        } else {
            descriptionContainerHeightConstraint.constant = 0.0
            descriptionToggleButton.hidden = false
        }
    }
}

// MARK: - UI Action

extension CommunityDetailViewController {
    
    func didTapDescriptionToggle(sender: UITapGestureRecognizer) {
        if !community.isMember { return }
        
        toggleDescriptionContainer()
    }
    
    @IBAction func didTapOverflowButton(sender: UIBarButtonItem) {
        Flurry.logEvent("CommMoreButton_Pressed")
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if community.isMember {
            let unsubscribeTitle = NSLocalizedString("COMMUNITY_DETAIL_OVERFLOW_MENU_ITEM_TITLE_LEAVE_COMMUNITY", comment: "Title for menu item to leave community in the community detail overflow menu.")
            let leaveAction = UIAlertAction(title: unsubscribeTitle, style: .Default, handler: { [weak self] (action) in
                self?.leaveCommunityConfirmation()
            })
            alertController.addAction(leaveAction)
        }
        
        if alertController.actions.count == 0 { return }
        
        let cancelTitle = NSLocalizedString("COMMUNITY_DETAIL_OVERFLOW_MENU_ITEM_TITLE_CANCEL", comment: "Title for item in the community detail overflow menu to cancel selection.")
        let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func didTapJoinButton(sender: UIButton) {
        joinCommunity()
    }
    
    func didTapInviteFriendsButton(sender: UIButton) {
        Flurry.logEvent("CommInvite_Pressed")
    }
    
    func didTapPrivateCommunityOverlay(sender: UIButton) {
        Flurry.logEvent("PrivateWorkIcon_Pressed")
        
        let storyboard = UIStoryboard(name: "Text", bundle: nil)
        guard let textViewController = storyboard.instantiateInitialViewController() as? TextViewController else { return }
        textViewController.modalPresentationStyle = .Popover
        
        guard let textViewPopoverPresentationController = textViewController.popoverPresentationController else { return }
        textViewPopoverPresentationController.permittedArrowDirections = .Right
        textViewPopoverPresentationController.delegate = self
        textViewPopoverPresentationController.sourceView = sender
        textViewPopoverPresentationController.sourceRect = CGRect(origin: CGPoint(x: -1, y: 1), size: sender.bounds.size)
        
        presentViewController(textViewController, animated: true, completion: nil)
        
        let text = NSLocalizedString("COMMUNITY_DETAIL_PRIVATE_COMMUNITY_POPOVER_TEXT", comment: "Text to display in popover when private community button is pressed in community detail view.")
        let textColor = Theme.Color.Primary.white
        let backgroundColor = UIColor.blackColor()
        
        textViewController.configure(text, textColor: textColor, backgroundColor: backgroundColor)
        textViewController.label.numberOfLines = 1
        let width = bannerContainer.accessoryContainer.frame.origin.x - bannerContainer.accessoryContainer.frame.width
        let height = bannerContainer.accessoryContainer.bounds.height * 1.4
        textViewController.preferredContentSize = CGSize(width: width, height: height)
        textViewPopoverPresentationController.backgroundColor = backgroundColor
    }
}

// MARK: - Leave Community 

extension CommunityDetailViewController {
    
    private func leaveCommunityConfirmation() {
        let alertMessage = NSLocalizedString("COMMUNITY_DETAIL_ALERT_UNSUBSCRIBE_CONFIRMATION_ALERT_MESSAGE", comment: "Message to display on alert to confirm a user's intent to unsubscribe/leave a community.")
        let alertController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .ActionSheet)
        let leaveTitle = NSLocalizedString("COMMUNITY_DETAIL_ALERT_UNSUBSCRIBE_CONFIRMATION_ALERT_ACTION_TITLE_LEAVE", comment: "Title for alert action to unsubscribe/leave a community.")
        let leaveAction = UIAlertAction(title: leaveTitle, style: .Destructive, handler: { [weak self] (action) in
            self?.leaveCommunity()
        })
        let cancelTitle = NSLocalizedString("COMMUNITY_DETAIL_ALERT_UNSUBSCRIBE_CONFIRMATION_ALERT_ACTION_TITLE_CANCEL", comment: "Title for alert action to cancel from unsubscribing/leaving a community.")
        let cancelAction = UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil)
        alertController.addAction(leaveAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK: - Community Description

extension CommunityDetailViewController {
    
    private func toggleDescriptionContainer() {
        view.layoutIfNeeded()
        
        let isCollapsed = self.descriptionContainerHeightConstraint.constant == 0.0
        
        /** @internal:
         iOS will rotate the shortest distance to the end angle, using counter-clockwise if equal.
         Force the rotation to open clockwise and close counter-clockwise by bumping the initial angle.
         [Stack Overflow](http://stackoverflow.com/a/10445958/5897233)
         */
        let almostPi = M_PI - 0.000001
        let radians: CGFloat = isCollapsed ? CGFloat(M_PI) : -CGFloat(almostPi)
        
        UIView.animateWithDuration(0.3, animations: {
            self.descriptionContainerHeightConstraint.constant = isCollapsed ? self.descriptionContainerHeight() : 0.0
            self.descriptionToggleButton.transform = CGAffineTransformRotate(self.descriptionToggleButton.transform, radians)
            self.view.layoutIfNeeded()
        })
    }
    
    private func descriptionContainerHeight() -> CGFloat {
        return descriptionLabel.intrinsicContentSize().height + descriptionLabelTopSpacingConstraint.constant + descriptionLabelBottomSpacingConstraint.constant
    }
}

// MARK: - Join/Leave

extension CommunityDetailViewController {
    
    func joinCommunity() {
        updateSubscription(.Join)
    }
    
    private func leaveCommunity() {
        updateSubscription(.Leave)
    }
    
    private func updateSubscription(filter: CommunitySubscribeRequest.Filter) {
        
        blurredLoadingViewController.show(self)
        
        communityDetailController.updateSubscription(community, filter: filter, user: userController.user, success: { [weak self] (community) in
            self?.updateSubscriptionSuccess(filter, community: community)
            }, failure: { [weak self] (error) in
                self?.updateSubscriptionFailure(filter, error: error)
            })
    }
    
    private func updateSubscriptionSuccess(filter: CommunitySubscribeRequest.Filter, community: Community) {
        let subscribeMessage = NSLocalizedString("COMMUNITY_DETAIL_NOTIFICATION_MESSAGE_SUBSCRIBE_SUCCESS", comment: "Notification message to display within community detail view when a user has successfully subscribed/joined a community.")
        let unsubscribeMessage = NSLocalizedString("COMMUNITY_DETAIL_NOTIFICATION_MESSAGE_UNSUBSCRIBE_SUCCESS", comment: "Notification message to display within community detail view when a user has successfully unsubscribed/left a community.")
        let message = (filter == .Join) ? subscribeMessage : unsubscribeMessage
        
        dispatch_async(dispatch_get_main_queue(), {
            self.blurredLoadingViewController.hide()
            self.configureView()
            self.textNotificationCoordinator.textViewController.label.text = message
            self.textNotificationCoordinator.textViewController.label.setNeedsDisplay()
            self.textNotificationCoordinator.showNotification()
        })
        
        if filter == .Join {
            communitySubscriptionDelegate?.didJoin(community)
        } else if filter == .Leave {
            communitySubscriptionDelegate?.didLeave(community)
        }
    }
    
    private func updateSubscriptionFailure(filter: CommunitySubscribeRequest.Filter, error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.blurredLoadingViewController.hide()
        })
    }
}

// MARK: - Interface Builder

extension CommunityDetailViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier where identifier == CommunitiesViewController.Storyboard.Segue.DetailView.Segue.segmentedPage {
            
            guard let segmentedPage = segue.destinationViewController as? SegmentedPageViewController else { return }
            
            let feedTitle = NSLocalizedString("COMMUNITY_DETAIL_SEGMENTED_CONTROL_SEGMENT_TITLE_FEED", comment: "Segment title for Feed on segmented control in community detail.")
            let feedViewController = UIStoryboard(name: "Feed", bundle: nil).instantiateInitialViewController() as! FeedViewController
            feedViewController.configure(userController, entity: .Community, entityId: community.identifier, targetPresentationViewController: self)
            
            let challengesTitle = NSLocalizedString("COMMUNITY_DETAIL_SEGMENTED_CONTROL_SEGMENT_TITLE_CHALLENGES", comment: "Segment title for Challenges on segmented control in community detail.")
            let chatterTitle = NSLocalizedString("COMMUNITY_DETAIL_SEGMENTED_CONTROL_SEGMENT_TITLE_CHATTER", comment: "Segment title for Chatter on segmented control in community detail.")
            let rewardsTitle = NSLocalizedString("COMMUNITY_DETAIL_SEGMENTED_CONTROL_SEGMENT_TITLE_REWARDS", comment: "Segment title for Rewards on segmented control in community detail.")
            
            let titles = [feedTitle, challengesTitle, chatterTitle, rewardsTitle]
            let viewControllers = [feedViewController, UIViewController(), UIViewController(), UIViewController()]
            segmentedPage.set(viewControllers, titles: titles)
        }
    }
}

// MARK: - Segmented Page Delegate

extension CommunityDetailViewController: SegmentedPageViewControllerDelegate {
    
    func segmentedPageViewControllerDidChange(segmentedPageViewController: SegmentedPageViewController, selectedSegmentIndex: Int, visibleViewController: UIViewController) {
        
        guard let segment = SegmentedControl(rawValue: selectedSegmentIndex) else { return }
        
        var event: String?
        switch segment {
        case .Feed:
            event = "CommFeed_Pressed"
        case .Challenges:
            event = "CommChallengeTab_Pressed"
        case .Chatter:
            event = "CommChatterTab_Pressed"
        case .Rewards:
            event = "CommRewards_Pressed"
        }
        if let event = event {
            Flurry.logEvent(event)
        }
    }
}

// MARK: - Presentation Controller

extension CommunityDetailViewController {

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
}

// MARK: - Popover

extension CommunityDetailViewController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

// MARK: - Protocol

protocol CommunitySubscriptionDelegate: class {
    
    func didJoin(community: Community)
    
    func didLeave(community: Community)
}
