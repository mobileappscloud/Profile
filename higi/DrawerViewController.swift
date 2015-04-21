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
    
    var navController: UINavigationController?;
    
    var revealController: SWRevealViewController?;
    
    let titles = ["Dashboard", "Body Stats", "Find a Station", "higi Pulse", "Settings"];
    
    let icons = ["oc_dashboard.png", "oc_bodystats.png", "oc_findastation.png", "oc_pulse.png", "oc_settings.png"];
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.selectRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DrawerCell") as! DrawerCell!;
        if (cell == nil) {
            cell = UINib(nibName: "DrawerCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DrawerCell;
            var selectedBgView = UIView();
            selectedBgView.backgroundColor = Utility.colorFromHexString("#EFEFEF");
            cell.selectedBackgroundView = selectedBgView;
        }
        cell.title.text = titles[indexPath.item];
        cell.icon.image = UIImage(named: icons[indexPath.item]);
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.item) {
        case 0:
            navController?.popToRootViewControllerAnimated(false);
        case 1:
<<<<<<< HEAD
=======
            if (SessionController.Instance.activities == nil) {
                tableView.deselectRowAtIndexPath(indexPath, animated: false);
                return;
            }
            Flurry.logEvent("ActivityOffCanvas_Pressed");
            navController?.pushViewController(ActivityViewController(nibName: "ActivityView", bundle: nil), animated: false);
        case 2:
            if (SessionController.Instance.challenges == nil) {
                tableView.deselectRowAtIndexPath(indexPath, animated: false);
                return;
            }
            Flurry.logEvent("ChallengesOffCanvas_Pressed");
            navController?.pushViewController(ChallengesViewController(nibName: "ChallengesView", bundle: nil), animated: false);
        case 3:
            if (SessionController.Instance.checkins == nil) {
                return;
            }
>>>>>>> develop
            Flurry.logEvent("BodystatOffCanvas_Pressed");
            navController?.pushViewController(BodyStatsViewController(), animated: false);
        case 2:
            Flurry.logEvent("FindStationOffCanvas_Pressed");
            navController?.popToRootViewControllerAnimated(false);
            navController?.pushViewController(FindStationViewController(nibName: "FindStationView", bundle: nil), animated: false);
        case 3:
            Flurry.logEvent("HigiPulseOffCanvas_Pressed");
            navController?.pushViewController(PulseHomeViewController(nibName: "PulseHomeView", bundle: nil), animated: false);
        case 4:
            Flurry.logEvent("SettingsOffCanvas_Pressed");
            navController?.pushViewController(SettingsViewController(nibName: "SettingsView", bundle: nil), animated: false);
        default:
            navController?.popToRootViewControllerAnimated(false);
        }
        revealController?.revealToggleAnimated(true);
<<<<<<< HEAD
        
=======
        tableView.reloadData();
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! DrawerCell;
        cell.icon.image = UIImage(named: activeIcons[indexPath.item]);
        cell.selected = true;
>>>>>>> develop
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count;
    }
    
}
