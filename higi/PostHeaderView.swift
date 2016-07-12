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
    
    @IBOutlet private var primaryLabel: TTTAttributedLabel! {
        didSet {
            primaryLabel.text = nil
        }
    }
    
    @IBOutlet private var secondaryLabel: UILabel! {
        didSet {
            secondaryLabel.text = nil
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

extension PostHeaderView {
    
    func configure(author: String?, action: String?, timestamp: String?) {
        if let author = author {
            primaryLabel.text = author
        }
        if let action = action {
            primaryLabel.text = primaryLabel.text?.stringByAppendingString(action)
        }
        secondaryLabel.text = timestamp
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
        secondaryLabel.text = Utility.abbreviatedElapsedTimeUnit(NSDate().dateByAddingTimeInterval(-890000), toDate: NSDate())
    }
}
