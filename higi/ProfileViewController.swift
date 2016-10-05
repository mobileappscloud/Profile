//
//  ProfileViewController.swift
//  higi
//
//  Created by Faisal Syed on 10/5/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit
import Foundation

class ProfileViewController: UIViewController
{
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    let wattsVC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("wattsID") as! WattsViewController
    
    let achievementsVC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("achievementsID") as! AchievementsViewController
    
    let communitiesVC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("communitiesID") as! CommunitiesVC
    
    let challengesVC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("challengesID") as! ChallengesVC
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "segmentShow" {
            guard let viewController = segue.destinationViewController as? SegmentedPageViewController else { return }
            
            let viewControllers = [wattsVC, achievementsVC, communitiesVC, challengesVC]
            let titles = ["Watts", "Achievements", "Communities", "Challenges"]
            
            let segmentedPageViewController = viewController
            segmentedPageViewController.set(viewControllers, titles: titles)
            
            if let segmentedControl = segmentedPageViewController.segmentedControl
            {
                print(segmentedControl)
            }
            
            else
            {
                print("no segment control")
            }
            
        }

    }
}
