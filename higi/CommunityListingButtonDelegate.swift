//
//  CommunityListingButtonDelegate.swift
//  higi
//
//  Created by Remy Panicker on 4/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//


final class CommunityListingButtonDelegate {
    
    weak var presentingViewController: UIViewController?
    var segueIdentifier: String?
    var userInfo: AnyObject?
    
    convenience init(presentingViewController: UIViewController?, segueIdentifier: String?, userInfo: AnyObject?) {
        self.init()
        self.presentingViewController = presentingViewController
        self.segueIdentifier = segueIdentifier
        self.userInfo = userInfo
    }
}

extension CommunityListingButtonDelegate {
    
    dynamic func didTapSegueButton(sender: UIButton) {
        
        guard let presentingViewController = presentingViewController,
            let segueIdentifer = segueIdentifier,
            let userInfo = userInfo else { return }
        
        presentingViewController.performSegueWithIdentifier(segueIdentifer, sender: userInfo)
    }
}
