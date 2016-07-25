//
//  PostVideoContainer.swift
//  higi
//
//  Created by Remy Panicker on 7/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class PostVideoContainer: ReusableXibView {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: #selector(didTapPlayButton), forControlEvents: .TouchUpInside)
        }
    }
    var playButtonHandler: (() -> Void)?
}

extension PostVideoContainer {
    
    @objc private func didTapPlayButton(sender: UIButton) {
        playButtonHandler?()
    }
}

// MARK: - Interface Builder Designable

extension PostVideoContainer {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
    }
}
