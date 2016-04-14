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
        cell.interactiveContentTapHandler = { (cell) in
            
        }
        
        if community.isMember {
            let title = NSLocalizedString("COMMUNITY_LISTING_TABLE_CELL_ACCESSORY_BUTTON_TITLE_JOIN", comment: "Title for accessory button on community listing table cell to join a community.")
            cell.configureAccessoryButton(title, titleColor: UIColor.whiteColor(), backgroundColor: Theme.Color.primary, handler: { (cell) in
                
            })
        }
        
        return cell
    }
    
    static func separatorCell(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
}