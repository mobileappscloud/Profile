//
//  CommunityDetailViewController.swift
//  higi
//
//  Created by Remy Panicker on 4/17/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunityDetailViewController: UIViewController {
    
    @IBOutlet private var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    @IBOutlet private var bannerContainer: CommunityBannerView!
    
    @IBOutlet private var titleContainer: UIView!
    @IBOutlet private var logoMemberView: CommunityLogoMemberView!
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    @IBOutlet private var infoButton: UIButton! {
        didSet {
            infoButton.tintColor = Theme.Color.primary
        }
    }
    
    @IBOutlet private var descriptionContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var descriptionLabelTopSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private var descriptionLabelBottomSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = nil
        }
    }
    
    @IBOutlet private var supplementalTitleContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var supplementalTitleContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet private var supplementalTitleContainer: CommunitySupplementalTitleView!
    
    @IBOutlet private var pageViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var pageViewContainer: UIView!
    
    var community: Community!
}

// MARK: - View Lifecycle

extension CommunityDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateDescriptionContainerHeight()
        updatePageViewContainerHeight()
    }
}

// MARK: - Layout

extension CommunityDetailViewController {
    
    /**
     Ensure page view fills visible screen space after accounting for the awesome supplemental view and bottom bars (if applicable).
     
     **Note: This method must be called after the view has been laid out to ensure the correct constraint values are used.**
     */
    private func updatePageViewContainerHeight() {
        pageViewContainerHeightConstraint.constant = -(supplementalTitleContainerHeightConstraint.constant + self.bottomLayoutGuide.length)
    }
    
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
        // hide supplemental view
        supplementalTitleContainerTopConstraint.constant -= supplementalTitleContainerHeightConstraint.constant
        
        updatePageViewContainerHeight()
        
        descriptionContainerHeightConstraint.constant = 0.0
        
        bannerContainer.imageView.setImageWithURL(community.header?.URI)
        
        logoMemberView.configure(community.memberCount)
        if let logo = community.logo {
            logoMemberView.imageView.setImageWithURL(logo.URI)
            supplementalTitleContainer.imageView.setImageWithURL(logo.URI)
        }
        
        titleLabel.text = community.name
        supplementalTitleContainer.titleLabel.text = community.name
        
        descriptionLabel.text = community.desc
        
        // If a community is private, users cannot invite friends
        if !community.isPublic {
            
        }
        
        // If a user has not joined the community, do not allow them to interact with the view
        if !community.isMember {
            descriptionContainerHeightConstraint.constant = descriptionContainerHeight()
            infoButton.hidden = true
        }
    }
}

// MARK: - UI Action

extension CommunityDetailViewController {
    
    @IBAction func didTapActionButton(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func didTapInfoButton(sender: UIButton) {
        toggleDescriptionContainer()
    }
    
    func didTapJoinButton(sender: UIButton) {
        joinCommunity()
    }
    
    func didTapLeaveButton(sender: UIButton) {
        
    }
    
    func didTapInviteFriendsButton(sender: UIButton) {
        
    }
    
    func didTapPrivateCommunityOverlay(sender: UIButton) {
        
    }
}

// MARK: - Community Description

extension CommunityDetailViewController {
    
    private func toggleDescriptionContainer() {
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.3, animations: {
            let isCollapsed = self.descriptionContainerHeightConstraint.constant == 0.0
            self.descriptionContainerHeightConstraint.constant = isCollapsed ? self.descriptionContainerHeight() : 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    private func descriptionContainerHeight() -> CGFloat {
        return descriptionLabel.intrinsicContentSize().height + descriptionLabelTopSpacingConstraint.constant + descriptionLabelBottomSpacingConstraint.constant
    }
}

// MARK: - Join/Leave

extension CommunityDetailViewController {
    
}

// MARK: - Scroll Delegate

extension CommunityDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateSupplementalTitlePosition(scrollView)
    }
    
    private func updateSupplementalTitlePosition(scrollView: UIScrollView) {
        let verticalOffset = scrollView.contentOffset.y
        let scrollingTitleViewHeight = CGRectGetHeight(supplementalTitleContainer.bounds)
        let scrollingTitleViewThresholdMax = CGRectGetMaxY(titleContainer.frame)
        let scrollingTitleViewThresholdMin = scrollingTitleViewThresholdMax - scrollingTitleViewHeight
        
        if verticalOffset < scrollingTitleViewThresholdMin {
            supplementalTitleContainerTopConstraint.constant = -scrollingTitleViewHeight
        } else if verticalOffset > scrollingTitleViewThresholdMax {
            supplementalTitleContainerTopConstraint.constant = 0.0
        } else if verticalOffset > (scrollingTitleViewThresholdMin) && verticalOffset < scrollingTitleViewThresholdMax  {
            let offset = verticalOffset - scrollingTitleViewThresholdMin
            supplementalTitleContainerTopConstraint.constant = offset - scrollingTitleViewHeight
        }
    }
}
