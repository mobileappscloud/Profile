//
//  ChallengesViewController.swift
//  higi
//
//  Created by Dan Harms on 10/27/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ChallengesViewController: BaseViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var activeChallengesTable: UITableView!
    @IBOutlet var upcomingChallengesTable: UITableView!
    @IBOutlet var availableChallengesTable: UITableView!
    @IBOutlet var invitationsTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    
    var currentPage  = 0;
    
    let pageTitles:[String] = ["Active Challenges","Upcoming Challenges","Available Challenges","Invitations"]
    let activeChallengeTypes:Dictionary<Int,String> = [:]
    var activeChallenges:[HigiChallenge] = []
    var upcomingChallenges:[HigiChallenge] = []
    var availableChallenges:[HigiChallenge] = []
    var invitations:[HigiChallenge] = []
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.pager.currentPage = currentPage
        self.title = pageTitles[currentPage]
        
        var session = SessionController.Instance
        
        for challenge:HigiChallenge in session.challenges {
            println("status \(challenge.status)")
            
            switch(challenge.status) {
                case "running":
                fallthrough
                case "calculating":
                fallthrough
                case "finished":
                    activeChallenges.append(challenge)
                case "public":
                    availableChallenges.append(challenge)
                case "upcoming":
                    upcomingChallenges.append(challenge)
                case "invited":
                    invitations.append(challenge)
                default:
                    println("No challenges")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * 4, height: self.scrollView.frame.size.height);
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        println("scrolled to top")
        return true
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (activeChallengesTable == tableView) {
            return activeChallenges.count
        } else if (upcomingChallengesTable == tableView) {
            return upcomingChallenges.count
        } else if (availableChallengesTable == tableView) {
            return availableChallenges.count
        } else if (invitationsTable == tableView) {
            return invitations.count
        }
        
        return 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChallengeRowCell") as ChallengeRowCell!;
        if (cell == nil) {
            cell = UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell
        }
        cell.separatorInset = UIEdgeInsetsZero;
        if (UIDevice.currentDevice().systemVersion >= "8.0") {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
        //remove all children before populating scrollview
        for subview in cell.scrollView.subviews {
            subview.removeFromSuperview()
        }

        if (activeChallengesTable == tableView) {
            if (activeChallenges[indexPath.row].description == "Competitive") {
                var view = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView
                cell.scrollView.addSubview(view)
            } else {
                //@todo CGFloat(activeChallenges[indexPath.row].winConditions.count)
                cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * 2, height: cell.frame.size.height);
                var view = UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GoalChallengeView
                cell.scrollView.addSubview(view)
            }
        }
        
        if upcomingChallengesTable == tableView {
            if upcomingChallenges[indexPath.row].description == "Competitive" {
                var view = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView
                cell.scrollView.addSubview(view)
            } else {
                //@todo CGFloat(activeChallenges[indexPath.row].winConditions.count
                cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * 2, height: cell.frame.size.height);
                var view = UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GoalChallengeView
                cell.scrollView.addSubview(view)
            }
        }
        
        if availableChallengesTable == tableView {
            if availableChallenges[indexPath.row].description == "Competitive" {
                var view = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView
                cell.scrollView.addSubview(view)
            } else {
                //@todo CGFloat(activeChallenges[indexPath.row].winConditions.count
                cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * 2, height: cell.frame.size.height);
                var view = UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GoalChallengeView
                cell.scrollView.addSubview(view)
            }
        }
        
        if invitationsTable == tableView {
            if availableChallenges[indexPath.row].description == "Competitive" {
                var view = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView
                cell.scrollView.addSubview(view)
            } else {
                //@todo CGFloat(activeChallenges[indexPath.row].winConditions.count
                cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * 2, height: cell.frame.size.height);
                var view = UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GoalChallengeView
                cell.scrollView.addSubview(view)
            }
        }
        
        //tableView.sectionIndexBackgroundColor = UIColor.blueColor()
        //cell.backgroundColor = UIColor.greenColor()
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        self.pager.currentPage = page;
        changePage(self.pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        //var pager = sender as UIPageControl;
        var page = self.pager.currentPage;
        self.title = pageTitles[page];
        
        var frame = self.scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        self.scrollView.setContentOffset(frame.origin, animated: true);
        
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}