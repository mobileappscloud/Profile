//
//  CommunityBannerView.swift
//  higi
//
//  Created by Remy Panicker on 4/13/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class CommunityBannerView: UIView {

    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.image = nil
        }
    }
    
    @IBOutlet var accessoryContainer: UIView!
    
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
        self.view = bundle.loadNibNamed("CommunityBannerView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

// MARK: - Interface Builder Designable

extension CommunityBannerView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        imageView.image = UIImage(named: "higi-logo", inBundle: bundle, compatibleWithTraitCollection: nil)
        
        let accessory = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 27))
        accessory.backgroundColor = Theme.Color.primary
        accessoryContainer.addSubview(accessory, pinToEdges: true)
    }
}
