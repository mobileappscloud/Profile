//
//  CommunityListingView.swift
//  higi
//
//  Created by Remy Panicker on 3/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

@IBDesignable
final class CommunityListingView: UIView {
    
    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    // MARK: Header
    
    /// Container view for header content
    @IBOutlet var headerContainer: UIView!
    
    /// Image view in cell header for displaying community banner image.
    @IBOutlet var headerImageView: UIImageView! {
        didSet {
            headerImageView.image = nil
        }
    }
    
    // MARK: Content
    
    /// Container view for cell body which allows user interactivity.
    @IBOutlet var interactiveContainer: UIView! {
        didSet {
//            interactiveContainer.addGestureRecognizer(containerTapGestureRecognizer)
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
    @IBOutlet var logoMemberContainer: UIView!
    /// Container view which frames the community logo.
    @IBOutlet private var logoContainerView: UIView! {
        didSet {
//            logoContainerView.addGestureRecognizer(logoTapGestureRecognizer)
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
    
//    private lazy var containerTapGestureRecognizer: UITapGestureRecognizer = {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveView))
//        return tap
//    }()
//    
//    private lazy var logoTapGestureRecognizer: UITapGestureRecognizer = {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveView))
//        return tap
//    }()
    
    private var tapHandler: (() -> Void)?
    
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
        let bundle = NSBundle(forClass: self.dynamicType)
        self.view = bundle.loadNibNamed("CommunityListingView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

// MARK: - Configuration

extension CommunityListingView {
    
    func configure(title: String?, memberCount: Int) {
        titleLabel.text = title
        
        let (_, _, formattedCount) = Utility.abbreviatedNumber(memberCount)
        let units = NSString.localizedStringWithFormat(NSLocalizedString("MEMBER_COUNT_SINGLE_PLURAL", comment: "Format for pluralization of members."), memberCount) as String
        
        let countFont = UIFont.boldSystemFontOfSize(10.0)
        let attributedCount = NSAttributedString(string: formattedCount, attributes: [NSFontAttributeName : countFont])
        
        let unitFont = UIFont.systemFontOfSize(9.0)
        let attributedUnit = NSAttributedString(string: units, attributes: [NSFontAttributeName : unitFont])
        
        let attributedText = NSMutableAttributedString(attributedString: attributedCount)
        attributedText.appendAttributedString(NSAttributedString(string: " "))
        attributedText.appendAttributedString(attributedUnit)
        
        membersLabel.attributedText = attributedText
    }
}

// MARK: - Tap Gesture Action

extension CommunityListingView {
    
    func didTapInteractiveView(sender: AnyObject) {
        tapHandler?()
    }
}


// MARK: - Interface Builder Designable

extension CommunityListingView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        configure("This is a sample community", memberCount: 3341)
        headerImageView.image = UIImage(named: "gradient-overlay")
        logoImageView.image = UIImage(named: "gradient-overlay")
    }
}
