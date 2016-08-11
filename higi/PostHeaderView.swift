//
//  PostHeaderView.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class PostHeaderView: ReusableXibView {
    
    @IBOutlet var avatarButton: UIButton! {
        didSet {
            avatarButton.backgroundColor = UIColor.clearColor()
            avatarButton.setImage(nil, forState: .Normal)
        }
    }
    
    @IBOutlet var primaryLabel: TTTAttributedLabel! {
        didSet {
            primaryLabel.text = nil
        }
    }
    
    @IBOutlet var secondaryLabel: UILabel! {
        didSet {
            secondaryLabel.text = nil
        }
    }
}

// MARK: - Interface Builder Designable

extension PostHeaderView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let logoImage = UIImage(named: "higi-logo", inBundle: bundle, compatibleWithTraitCollection: nil)
        avatarButton.setImage(logoImage, forState: .Normal)
        
        primaryLabel.text = "higi user commented on a post."
        secondaryLabel.text = Utility.shortElapsedTimeAgo(NSDate().dateByAddingTimeInterval(-890000), toDate: NSDate())
    }
}
