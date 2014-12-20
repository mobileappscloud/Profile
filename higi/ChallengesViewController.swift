import Foundation

class ChallengesViewController: BaseViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var activeChallengesTable: UITableView!
    @IBOutlet var upcomingChallengesTable: UITableView!
    @IBOutlet var availableChallengesTable: UITableView!
    @IBOutlet var invitationsTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    
    var currentPage  = 0;
    
    let pageTitles:[String] = ["Active Challenges","Upcoming Challenges","Available Challenges","Invitations"];
    var activeChallenges:[HigiChallenge] = [];
    var upcomingChallenges:[HigiChallenge] = [];
    var availableChallenges:[HigiChallenge] = [];
    var invitations:[HigiChallenge] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        pager.currentPage = currentPage;
        title = pageTitles[currentPage];
        
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
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0;
        let x = section;
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
            subview.removeFromSuperview();
        }
        
        //load the appropriate challenges for this table
        var challenges:[HigiChallenge] = [];
        if (tableView == activeChallengesTable) {
            challenges = activeChallenges;
            cell.join.hidden = true;
            cell = buildChallengeCell(cell, challenge: challenges[indexPath.row]);
        } else if (tableView == upcomingChallengesTable) {
            challenges = upcomingChallenges;
            cell = buildInvitationCell(cell, challenge: challenges[indexPath.row]);
            cell.join.hidden = true;
        } else if (tableView == availableChallengesTable) {
            challenges = availableChallenges;
            cell = buildInvitationCell(cell, challenge: challenges[indexPath.row]);
        } else {
            challenges = invitations;
            cell = buildInvitationCell(cell, challenge: challenges[indexPath.row]);
        }
        let challenge = challenges[indexPath.row];
        cell.title.text = challenge.name;
        cell.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.imageUrl));
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    func buildChallengeCell(cell: ChallengeRowCell, challenge: HigiChallenge) -> ChallengeRowCell {
        var nibOriginX:CGFloat = 0.0;
        
        var nibs = Utility.getChallengeViews(challenge);
        for nib in nibs {
            nib.frame.origin.x = nibOriginX;
            cell.scrollView.addSubview(nib);
            nibOriginX += nib.frame.width;
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
        currentPage = page
        
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false;
    }
}