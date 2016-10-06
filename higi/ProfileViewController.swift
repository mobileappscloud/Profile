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
    //User Interface Header
    @IBOutlet weak var followersLabel: UILabel! {
        didSet {
            followersLabel.textColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
        }
    }
    
    @IBOutlet weak var followersNumber: UILabel! {
        didSet {
            followersNumber.textColor = UIColor(red:0.19, green:0.43, blue:0.86, alpha:1.0)
        }
    }
    @IBOutlet weak var followingLabel: UILabel! {
        didSet {
            followersLabel.textColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
        }
    }
    @IBOutlet weak var followingNumber: UILabel! {
        didSet {
            followingNumber.textColor = UIColor(red:0.19, green:0.43, blue:0.86, alpha:1.0)
        }
    }
    @IBOutlet weak var locationLabel: UILabel! {
        didSet {
            locationLabel.textColor = UIColor(red:0.35, green:0.35, blue:0.35, alpha:1.0)
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.textColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
        }
    }
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            followButton.backgroundColor = UIColor(red:0.19, green:0.43, blue:0.86, alpha:1.0)
            followButton.layer.cornerRadius = 10
            followButton.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    //Empty View Controllers for now
    
    let wattsVC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("wattsID") as! WattsViewController
    
    let achievementsVC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("achievementsID") as! AchievementsViewController
    
    let communitiesVC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("communitiesID") as! CommunitiesVC
    
    let challengesVC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("challengesID") as!ChallengesVC
    
    let userProfileViewController:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewControllerWithIdentifier("userProfileID") as! UserProfileViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "segmentShow" {
            guard let viewController = segue.destinationViewController as? SegmentedPageViewController else { return }
            
            let viewControllers: [UIViewController] = [wattsVC, achievementsVC, communitiesVC, challengesVC]
            
            let titles = ["Watts", "Achievements", "Communities", "Challenges"]
            
            let segmentedPageViewController = viewController
            
            segmentedPageViewController.set(viewControllers, titles: titles)
            
            let horizontalMargin: CGFloat = 5.0
            segmentedPageViewController.segmentedControlHorizontalMargin = horizontalMargin
        }
    }
}
