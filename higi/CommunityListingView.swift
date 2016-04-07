//
//  CommunityListingView.swift
//  higi
//
//  Created by Remy Panicker on 3/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class CommunityListingView: UIView {

    @IBOutlet var view: UIView!
    
    @IBOutlet var headerImageView: UIImageView! {
        didSet {
            
        }
    }
    
    @IBOutlet var interactiveContainer: UIView! {
        didSet {
            interactiveContainer.addGestureRecognizer(containerTapGestureRecognizer)
        }
    }
    
    @IBOutlet var logoContainerView: UIView! {
        didSet {
            logoContainerView.addGestureRecognizer(logoTapGestureRecognizer)
        }
    }

    @IBOutlet var logoImageView: UIImageView!
    
    private lazy var containerTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveView))
        return tap
    }()
    
    private lazy var logoTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveView))
        return tap
    }()
    
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
        self.view = NSBundle.mainBundle().loadNibNamed("CommunityListingView", owner: self, options: nil).first as! UIView
        self.addSubview(self.view, pinToEdges: true)
    }
}

extension CommunityListingView {
    
    func didTapInteractiveView(sender: AnyObject) {
        print("did tap interactive view")
    }
}
