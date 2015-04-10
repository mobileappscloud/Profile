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
    @IBOutlet weak var higiScore: UILabel!
    @IBOutlet weak var name: UILabel!
    
    var navController: UINavigationController?;
    
    var revealController: SWRevealViewController?;
    
    let titles = ["Dashboard", "Activity", "Challenges", "Body Stats", "Find a Station", "higi Pulse", "Settings"];
    
    let icons = ["oc_dashboard.png", "oc_activity.png", "oc_challenges.png", "oc_bodystats.png", "oc_findastation.png", "oc_pulse.png", "oc_settings.png"];
    
    let activeIcons = ["oc_dashboard_active.png", "oc_activity_active.png", "oc_challenges_active", "oc_bodystats_active.png", "oc_findastation_active.png", "oc_pulse_active.png", "oc_settings_active.png"];
    
    var arc: CAShapeLayer!, circle: CAShapeLayer!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.selectRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
        refreshData();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        setScore();
        self.setNeedsStatusBarAppearanceUpdate();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DrawerCell") as! DrawerCell!;
        if (cell == nil) {
            cell = UINib(nibName: "DrawerCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DrawerCell;
            var selectedBgView = UIView();
            selectedBgView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.06)
            cell.selectedBackgroundView = selectedBgView;
        }
        cell.title.text = titles[indexPath.item];
        if (tableView.indexPathForSelectedRow() != nil && indexPath.item == tableView.indexPathForSelectedRow()!.item) {
            cell.icon.image = UIImage(named: activeIcons[indexPath.item]);
        } else {
            cell.icon.image = UIImage(named: icons[indexPath.item]);
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.item) {
        case 0:
            navController?.popToRootViewControllerAnimated(false);
        case 1:
            if (SessionController.Instance.activities == nil) {
                return;
            }
            Flurry.logEvent("ActivityOffCanvas_Pressed");
            navController?.pushViewController(ActivityViewController(nibName: "ActivityView", bundle: nil), animated: false);
        case 2:
            if (SessionController.Instance.challenges == nil) {
                return;
            }
            Flurry.logEvent("ChallengesOffCanvas_Pressed");
            navController?.pushViewController(ChallengesViewController(nibName: "ChallengesView", bundle: nil), animated: false);
        case 3:
            if (SessionController.Instance.checkins == nil) {
                return;
            }
            Flurry.logEvent("BodystatOffCanvas_Pressed");
            navController?.pushViewController(BodyStatsViewController(), animated: false);
        case 4:
            Flurry.logEvent("FindStationOffCanvas_Pressed");
            navController?.popToRootViewControllerAnimated(false);
            navController?.pushViewController(FindStationViewController(nibName: "FindStationView", bundle: nil), animated: false);
        case 5:
            Flurry.logEvent("HigiPulseOffCanvas_Pressed");
            navController?.pushViewController(PulseHomeViewController(nibName: "PulseHomeView", bundle: nil), animated: false);
        case 6:
            Flurry.logEvent("SettingsOffCanvas_Pressed");
            navController?.pushViewController(SettingsViewController(nibName: "SettingsView", bundle: nil), animated: false);
        default:
            navController?.popToRootViewControllerAnimated(false);
        }
        revealController?.revealToggleAnimated(true);
        tableView.reloadData();
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! DrawerCell;
        cell.icon.image = UIImage(named: activeIcons[indexPath.item]);
        cell.selected = true;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count;
    }
    
    func refreshData() {
        blurryBackground.image = SessionData.Instance.user.blurredImage;
        profileImage.image = SessionData.Instance.user.profileImage;
        name.text = "\(SessionData.Instance.user.firstName) \(SessionData.Instance.user.lastName)";
        setScore();
    }
    
    func setScore() {
        var score = SessionData.Instance.user.currentHigiScore;
        higiScore.text = "0";
        if (score > 0) {
            if (arc == nil) {
                scoreRingMask.hidden = false;
                scoreRingMask.frame = CGRect(x: 43, y: 86, width: 14, height: 14);
                arc = CAShapeLayer();
                arc.lineWidth = 14;
                arc.fillColor = UIColor.whiteColor().CGColor;
                arc.strokeColor = Utility.colorFromHexString("#76C044").CGColor;
                
                var toPath = UIBezierPath();
                var center = CGPoint(x: 50.0, y: 50.0);
                var radius: CGFloat = 43.0;
                var startingPoint = CGPoint(x: center.x, y: center.y + radius);
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
            var percent = Double(score) / 999.0;
            arc.strokeEnd = CGFloat(percent);
            CATransaction.setDisableActions(false);
            CATransaction.commit();
            higiScore.text = "\(score)";
            var theta = percent * M_PI * 2 + M_PI_2;
            var x = 43.0 * cos(theta) + 43.0;
            var y = 43.0 * sin(theta) + 43.0;
            scoreRingMask.frame.origin = CGPoint(x: x, y: y);
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
}
