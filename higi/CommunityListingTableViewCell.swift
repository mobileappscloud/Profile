//
//  CommunityListingTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 4/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class CommunityListingTableViewCell: UITableViewCell {

    var delegate: CommunityListingButtonDelegate?
    
    @IBOutlet var listingView: CommunityListingView!
}

// MARK: - Reuse

extension CommunityListingTableViewCell {
    
    func reset() {
        listingView.bannerContainer.imageView.image = nil
        
        listingView.logoMemberContainer.imageView.image = nil
        listingView.configure("", memberCount: 0)
        
        let subviews = listingView.bannerContainer.accessoryContainer.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        delegate = nil
    }
}
