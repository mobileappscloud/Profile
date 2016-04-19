//
//  CommunitySupplementalTitleView.swift
//  higi
//
//  Created by Remy Panicker on 4/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

@IBDesignable
final class CommunitySupplementalTitleView: UIView {
    
    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.image = nil
        }
    }
    
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    
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
        self.view = bundle.loadNibNamed("CommunitySupplementalTitleView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

// MARK: - Interface Builder Designable

extension CommunitySupplementalTitleView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        imageView.image = UIImage(named: "higi-logo", inBundle: bundle, compatibleWithTraitCollection: nil)
        
        titleLabel.text = "This is a community title"
    }
}
