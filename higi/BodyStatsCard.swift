//
//  BodyStatsCard.swift
//  higi
//
//  Created by Dan Harms on 1/20/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class BodyStatsCard: UIView {
    
    @IBOutlet weak var bpButton: UIButton!
    @IBOutlet weak var pulseButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var bmiButton: UIButton!
    @IBOutlet weak var lastCheckin: UILabel!
    @IBOutlet weak var lastCheckinBox: UIView!
    
    @IBAction func bodyStatClicked(sender: AnyObject) {
        Flurry.logEvent("Bodystat_Pressed");
        var bodyStatsViewController = BodyStatsViewController();
        var tag = sender.tag;
        bodyStatsViewController.currentPage = sender.tag;
        var viewController = Utility.getViewController(self);
        viewController!.navigationController!.pushViewController(bodyStatsViewController, animated: true);
        (viewController!.navigationController as! MainNavigationController).drawerController?.tableView.reloadData();
        (viewController!.navigationController as! MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 3, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
}