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
    
    @IBOutlet var listingView: CommunityListingView! {
        didSet {
            listingView.logoMemberContainer.addGestureRecognizer(logoTapGestureRecognizer)
            listingView.interactiveContainer.addGestureRecognizer(containerTapGestureRecognizer)
        }
    }
    
    // MARK: Gesture Recognizers
    
    private lazy var containerTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveContent))
        return tap
    }()
    
    private lazy var logoTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveContent))
        return tap
    }()
    
    var interactiveContentTapHandler: ((cell: CommunityListingTableViewCell) -> Void)?
}

// MARK: - UI Actions

extension CommunityListingTableViewCell {
    
    func didTapInteractiveContent(sender: UIButton) {
        interactiveContentTapHandler?(cell: self)
    }
}

// MARK: - Reuse

extension CommunityListingTableViewCell {
    
    func reset() {
        listingView.bannerContainer.imageView.image = nil
        listingView.logoMemberContainer.imageView.image = nil
        listingView.configure("", memberCount: 0)
        
        interactiveContentTapHandler = nil
        
        let subviews = listingView.bannerContainer.accessoryContainer.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        delegate = nil
    }
}
