//
//  RevealViewController.swift
//  higi
//
//  Created by Dan Harms on 8/1/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation


class RevealViewController: SWRevealViewController {
    
    var shouldRotate = false;
    
    var supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue;
    
    var preferredOrientation = UIInterfaceOrientation.Portrait;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.addGestureRecognizer(self.panGestureRecognizer());
    }
    
    override func shouldAutorotate() -> Bool {
        return shouldRotate && self.frontViewPosition != FrontViewPosition.Right;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if (self.frontViewPosition == FrontViewPosition.Right) {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue);
        } else {
            return Int(supportedOrientations);
        }
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return preferredOrientation;
    }
}