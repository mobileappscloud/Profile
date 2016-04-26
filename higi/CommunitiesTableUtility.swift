//
//  CommunitiesTableUtility.swift
//  higi
//
//  Created by Remy Panicker on 4/11/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

// MARK: - Custom Section

struct CommunitiesTableUtility {}

extension CommunitiesTableUtility {
    
    static func communitySectionHeader(tableView: UITableView, title: String) -> TitleTableHeaderFooterView {
        let header = tableView.dequeueResuableHeaderFooterView(withClass: TitleTableHeaderFooterView.self)!
        header.titleLabel.text = title
        header.contentView.backgroundColor = Theme.Color.Primary.whiteGray
        header.contentView.alpha = 0.8
        return header
    }
}

// MARK: - Custom Cells

extension CommunitiesTableUtility {
    
    static func cell(tableView: UITableView, community: Community, indexPath: NSIndexPath) -> CommunityListingTableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CommunityListingTableViewCell.self, forIndexPath: indexPath)
        cell.layer.cornerRadius = 5.0
        
        cell.reset()
        
        cell.listingView.configure(community.name, memberCount: community.memberCount)
        if let bannerURL = community.header?.URI {
            cell.listingView.bannerContainer.imageView.setImageWithURL(bannerURL)
        }
        if let logoURL = community.logo?.URI {
            cell.listingView.logoMemberContainer.imageView.setImageWithURL(logoURL)
        }
        
        return cell
    }
    
    static func separatorCell(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
}

// MARK: - Buttons

extension CommunitiesTableUtility {

    static func addJoinButton(toCell cell: CommunityListingTableViewCell, delegate: CommunityListingButtonDelegate) {
        let title = NSLocalizedString("COMMUNITY_LISTING_TABLE_CELL_ACCESSORY_BUTTON_TITLE_JOIN", comment: "Title for accessory button on community listing table cell to join a community.")
        addButton(toCell: cell, delegate: delegate, title: title, backgroundColor: Theme.Color.primary, image: nil, height: 25.0, width: 90.0)
    }
    
    static func addInviteFriendsButton(toCell cell: CommunityListingTableViewCell, delegate: CommunityListingButtonDelegate) {
        let title = NSLocalizedString("COMMUNITY_LISTING_TABLE_CELL_ACCESSORY_BUTTON_TITLE_INVITE_FRIENDS", comment: "Title for accessory button on community listing table cell to invite friends.")
        addButton(toCell: cell, delegate: delegate, title: title, backgroundColor: Theme.Color.Secondary.teal, image: nil, height: 25.0, width: 90.0)
    }
    
    static func addPrivateCommunityButton(toCell cell: CommunityListingTableViewCell, delegate: CommunityListingButtonDelegate) {
        addButton(toCell: cell, delegate: delegate, title: nil, backgroundColor: Theme.Color.Secondary.teal, image: nil, height: 25.0, width: 25.0)
    }
    
    private static func addButton(toCell cell: CommunityListingTableViewCell, delegate: CommunityListingButtonDelegate, title: String?, backgroundColor: UIColor?, image: UIImage?, height: CGFloat, width: CGFloat) {
        
        let button = UIButton(type: .System)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(Theme.Color.Primary.white, forState: .Normal)
        button.backgroundColor = backgroundColor
        button.setImage(image, forState: .Normal)
        button.layer.cornerRadius = 5.0
        
        button.addTarget(delegate, action: #selector(delegate.didTapSegueButton(_:)), forControlEvents: .TouchUpInside)
        
        cell.delegate = delegate
        
        let container = cell.listingView.bannerContainer.accessoryContainer
        container.addSubview(button, pinToEdges: true)
        container.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height))
        container.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width))
    }
}
