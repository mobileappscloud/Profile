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
    private let imageViewKeyPath = "imageView.image"
    
    @IBOutlet var gradientOverlayImageView: UIImageView!
    
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
        
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
}

// MARK: - KVO

extension CommunityBannerView {
    
    private func addObservers() {
        addObserver(self, forKeyPath: imageViewKeyPath, options: .New, context: nil)
    }
    
    private func removeObservers() {
        removeObserver(self, forKeyPath: imageViewKeyPath)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath else { return }
        
        if keyPath == imageViewKeyPath {
            var shouldHideOverlay = true
            if let change = change, let value = change["new"] {
                if !(value is NSNull) {
                    shouldHideOverlay = false
                }
            }
            gradientOverlayImageView.hidden = shouldHideOverlay
            dispatch_async(dispatch_get_main_queue(), {
                self.setNeedsDisplay()
            })   
        }
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
