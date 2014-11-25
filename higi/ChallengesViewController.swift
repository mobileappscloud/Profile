//
//  ChallengesViewController.swift
//  higi
//
//  Created by Joe Sangervasi on 10/31/14.
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
            
            switch(challenge.userStatus) {
                case "current":
                    activeChallenges.append(challenge)
                case "public":
                    //@todo check challenge status
                    availableChallenges.append(challenge)
                case "upcoming":
                    upcomingChallenges.append(challenge)
                case "invited":
                    invitations.append(challenge)
                default:
                    println("No challenges")
                    println("challenge \(challenge.status)")
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
    
    func populateView(challenge:HigiChallenge, winConditions:[ChallengeWinCondition]) -> UIView {
        
        var competitiveView:CompetitiveChallengeView!
        var goalView:GoalChallengeView!
        var nib:UIView!
        var count = 0
        
        //build win conditions
        for wincondition in winConditions {
            var winconditionName = wincondition.name
            var winnerType = wincondition.winnerType
            var goalMin = wincondition.goal.minThreshold
            var goalMax = wincondition.goal.maxThreshold
            var goalType = wincondition.goal.type
            
            switch(goalType) {
                case "most_points":
                    competitiveView = CompetitiveChallengeView.instanceFromNib()
                case "threshold_reached":
                fallthrough
                case "unit_goal_reached":
                fallthrough
                default:
                    goalView = GoalChallengeView.instanceFromNib()
            }

            if ( competitiveView != nil ) {
                if( challenge.userStatus == "current" ) {
                    var gb = challenge.gravityBoard
                    
                    for var i = 0;i < gb.count;i++ {
                        if ( i == 0 ) {
                            competitiveView.firstPositionName.text = gb[i].participant.displayName
                            competitiveView.firstPositionPoints.text = "\(Int(gb[i].participant.units)) pts"
                            competitiveView.firstPositionRank.text = self.getRankSuffix(gb[i].place)
                            competitiveView.firstPositionAvatar.setImageWithURL(self.loadImageFromUrl(gb[i].participant.imageUrl))
                        } else if ( i == 1 ) {
                            competitiveView.secondPositionName.text = gb[i].participant.displayName
                            competitiveView.secondPositionPoints.text = "\(Int(gb[i].participant.units)) pts"
                            competitiveView.secondPositionRank.text = self.getRankSuffix(gb[i].place)
                            competitiveView.secondPositionAvatar.setImageWithURL(self.loadImageFromUrl(gb[i].participant.imageUrl))
                        } else {
                            competitiveView.thirdPositionName.text = gb[i].participant.displayName
                            competitiveView.thirdPositionPoints.text = "\(Int(gb[i].participant.units)) pts"
                            competitiveView.thirdPositionRank.text = self.getRankSuffix(gb[i].place)
                            competitiveView.thirdPositionAvatar.setImageWithURL(self.loadImageFromUrl(gb[i].participant.imageUrl))
                        }
                    }
                }
                
                nib = competitiveView
            }
            
            if ( goalView != nil ) {
                if( challenge.userStatus == "current" ) {
                    goalView.avatar.setImageWithURL(self.loadImageFromUrl(challenge.participant.imageUrl))
                    goalView.rank.text = self.getRankSuffix(challenge.gravityBoard[count].place)
                }
                
                nib = goalView
            }
            count++
        }
        
        return nib
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //@todo fix the scrolling issue maybe an autolayout issue
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

        //load the appropriate challenges for this table
        var challenges:[HigiChallenge] = []
        if( tableView == activeChallengesTable) {
            challenges = activeChallenges
            cell = self.buildChallengeCell(cell, challenges: challenges, indexPath: indexPath)
        } else if ( tableView == upcomingChallengesTable ) {
            challenges = upcomingChallenges
            cell = self.buildInvitationCell(cell, challenges: challenges, indexPath: indexPath)
        } else if ( tableView == availableChallengesTable ) {
            challenges = availableChallenges
            if ( challenges[indexPath.row].status == "running" ) {
                cell = self.buildChallengeCell(cell, challenges: challenges, indexPath: indexPath)
            } else {
                cell = self.buildInvitationCell(cell, challenges: challenges, indexPath: indexPath)
            }
        } else {
            challenges = invitations
            cell = self.buildInvitationCell(cell, challenges: challenges, indexPath: indexPath)
        }
        
        return cell
    }
    
    func buildChallengeCell(cell: ChallengeRowCell, challenges: [HigiChallenge], indexPath: NSIndexPath) ->  ChallengeRowCell {
        var nibOriginX:CGFloat = 0.0
        
        //@todo fix sizing issue
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * CGFloat(challenges[indexPath.row].winConditions.count), height: cell.frame.size.height - 45);
        
        var winconditions:[ChallengeWinCondition] = []
        var lastWinCondition:ChallengeWinCondition!
        var challenge = challenges[indexPath.row]
        for wincondition in challenges[indexPath.row].winConditions {
            var goalType = wincondition.goal.type
            var winnerType = wincondition.winnerType
            
            if lastWinCondition != nil && (goalType != lastWinCondition.goal.type || winnerType != lastWinCondition.winnerType) {
                var nib = populateView(challenge,winConditions: winconditions)
                nib.frame.origin.x = nibOriginX
                
                cell.scrollView.addSubview(nib)
                
                nibOriginX += nib.frame.width
                winconditions = []
            }
            
            winconditions.append(wincondition)
            lastWinCondition = wincondition
        }
        
        if winconditions.count > 0 {
            var nib = populateView(challenge,winConditions: winconditions)
            nib.frame.origin.x = nibOriginX
            
            cell.scrollView.addSubview(nib)
        }
        
        //populate cell contents
        cell.title.text = challenges[indexPath.row].name
        
        var daysLeft:Int = 0
        var endDate:NSDate? = challenges[indexPath.row].endDate?
        if ( endDate != nil ) {
            var compare:NSTimeInterval = endDate!.timeIntervalSinceNow
        
            if ( Int(compare) > 0) {
                daysLeft = Int(compare) / 60 / 60 / 24
            }
        }
        cell.daysLeft.text = "\(daysLeft)d left"
        
        cell.avatar.setImageWithURL(self.loadImageFromUrl(challenges[indexPath.row].imageUrl))

        return cell
    }
    
    func buildInvitationCell(cell: ChallengeRowCell, challenges: [HigiChallenge], indexPath: NSIndexPath) ->  ChallengeRowCell {
        var invitationView = UINib(nibName: "ChallengeInvitation", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeInvitationView;
        
        invitationView.title.text = challenges[indexPath.row].name
        invitationView.avatar.setImageWithURL(self.loadImageFromUrl(challenges[indexPath.row].imageUrl))
        invitationView.goal.text = challenges[indexPath.row].winConditions[indexPath.row].goal.type
        invitationView.type.text = challenges[indexPath.row].winConditions[indexPath.row].winnerType
        invitationView.prize.text = challenges[indexPath.row].winConditions[indexPath.row].prizeName
        invitationView.participantCount.text = String(challenges[indexPath.row].participantsCount)
        //invitationView.inviter.text = challenges[indexPath.row].participant.displayName
        var days:Int = 0
        var message:String!
        var startDate:NSDate? = challenges[indexPath.row].startDate?
        var endDate:NSDate? = challenges[indexPath.row].endDate?
        if ( startDate != nil ) {
            var compare:NSTimeInterval = startDate!.timeIntervalSinceNow
            
            if ( Int(compare) > 0) {
                days = Int(compare) / 60 / 60 / 24
                message = "Starts in \(days) days!"
            } else if ( Int(compare) < 0 ) {
                days = abs(Int(compare)) / 60 / 60 / 24
                message = "Started \(days) days ago!"
            } else {
                message = "Starting today!"
            }
        }
        invitationView.starting.text = message
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        var startDateShort = formatter.stringFromDate(startDate!)
        var endDateShort = formatter.stringFromDate(endDate!)
        
        invitationView.dateRange.text = "\(startDateShort) - \(endDateShort)"
        
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width, height: cell.frame.size.height);
        cell.scrollView.addSubview(invitationView)
        
        cell.title.removeFromSuperview()
        cell.avatar.removeFromSuperview()
        cell.daysLeft.removeFromSuperview()
        
        return cell
    }
    
    func getRankSuffix(rank: NSString) -> String {
        if ( rank == "11" || rank == "12" || rank == "13") {
            return rank + "th"
        }
        
        let last = rank.substringFromIndex(rank.length - 1)
        switch(last) {
            case "1":
            return rank + "st"
            case "2":
            return rank + "nd"
            case "3":
            return rank + "rd"
            default:
            return rank + "th"
        }
    }
    
    func loadImageFromUrl(imageUrlString: String) -> NSURL {
        if (!imageUrlString.isEmpty) {
            let imageUrl = NSURL(string: imageUrlString)?;
            if let imageError = imageUrl?.checkResourceIsReachableAndReturnError(NSErrorPointer()) {
                if( !imageError ) {
                    return imageUrl!;
                }
            }
        }
        return NSURL()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        self.pager.currentPage = page;
        changePage(self.pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var page = self.pager.currentPage;
        self.title = pageTitles[page];
        self.currentPage = page
        
        var frame = self.scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        self.scrollView.setContentOffset(frame.origin, animated: true);
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}