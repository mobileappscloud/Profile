//
//  PostHeaderView.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class PostHeaderView: UIView {
    
    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    @IBOutlet var avatarButton: UIButton! {
        didSet {
            avatarButton.backgroundColor = UIColor.clearColor()
            avatarButton.setImage(nil, forState: .Normal)
        }
    }
    
    @IBOutlet var nameActionLabel: TTTAttributedLabel! {
        didSet {
            nameActionLabel.text = nil
        }
    }
    
    @IBOutlet var timestampLabel: UILabel! {
        didSet {
            timestampLabel.text = nil
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
        self.view = bundle.loadNibNamed("PostHeaderView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

// MARK: - Interface Builder Designable

extension PostHeaderView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let logoImage = UIImage(named: "higi-logo", inBundle: bundle, compatibleWithTraitCollection: nil)
        avatarButton.setImage(logoImage, forState: .Normal)
        
        nameActionLabel.text = "higi user commented on a post."
        timestampLabel.text = Utility.abbreviatedElapsedTimeUnit(NSDate().dateByAddingTimeInterval(-890000), toDate: NSDate())
    }
}
