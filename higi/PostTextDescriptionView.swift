//
//  PostTextDescriptionView.swift
//  higi
//
//  Created by Remy Panicker on 6/27/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class PostTextDescriptionView: UIView {

    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    @IBOutlet var titleLabel: TTTAttributedLabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    
    @IBOutlet var descriptionLabel: TTTAttributedLabel! {
        didSet {
            descriptionLabel.text = nil
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
        self.view = bundle.loadNibNamed("PostTextDescriptionView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

// MARK: - Interface Builder Designable

extension PostTextDescriptionView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        titleLabel.text = "higi Station Tutorial (1:37)"
        descriptionLabel.text = "View this video for a comprehensive overview of how to use a higi Station. You can check-in, get your blood pressure reading, weight yourself, and measure your pulse all in one quick session. Don't worry about offline stations. You can check-in with your phone!"
    }
}
