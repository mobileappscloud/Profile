//
//  DrawerViewController.swift
//  higi
//
//  Created by Dan Harms on 8/1/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class DrawerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var blurryBackground: UIImageView!
    @IBOutlet weak var scoreRing: UIView!
    @IBOutlet weak var scoreRingMask: UIView!
    @IBOutlet weak var higiScoreTitleLabel: UILabel! {
        didSet {
            higiScoreTitleLabel.text = NSLocalizedString("DRAWER_VIEW_HIGI_SCORE_TITLE", comment: "Title for higi Score")
        }
    }
    @IBOutlet weak var higiScore: UILabel!
    @IBOutlet weak var name: UILabel!
    
    var navController: UINavigationController?;
    
    var revealController: SWRevealViewController?;
    
    var navigationObjects:[NavigationObject] = [];
    
    var arc: CAShapeLayer!, circle: CAShapeLayer!;
    
    let dashboardTitle = NSLocalizedString("DRAWER_VIEW_MENU_ITEM_TITLE_DASHBOARD", comment: "Title for dashboard drawer menu item.")
    let challengesTitle = NSLocalizedString("DRAWER_VIEW_MENU_ITEM_TITLE_CHALLENGES", comment: "Title for challenges drawer menu item.")
    let metricsTitle = NSLocalizedString("DRAWER_VIEW_MENU_ITEM_TITLE_METRICS", comment: "Title for metrics drawer menu item.")
    let stationLocatorTitle = NSLocalizedString("DRAWER_VIEW_MENU_ITEM_TITLE_STATION_LOCATOR", comment: "Title for station locator drawer menu item.")
    let pulseTitle = NSLocalizedString("DRAWER_VIEW_MENU_ITEM_TITLE_PULSE", comment: "Title for pulse drawer menu item.")
    let settingsTitle = NSLocalizedString("DRAWER_VIEW_MENU_ITEM_TITLE_SETTINGS", comment: "Title for settings drawer menu item.")
    let captureTitle = NSLocalizedString("DRAWER_VIEW_MENU_ITEM_TITLE_CAPTURE", comment: "Title for capture drawer menu item.")
    
    override func viewDidLoad() {
        super.viewDidLoad();
        initNavigationObjects();
        tableView.selectRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
        refreshData();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        setScore();
        self.setNeedsStatusBarAppearanceUpdate();
    }
    
    func initNavigationObjects() {
        navigationObjects.append(NavigationObject(title: dashboardTitle, icon: "oc_dashboard.png", activeIcon: "oc_dashboard_active.png", callback:
            { (index: NSIndexPath) in
            self.navController?.popToRootViewControllerAnimated(false);
        }));
        navigationObjects.append(NavigationObject(title: challengesTitle, icon: "oc_challenges.png", activeIcon: "oc_challenges_active", callback: {
            (index: NSIndexPath) in
            if (SessionController.Instance.challenges == nil) {
                self.tableView.deselectRowAtIndexPath(index, animated: false);
                return;
            }
            Flurry.logEvent("ChallengesOffCanvas_Pressed");
            self.navController?.pushViewController(ChallengesViewController(nibName: "ChallengesView", bundle: nil), animated: false);
        }));
        navigationObjects.append(NavigationObject(title: metricsTitle, icon: "oc_bodystats.png", activeIcon: "oc_bodystats_active.png", callback: { (index: NSIndexPath) in
            if (SessionController.Instance.checkins == nil || !SessionController.Instance.loadedActivities) {
                return;
            }
            Flurry.logEvent("MetricsOffCanvas_Pressed");
            self.tableView.deselectRowAtIndexPath(index, animated: false);
            self.navController?.pushViewController(MetricsViewController(), animated: true);
        }));
        navigationObjects.append(NavigationObject(title: stationLocatorTitle, icon: "oc_findastation.png", activeIcon: "oc_findastation_active.png", callback: { (index: NSIndexPath) in
            Flurry.logEvent("FindStationOffCanvas_Pressed");
            self.navController?.popToRootViewControllerAnimated(false);
            self.navController?.pushViewController(FindStationViewController(nibName: "FindStationView", bundle: nil), animated: false);
        }));
        navigationObjects.append(NavigationObject(title: pulseTitle, icon: "oc_pulse.png", activeIcon: "oc_pulse_active.png", callback: {
            (index: NSIndexPath) in
            Flurry.logEvent("HigiPulseOffCanvas_Pressed");
            self.navController?.pushViewController(PulseHomeViewController(nibName: "PulseHomeView", bundle: nil), animated: false);
        }));
        navigationObjects.append(NavigationObject(title: settingsTitle, icon: "oc_settings.png", activeIcon: "oc_settings_active.png", callback: {
            (index: NSIndexPath) in
            Flurry.logEvent("SettingsOffCanvas_Pressed");
            let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil);
            let settingsViewController = settingsStoryboard.instantiateInitialViewController();
            self.navController?.pushViewController(settingsViewController!, animated: false);
        }));
        navigationObjects.append(NavigationObject(title: captureTitle, icon: "oc_qr.png", activeIcon: "oc_qr.png", callback: {
            (index: NSIndexPath) in
            Flurry.logEvent("QrCodeOffCanvas_Pressed");
            self.tableView.deselectRowAtIndexPath(index, animated: false);
            self.navController?.pushViewController(QrScannerViewController(nibName: "QrScannerView", bundle: nil), animated: false);
        }));
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DrawerCell") as! DrawerCell!;
        if (cell == nil) {
            cell = UINib(nibName: "DrawerCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DrawerCell;
            let selectedBgView = UIView();
            selectedBgView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.06)
            cell.selectedBackgroundView = selectedBgView;
        }
        cell.title.text = navigationObjects[indexPath.item].title;
        if (tableView.indexPathForSelectedRow != nil && indexPath.item == tableView.indexPathForSelectedRow!.item && navigationObjects[indexPath.item].title != metricsTitle && navigationObjects[indexPath.item].title != captureTitle) {
            cell.icon.image = UIImage(named: navigationObjects[indexPath.item].activeIcon);
        } else {
            cell.icon.image = UIImage(named: navigationObjects[indexPath.item].icon);
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationObjects[indexPath.row].callback(indexPath);
        revealController?.revealToggleAnimated(true);
        if navigationObjects[indexPath.item].title != metricsTitle && navigationObjects[indexPath.item].title != captureTitle {
            tableView.reloadData();
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! DrawerCell;
            cell.icon.image = UIImage(named: navigationObjects[indexPath.item].activeIcon);
            cell.selected = true;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navigationObjects.count;
    }
    
    func selectRowAtIndex(index: Int) {
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    func refreshData() {
        blurryBackground.image = SessionData.Instance.user.blurredImage;
        profileImage.image = SessionData.Instance.user.profileImage;
        name.text = "\(SessionData.Instance.user.firstName) \(SessionData.Instance.user.lastName)";
        setScore();
    }
    
    func setScore() {
        let score = SessionData.Instance.user.currentHigiScore;
        higiScore.text = "0";
        if (score > 0) {
            if (arc == nil) {
                scoreRingMask.hidden = false;
                scoreRingMask.frame = CGRect(x: 43, y: 86, width: 14, height: 14);
                arc = CAShapeLayer();
                arc.lineWidth = 14;
                arc.fillColor = UIColor.whiteColor().CGColor;
                arc.strokeColor = Utility.colorFromHexString(Constants.higiGreen).CGColor;
                
                let toPath = UIBezierPath();
                let center = CGPoint(x: 50.0, y: 50.0);
                let radius: CGFloat = 43.0;
                let startingPoint = CGPoint(x: center.x, y: center.y + radius);
                toPath.moveToPoint(startingPoint);
                toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(5 * M_PI_2), clockwise: true);
                toPath.closePath();
                
                arc.path = toPath.CGPath;
                scoreRing.layer.addSublayer(arc);
            }
            scoreRingMask.frame.origin = CGPoint(x: 43, y: 86);
            scoreRingMask.hidden = false;
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            arc.strokeStart = 0.0;
            let percent = Double(score) / 999.0;
            arc.strokeEnd = CGFloat(percent);
            CATransaction.setDisableActions(false);
            CATransaction.commit();
            higiScore.text = "\(score)";
            let theta = percent * M_PI * 2 + M_PI_2;
            let x = 43.0 * cos(theta) + 43.0;
            let y = 43.0 * sin(theta) + 43.0;
            scoreRingMask.frame.origin = CGPoint(x: x, y: y);
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
}
