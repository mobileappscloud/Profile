//
//  CommunityLogoMemberView.swift
//  higi
//
//  Created by Remy Panicker on 4/13/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class CommunityLogoMemberView: UIView {
    
    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.image = nil
        }
    }
    
    @IBOutlet private var label: UILabel! {
        didSet {
            label.text = nil
            label.attributedText = nil
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
        self.view = bundle.loadNibNamed("CommunityLogoMemberView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

extension CommunityLogoMemberView {
    
    func configure(memberCount: Int) {
        let (_, _, formattedCount) = Utility.abbreviatedNumber(memberCount)
        let units = NSString.localizedStringWithFormat(NSLocalizedString("MEMBER_COUNT_SINGLE_PLURAL", comment: "Format for pluralization of members."), memberCount) as String
        
        let countFont = UIFont.boldSystemFontOfSize(10.0)
        let attributedCount = NSAttributedString(string: formattedCount, attributes: [NSFontAttributeName : countFont])
        
        let unitFont = UIFont.systemFontOfSize(10.0)
        let attributedUnit = NSAttributedString(string: units, attributes: [NSFontAttributeName : unitFont])
        
        let attributedText = NSMutableAttributedString(attributedString: attributedCount)
        attributedText.appendAttributedString(NSAttributedString(string: " "))
        attributedText.appendAttributedString(attributedUnit)
        
        label.attributedText = attributedText
    }
}

// MARK: - Interface Builder Designable

extension CommunityLogoMemberView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        configure(2531)
        imageView.image = UIImage(named: "gradient-overlay")
    }
}
