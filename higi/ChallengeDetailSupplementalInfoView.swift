//
//  ChallengeDetailSupplementalInfoView.swift
//  higi
//
//  Created by Remy Panicker on 8/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Supplemental info views shown at the bottom of the challenge detail view.
@IBDesignable
final class ChallengeDetailSupplementalInfoView: ReusableXibView {
    
    /// Image view positioned at the left end of the view.
    @IBOutlet private var leftImageView: UIImageView!
    
    /// Label for title.
    @IBOutlet var titleLabel: UILabel!
    
    /// Image view positioned at the right end of the view. Shown if view should signal interactivity.
    @IBOutlet private var rightImageView: UIImageView! {
        didSet {
            let image = UIImage(named: "chevron-right")?.imageWithRenderingMode(.AlwaysTemplate)
            rightImageView.image = image
            rightImageView.tintColor = Theme.Color.primary
        }
    }
}

// MARK: View Configuration

extension ChallengeDetailSupplementalInfoView {
    
    /**
     Configures the view with the specified input.
     
     - parameter leftMediaAsset:  Media asset to be rendered in left image view.
     - parameter title:           Text to display in title label.
     - parameter rightMediaAsset: Media asset to be rendered in right image view.
     */
    func configureView(withLeftMediaAsset leftMediaAsset: MediaAsset? = nil, title: String? = nil, isInteractive: Bool = true) {
        
        if let leftMediaAsset = leftMediaAsset {
            leftImageView.setImage(withMediaAsset: leftMediaAsset, transition: true)
        } else {
            leftImageView.hidden = true
        }
        titleLabel.text = title
        rightImageView.hidden = !isInteractive
    }
}

// MARK: Interface Builder

extension ChallengeDetailSupplementalInfoView {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        leftImageView.image = UIImage(named: "higi-logo", inBundle: bundle, compatibleWithTraitCollection: nil)
        titleLabel.text = "Higi Default Community"
        rightImageView.image = UIImage(named: "chevron-right", inBundle: bundle, compatibleWithTraitCollection: nil)
    }
}
