//
//  CommunitiesTableUtility.swift
//  higi
//
//  Created by Remy Panicker on 4/11/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class CommunitiesUtility {}

// MARK: - Buttons

extension CommunitiesUtility {
    
    static func joinButton() -> UIButton {
        let title = NSLocalizedString("COMMUNITY_LISTING_TABLE_CELL_ACCESSORY_BUTTON_TITLE_JOIN", comment: "Title for accessory button on community listing table cell to join a community.")
        let backgroundColor = Theme.Color.primary
        return button(title, backgroundColor: backgroundColor, image: nil)
    }
    
    static func inviteButton() -> UIButton {
        let title = NSLocalizedString("COMMUNITY_LISTING_TABLE_CELL_ACCESSORY_BUTTON_TITLE_INVITE_FRIENDS", comment: "Title for accessory button on community listing table cell to invite friends.")
        let backgroundColor = Theme.Color.Secondary.teal
        return button(title, backgroundColor: backgroundColor, image: nil)
    }
    
    static func privateCommunityButton() -> UIButton {
        let backgroundColor = Theme.Color.Secondary.teal
        let image = UIImage(named: "private-community-icon")
        return button(nil, backgroundColor: backgroundColor, image: image)
    }
    
    private static func button(title: String?, backgroundColor: UIColor?, image: UIImage?) -> UIButton {
        let button = UIButton(type: .System)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(Theme.Color.Primary.white, forState: .Normal)
        button.backgroundColor = backgroundColor
        button.setImage(image, forState: .Normal)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
    }
}

// MARK: - Banner Accessory Button

extension CommunitiesUtility {
    
    static func addButton(button: UIButton, toBannerContainer bannerContainer: CommunityBannerView, height: CGFloat, width: CGFloat) {
        let container = bannerContainer.accessoryContainer
        container.addSubview(button, pinToEdges: true)
        container.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height))
        container.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width))
    }
}

// MARK: - Community Cell Button

extension CommunitiesUtility {
    
    static func addJoinButton(toCell cell: CommunityListingTableViewCell, delegate: CommunityListingButtonDelegate) {
        addButton(joinButton(), height: 30.0, width: 90.0, toCell: cell, delegate: delegate)
    }
    
    static func addInviteFriendsButton(toCell cell: CommunityListingTableViewCell, delegate: CommunityListingButtonDelegate) {
        addButton(inviteButton(), height: 30.0, width: 110.0, toCell: cell, delegate: delegate)
    }
    
    private static func addButton(communityButton: UIButton, height: CGFloat, width: CGFloat, toCell cell: CommunityListingTableViewCell, delegate: CommunityListingButtonDelegate) {
        
        communityButton.addTarget(delegate, action: #selector(delegate.didTapSegueButton(_:)), forControlEvents: .TouchUpInside)
        
        cell.delegate = delegate
        
        addButton(communityButton, toBannerContainer: cell.listingView.bannerContainer, height: height, width: width)
    }
}
