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
    
    lazy private var accessoryButton: UIButton! = {
        let button = UIButton(type: .Custom)
        button.addTarget(self, action: #selector(didTapAccessoryButton), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private var accessoryButtonHandler: ((cell: CommunityListingTableViewCell) -> Void)? {
        willSet {
            if newValue == nil {
                accessoryButton.removeFromSuperview()
            } else {
                return
                
                let container = self.listingView.headerContainer
                container.addSubview(accessoryButton)
                accessoryButton.translatesAutoresizingMaskIntoConstraints = false
                let height = NSLayoutConstraint(item: accessoryButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 27.0)
                let width = NSLayoutConstraint(item: accessoryButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 45.0)
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

// MARK: - Configuration

extension CommunityListingTableViewCell {
    
    func configureAccessoryButton(title: String?, tintColor: UIColor?, backgroundColor: UIColor?, handler: ((cell: CommunityListingTableViewCell) -> Void)?) {
        accessoryButton.setTitle(title, forState: .Normal)
        accessoryButton.tintColor = tintColor
        accessoryButton.backgroundColor = backgroundColor
        accessoryButtonHandler = handler
    }
}

// MARK: - UI Actions

extension CommunityListingTableViewCell {
    
    func didTapInteractiveContent(sender: UIButton) {
        print("did tap interactive content")
        interactiveContentTapHandler?(cell: self)
    }
    
    func didTapAccessoryButton(sender: UIButton) {
        print("did tap accessory")
        accessoryButtonHandler?(cell: self)
    }
}
