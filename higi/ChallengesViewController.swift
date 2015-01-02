import Foundation

class ChallengesViewController: BaseViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var activeChallengesTable: UITableView!
    @IBOutlet var upcomingChallengesTable: UITableView!
    @IBOutlet var availableChallengesTable: UITableView!
    @IBOutlet var invitationsTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    
    
    let pageTitles:[String] = ["Active Challenges","Upcoming Challenges","Available Challenges","Invitations"];
    var activeChallenges:[HigiChallenge] = [];
    var upcomingChallenges:[HigiChallenge] = [];
    var availableChallenges:[HigiChallenge] = [];
    var invitations:[HigiChallenge] = [];
    
    struct ViewConstants {
        static let footerHeight:CGFloat = 10;
        static let viewWidth:CGFloat = 320;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        pager.currentPage = 0;
        title = pageTitles[0];
        
        var session = SessionController.Instance;
        
        for challenge:HigiChallenge in session.challenges {
            switch(challenge.userStatus) {
            case "current":
                activeChallenges.append(challenge);
            case "public":
                availableChallenges.append(challenge);
            case "upcoming":
                upcomingChallenges.append(challenge);
            case "invited":
                invitations.append(challenge);
            default:
                var i = 0;
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 4, height: scrollView.frame.size.height);
        scrollView.setContentOffset(CGPointMake(0,0),animated: false);
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0;
        if (activeChallengesTable == tableView) {
            count = activeChallenges.count;
        } else if (upcomingChallengesTable == tableView) {
            count = upcomingChallenges.count;
        } else if (availableChallengesTable == tableView) {
            count = availableChallenges.count;
        } else if (invitationsTable == tableView) {
            count = invitations.count;
        }
        return count;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 83));
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChallengeRowCell") as ChallengeRowCell!;
        
        if (cell == nil) {
            cell = UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell
        }

        //remove all children before populating scrollview
        for subview in cell.scrollView.subviews {
            subview.removeFromSuperview();
        }
        
        
        //load the appropriate challenges for this table
        var challenges:[HigiChallenge] = [];
        var challengeType = "";
        if (tableView == activeChallengesTable) {
            challenges = activeChallenges;
            challengeType = "active";
        } else if (tableView == upcomingChallengesTable) {
            challenges = upcomingChallenges;
            challengeType = "available";
        } else if (tableView == availableChallengesTable) {
            challenges = availableChallenges;
            challengeType = "upcoming";
        } else {
            challenges = invitations;
            challengeType = "invitation";
        }
        let isActiveChallenge = challengeType == "active";
        cell = buildChallengeCell(cell, challenge: challenges[indexPath.row], isActive: isActiveChallenge);
        
        if (challengeType == "available") {
            cell.join.hidden = true;
        }
        if (challenges.count == 0) {
//            cell = buildEmptyCell(cell);
        } else {
            let challenge = challenges[indexPath.row];
            cell.title.text = challenge.name;
            cell.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.imageUrl));
        }
        
        let footer = UIView(frame: CGRect(x: 0, y: cell.frame.height - ViewConstants.footerHeight, width: cell.frame.width, height: ViewConstants.footerHeight));
        footer.backgroundColor = Utility.colorFromHexString("#EEEEEE");
        cell.addSubview(footer);
        
        return cell;
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    func buildEmptyCell(cell: ChallengeRowCell) {
        
    }
    
    func buildChallengeCell(cell: ChallengeRowCell, challenge: HigiChallenge, isActive: Bool) -> ChallengeRowCell {
        if (isActive) {
            return buildActiveCell(cell, challenge: challenge);
        } else {
            return buildInvitationCell(cell, challenge: challenge);
        }
    }
    
    func buildActiveCell(cell: ChallengeRowCell, challenge: HigiChallenge) -> ChallengeRowCell {
        var nibOriginX:CGFloat = 0.0;
        
        var nibs = Utility.getChallengeViews(challenge);
        for nib in nibs {
            nib.frame.origin.x = nibOriginX;
            cell.scrollView.addSubview(nib);
            nibOriginX += max(nib.frame.width, ViewConstants.viewWidth);
        }
        cell.pager.numberOfPages = nibs.count;
        cell.pager.currentPage = 0;
        
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * CGFloat(nibs.count), height: cell.frame.size.height - 45);
        
        var daysLeft:Int = 0
        var endDate:NSDate? = challenge.endDate?
        if (endDate != nil) {
            var compare:NSTimeInterval = endDate!.timeIntervalSinceNow
            if (Int(compare) > 0) {
                daysLeft = Int(compare) / 60 / 60 / 24
            }
        }
        cell.daysLeft.text = "\(daysLeft)d left";
        cell.join.hidden = true;
        return cell;
    }
    
    func buildInvitationCell(cell: ChallengeRowCell, challenge: HigiChallenge) -> ChallengeRowCell {
        var invitationView = ChallengeInvitationView.instanceFromNib(challenge);

        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width, height: cell.frame.size.height);
        cell.scrollView.addSubview(invitationView);
        cell.daysLeft.hidden = true;
        return cell;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        pager.currentPage = page;
        changePage(pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var page = pager.currentPage;
        title = pageTitles[page];
        
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false;
    }
}