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
    
    @IBOutlet var supplementalTitleContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var supplementalTitleContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet var supplementalTitleContainer: UIView!
    
    @IBOutlet var pageViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var pageViewContainer: UIView!
    
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
        
        updatePageViewContainerHeight()
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
        logoMemberView.imageView.setImageWithURL(community.logo?.URI)
        
        titleLabel.text = community.name
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
    
    /**
     Ensure page view fills visible screen space after accounting for the awesome supplemental view and bottom bars (if applicable).
     
     **Note: This method must be called after the view has been laid out to ensure the correct constraint values are used.**
     */
    private func updatePageViewContainerHeight() {
        pageViewContainerHeightConstraint.constant = -(supplementalTitleContainerHeightConstraint.constant + self.bottomLayoutGuide.length)
    }
}

// MARK: - UI Action

extension CommunityDetailViewController {
    
    @IBAction func didTapInfoButton(sender: UIButton) {
        toggleDescriptionContainer()
    }
    
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
