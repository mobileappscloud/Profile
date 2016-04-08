//
//  CommunityListingView.swift
//  higi
//
//  Created by Remy Panicker on 3/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class CommunityListingView: UIView {
    
    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    // MARK: Header
    
    /// Container view for header content
    @IBOutlet private var headerContainer: UIView!
    
    /// Image view in cell header for displaying community banner image.
    @IBOutlet var headerImageView: UIImageView! {
        didSet {
            headerImageView.image = nil
        }
    }
    
    // MARK: Content
    
    /// Container view for cell body which allows user interactivity.
    @IBOutlet private var interactiveContainer: UIView! {
        didSet {
            interactiveContainer.addGestureRecognizer(containerTapGestureRecognizer)
        }
    }
    /// Label for community title.
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    
    // MARK: Logo/Members
    
    /// Container for community logo and member count.
    @IBOutlet private var logoMemberContainer: UIView!
    /// Container view which frames the community logo.
    @IBOutlet private var logoContainerView: UIView! {
        didSet {
            logoContainerView.addGestureRecognizer(logoTapGestureRecognizer)
        }
    }
    /// Image view for community logo.
    @IBOutlet var logoImageView: UIImageView! {
        didSet {
            logoImageView.image = nil
        }
    }
    /// Label which displays the number of members in a community.
    @IBOutlet private var membersLabel: UILabel! {
        didSet {
            membersLabel.text = nil
            membersLabel.attributedText = nil
        }
    }
    
    // MARK: Gesture Recognizers
    
    private lazy var containerTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveView))
        return tap
    }()
    
    private lazy var logoTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveView))
        return tap
    }()
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit() {
        self.view = NSBundle.mainBundle().loadNibNamed("CommunityListingView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

extension CommunityListingView {
    
    func configure(title: String?, memberCount: Int) {
        titleLabel.text = title
        
        let (_, _, formattedCount) = Utility.abbreviatedNumber(memberCount)
        let units = NSString.localizedStringWithFormat(NSLocalizedString("MEMBER_COUNT_SINGLE_PLURAL", comment: "Format for pluralization of members."), memberCount)
        membersLabel.text = "\(formattedCount) \(units)"
    }
    
    
}

// MARK: - Tap Gesture Action
extension CommunityListingView {
    
    func didTapInteractiveView(sender: AnyObject) {
        print("did tap interactive view")
    }
}
