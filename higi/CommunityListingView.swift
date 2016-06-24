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
    
    @IBOutlet var bannerContainer: CommunityBannerView!
    
    // MARK: Content
    
    /// Label for community title.
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    
    // MARK: Logo/Members

    @IBOutlet var logoMemberContainer: CommunityLogoMemberView!
    
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
        logoMemberContainer.configure(memberCount)
    }
}

// MARK: - Interface Builder Designable

extension CommunityListingView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        configure("This is a sample community", memberCount: 3341)
        
        let bundle = NSBundle(forClass: self.dynamicType)
        bannerContainer.imageView.image = UIImage(named: "higi-logo", inBundle: bundle, compatibleWithTraitCollection: nil)
        logoMemberContainer.imageView.image = UIImage(named: "higi-logo", inBundle: bundle, compatibleWithTraitCollection: nil)
    }
}
