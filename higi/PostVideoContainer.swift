//
//  PostVideoContainer.swift
//  higi
//
//  Created by Remy Panicker on 7/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@IBDesignable
final class PostVideoContainer: UIView {
 
    /// View necessary for xib reuse
    @IBOutlet private var view: UIView!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: #selector(didTapPlayButton), forControlEvents: .TouchUpInside)
        }
    }
    var playButtonHandler: (() -> Void)?
    
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
        self.view = bundle.loadNibNamed("PostVideoContainer", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
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
