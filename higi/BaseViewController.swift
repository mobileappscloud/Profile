//
//  BaseViewController.swift
//  higi
//
//  Created by Dan Harms on 7/30/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class BaseViewController: UIViewController, SWRevealViewControllerDelegate {
    
    var fakeNavBar = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 64));
    
    var pointsMeter: PointsMeter!;
    
    var toggleButton: UIButton?;
    
    var revealController: RevealViewController!;
    
    var pointsSet = false;
    
    var shouldShowDailyPoints = true;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        revealController = (self.navigationController as? MainNavigationController)?.revealController
        revealController?.shouldRotate = false;
        revealController?.supportedOrientations = UIInterfaceOrientationMask.Portrait;
        self.view.addSubview(fakeNavBar);
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()];
        self.fakeNavBar.backgroundColor = UIColor.whiteColor();
        self.fakeNavBar.alpha = 0;
        self.fakeNavBar.userInteractionEnabled = false;
        
        if (shouldShowDailyPoints) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveApiNotification:", name: ApiUtility.ACTIVITIES, object: nil);
        }
        toggleButton = UIButton(type: .Custom);
        toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon.png"), forState: UIControlState.Normal);
        toggleButton!.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        toggleButton!.addTarget(self, action: Selector("toggleMenu:"), forControlEvents: UIControlEvents.TouchUpInside);
        let menuToggle = UIBarButtonItem(customView: toggleButton!);
        navigationItem.leftBarButtonItem = menuToggle;
        navigationItem.hidesBackButton = true;
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        revealController?.panGestureRecognizer().enabled = true;
        revealController?.delegate = self;
        if (shouldShowDailyPoints) {
            initDailyPoints();
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        if (revealController == self) {
            revealController.delegate = nil;
        }
    }
    
    func receiveApiNotification(notification: NSNotification) {
        switch (notification.name) {
        case ApiUtility.ACTIVITIES:
            if shouldShowDailyPoints {
                setDailyPoints(true);
            }
        default:
            break;
        }
    }
    
    func initDailyPoints() {
        let summaryBarItem = UIBarButtonItem();
        pointsMeter = PointsMeter.create(CGRect(x: 0, y: 0, width: 30, height: 30));
        let tap = UITapGestureRecognizer(target: self, action: "gotoSummary:");
        pointsMeter.addGestureRecognizer(tap);
        summaryBarItem.customView = pointsMeter;
        self.navigationItem.rightBarButtonItem = summaryBarItem;
        setDailyPoints(false);
        pointsMeter.hidden = !SessionController.Instance.loadedActivities;
    }
    
    func setDailyPoints(animated: Bool) {
        let dateString = Constants.dateFormatter.stringFromDate(NSDate());
        if let (total, todaysActivities) = SessionController.Instance.activities[dateString] {
            pointsMeter.setActivities((total, todaysActivities));
            pointsMeter.drawArc(animated);
        } else {
            pointsMeter.setActivities((0, []));
            pointsMeter.drawArc(false);
        }
        pointsMeter.hidden = false;
    }
    
    func toggleMenu(sender: AnyObject!) {
        (self.navigationController as! MainNavigationController).revealController?.revealToggleAnimated(true);
    }
    
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        self.view.userInteractionEnabled = position != FrontViewPosition.Right;
    }
    
    func gotoSummary(sender: AnyObject) {
        Flurry.logEvent("Summary_Pressed");
        let summaryController = DailySummaryViewController(nibName: "DailySummaryView", bundle: nil);
        self.navigationController!.pushViewController(summaryController, animated: true);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
}
