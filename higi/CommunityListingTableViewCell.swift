//
//  CommunityListingTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 4/8/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class CommunityListingTableViewCell: UITableViewCell {

    @IBOutlet var listingView: CommunityListingView! {
        didSet {
            listingView.logoMemberContainer.addGestureRecognizer(logoTapGestureRecognizer)
            listingView.interactiveContainer.addGestureRecognizer(containerTapGestureRecognizer)
        }
    }
    
    // MARK: Accessory
    
    lazy private var accessoryButton: UIButton! = {
        let button = UIButton(type: .System)
        button.addTarget(self, action: #selector(didTapAccessoryButton), forControlEvents: .TouchUpInside)
        button.layer.cornerRadius = 5.0
        button.setTitleShadowColor(Theme.Color.Primary.charcoal, forState: .Normal)
        return button
    }()
    
    private var accessoryButtonHandler: ((cell: CommunityListingTableViewCell) -> Void)? {
        didSet {
            if accessoryButtonHandler == nil {
                accessoryButton.removeFromSuperview()
            } else {
                let container = self.listingView.bannerContainer
                container.addSubview(accessoryButton)
                accessoryButton.translatesAutoresizingMaskIntoConstraints = false
                let height = NSLayoutConstraint(item: accessoryButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 25.0)
                let width = NSLayoutConstraint(item: accessoryButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 90.0)
                let trailing = NSLayoutConstraint(item: accessoryButton, attribute: .Trailing, relatedBy: .Equal, toItem: container, attribute: .TrailingMargin, multiplier: 1.0, constant: 0.0)
                let bottom = NSLayoutConstraint(item: accessoryButton, attribute: .Bottom, relatedBy: .Equal, toItem: container, attribute: .BottomMargin, multiplier: 1.0, constant: 0.0)
                container.addConstraints([height, width, trailing, bottom])
            }
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

// MARK: - Configure

extension CommunityListingTableViewCell {
    
    func configureAccessoryButton(title: String?, titleColor: UIColor?, backgroundColor: UIColor?, handler: (cell: CommunityListingTableViewCell) -> Void) {
        accessoryButton.setTitle(title, forState: .Normal)
        accessoryButton.setTitleColor(titleColor, forState: .Normal)
        accessoryButton.backgroundColor = backgroundColor
        accessoryButtonHandler = handler
    }
}

// MARK: - UI Actions

extension CommunityListingTableViewCell {
    
    func didTapInteractiveContent(sender: UIButton) {
        interactiveContentTapHandler?(cell: self)
    }
    
    func didTapAccessoryButton(sender: UIButton) {
        accessoryButtonHandler?(cell: self)
    }
}

// MARK: - Reuse

extension CommunityListingTableViewCell {
    
    func reset() {
        listingView.bannerContainer.imageView.image = nil
        listingView.logoMemberContainer.imageView.image = nil
        listingView.configure("", memberCount: 0)
        
        interactiveContentTapHandler = nil

        accessoryButton.setTitle("", forState: .Normal)
        accessoryButton.setTitleColor(nil, forState: .Normal)
        accessoryButton.backgroundColor = backgroundColor
        accessoryButtonHandler = nil
    }
}
