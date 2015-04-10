//
//  BaseViewController.swift
//  higi
//
//  Created by Dan Harms on 7/30/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BaseViewController: UIViewController, SWRevealViewControllerDelegate {
    
    var fakeNavBar = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 64));
    
    var toggleButton: UIButton?;
    
    var revealController: RevealViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        revealController = (self.navigationController as! MainNavigationController).revealController;
        revealController.shouldRotate = false;
        revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue;
        self.view.addSubview(fakeNavBar);
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()];
        self.fakeNavBar.backgroundColor = UIColor.whiteColor();
        self.fakeNavBar.alpha = 0;
        self.fakeNavBar.userInteractionEnabled = false;
        
        toggleButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton;
        toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon.png"), forState: UIControlState.Normal);
        toggleButton!.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        toggleButton!.addTarget(self, action: Selector("toggleMenu:"), forControlEvents: UIControlEvents.TouchUpInside);
        var menuToggle = UIBarButtonItem(customView: toggleButton!);
        navigationItem.leftBarButtonItem = menuToggle;
        navigationItem.hidesBackButton = true;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        revealController.panGestureRecognizer().enabled = true;
        revealController.delegate = self;
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        if (revealController == self) {
            revealController.delegate = nil;
        }
    }
    
    func toggleMenu(sender: AnyObject!) {
        (self.navigationController as! MainNavigationController).revealController?.revealToggleAnimated(true);
    }
    
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        self.view.userInteractionEnabled = position != FrontViewPosition.Right;
    }
}
