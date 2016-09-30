//
//  CommunityBannerView.swift
//  higi
//
//  Created by Remy Panicker on 4/13/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class CommunityBannerView: ReusableXibView {
    
    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.image = nil
        }
    }
    private let imageViewKeyPath = "imageView.image"
    
    /// Set this property to `false` if the view should not automatically manage the display of a gradient overlay atop the `imageView`. By default, this is set to `true`.
    var shouldManageGradientOverlay = true
    
    @IBOutlet var gradientOverlayImageView: UIImageView!
    
    @IBOutlet var accessoryContainer: UIView!
    
    // MARK: - Init
    
    override func commonInit() {
        super.commonInit()
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
        
        if keyPath == imageViewKeyPath && shouldManageGradientOverlay {
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
