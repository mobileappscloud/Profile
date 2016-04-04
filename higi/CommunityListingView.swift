//
//  CommunityListingView.swift
//  higi
//
//  Created by Remy Panicker on 3/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class CommunityListingView: UIView {

    @IBOutlet var headerImageView: UIImageView!
    
    @IBOutlet var interactiveContainer: UIView! {
        didSet {
            interactiveContainer.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet var logoImageView: UIImageView! {
        didSet {
            logoImageView.addGestureRecognizer(tapGestureRecognizer)
            
            logoImageView.layer.borderWidth = 3.0
            logoImageView.layer.borderColor = Theme.Color.Primary.whiteGray.CGColor
        }
    }

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInteractiveView))
        return tap
    }()
}

extension CommunityListingView {
    
    func didTapInteractiveView(sender: AnyObject) {
        print("did tap interactive view")
    }
}
