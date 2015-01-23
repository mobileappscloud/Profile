import Foundation

class ChallengesViewController: BaseViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headerImage: UIImageView!
    
    var activeTable: UITableView!;
    var upcomingTable: UITableView!;
    var availableTable: UITableView!;
    var invitedTable: UITableView!;
    
    var pageTitles:[String] = [];
    var pageDisplayMaster = [false, false, false, false];
    struct PagerConstants {
        static let activeChallengesIndex = 0;
        static let upcomingChallengesIndex = 1;
        static let availableChallengesIndex = 2;
        static let invitedChallengesIndex = 3;
    }

    var activeChallenges:[HigiChallenge]! = [];
    var upcomingChallenges:[HigiChallenge]! = [];
    var availableChallenges:[HigiChallenge]! = [];
    var invitedChallenges:[HigiChallenge]! = [];
    
    var currentPage  = 0;
    var totalPages = 0;
    
    struct ViewConstants {
        static let footerHeight:CGFloat = 10;
        static let cardHeight:CGFloat = 176;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        pager.currentPage = currentPage;

        var session = SessionController.Instance;
        
        self.navigationController?.delegate = self;
        
        for challenge:HigiChallenge in session.challenges {
            switch(challenge.userStatus) {
            case "current":
                activeChallenges.append(challenge);
                pageDisplayMaster[PagerConstants.activeChallengesIndex] = true;
            case "public":
                availableChallenges.append(challenge);
                pageDisplayMaster[PagerConstants.availableChallengesIndex] = true;
            case "upcoming":
                upcomingChallenges.append(challenge);
                pageDisplayMaster[PagerConstants.upcomingChallengesIndex] = true;
            case "invited":
                invitedChallenges.append(challenge);
                pageDisplayMaster[PagerConstants.invitedChallengesIndex] = true;
            default:
                var i = 0;
            }
        }
        
        var table:UITableView;
        for index in 0...pageDisplayMaster.count-1 {
            if (pageDisplayMaster[index]) {
                switch(index) {
                case 0:
                    activeTable = addTableView(totalPages);
                    scrollView.addSubview(activeTable);
                    pageTitles.append("Active Challenges");
                case 1:
                    upcomingTable = addTableView(totalPages);
                    scrollView.addSubview(upcomingTable);
                    pageTitles.append("Upcoming Challenges");
                case 2:
                    availableTable = addTableView(totalPages);
                    scrollView.addSubview(availableTable);
                    pageTitles.append("Available Challenges");
                case 3:
                    invitedTable = addTableView(totalPages);
                    scrollView.addSubview(invitedTable);
                    pageTitles.append("Invited Challenges");
                default:
                    var i = 0;
                }
                totalPages++;
            }
        }
        if (pageTitles.count > 0) {
            title = pageTitles[0];
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavbar();
    }
    
    func updateNavbar() {
        //@todo this only works for the first table at the moment
        var scrollY = activeTable.contentOffset.y;
        if (scrollY >= 0) {
            //headerImage.frame.origin.y = -scrollY / 2;
            var alpha = min(scrollY / 75, 1);
            self.fakeNavBar.alpha = alpha;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
            if (alpha < 0.5) {
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
                toggleButton!.alpha = 1 - alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
                pager.currentPageIndicatorTintColor = UIColor.whiteColor();
            } else {
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
                toggleButton!.alpha = alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
                pager.currentPageIndicatorTintColor = UIColor.blackColor();
            }
        } else {
            self.fakeNavBar.alpha = 0;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 1)];
        }
    }

    func addTableView(page: Int) -> UITableView {
        let viewWidth = scrollView.frame.size.width;
        let viewHeight = min(ViewConstants.cardHeight * CGFloat(activeChallenges.count) + 83, scrollView.frame.size.height);
        
        let table = UITableView(frame: CGRect(x: CGFloat(page) * viewWidth, y: 0, width: viewWidth, height: viewHeight));
        table.dataSource = self;
        table.delegate = self;
        table.separatorStyle = UITableViewCellSeparatorStyle.None;
        table.backgroundColor = UIColor.clearColor();
        table.scrollEnabled = true;
        return table;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height);
        scrollView.setContentOffset(CGPointMake(0,0),animated: false);
        
        pager.numberOfPages = totalPages;
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0;
        let activeTableViewTemp:UITableView = activeTable;
        //check display master array instead of null checks to avoid crash
        if (pageDisplayMaster[0] && tableView == activeTable && activeChallenges != nil) {
            count = activeChallenges.count;
        } else if (pageDisplayMaster[1] && tableView == upcomingTable && upcomingChallenges != nil) {
            count = upcomingChallenges.count;
        } else if (pageDisplayMaster[2] && tableView == availableTable && availableChallenges != nil) {
            count = availableChallenges.count;
        } else if (pageDisplayMaster[3] && pageDisplayMaster[3] && tableView == invitedTable && invitedChallenges != nil) {
            count = invitedChallenges.count;
        }
        return count;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 83));
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 83;
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

        if (activeTable != nil && tableView == activeTable) {
            challenges = activeChallenges;
            challengeType = "active";
        } else if (upcomingTable != nil && tableView == upcomingTable) {
            challenges = upcomingChallenges;
            challengeType = "available";
        } else if (availableTable != nil && tableView == availableTable) {
            challenges = availableChallenges;
            challengeType = "upcoming";
        } else {
            challenges = invitedChallenges;
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
        
        //use this to send to challenge details page
        cell.tag = indexPath.row;
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "gotoDetails:");
        cell.addGestureRecognizer(tapGestureRecognizer);
        let footer = UIView(frame: CGRect(x: 0, y: cell.frame.height - ViewConstants.footerHeight, width: cell.frame.width, height: ViewConstants.footerHeight));
        footer.backgroundColor = Utility.colorFromHexString("#EEEEEE");
        cell.addSubview(footer);
        return cell;
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
        
        var nibs = Utility.getChallengeViews(challenge, isComplex: false);
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
        let page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        pager.currentPage = page;
        changePage(pager);
    }
    
    func gotoDetails(sender: AnyObject) {
        
        let view = sender.view as UIView!;
        let index = view.tag;
        
        var challenges:[HigiChallenge] = [];
        var challengeType = "";
        
        let currentTableIndex = getCurrentTable();
        
        switch(currentTableIndex) {
        case PagerConstants.activeChallengesIndex:
            challenges = activeChallenges;
        case PagerConstants.availableChallengesIndex:
            challenges = upcomingChallenges;
        case PagerConstants.upcomingChallengesIndex:
            challenges = availableChallenges;
        case PagerConstants.invitedChallengesIndex:
            challenges = invitedChallenges;
        default:
            var i = 0;
        }

        var challenge = challenges[index];
        
        Flurry.logEvent("Challenge_Pressed");
        var challengeDetailViewController = ChallengeDetailsViewController(nibName: "ChallengeDetailsView", bundle: nil);
        
        challengeDetailViewController.challenge = challenge;
        self.navigationController!.pushViewController(challengeDetailViewController, animated: true);
    }
    
    func getCurrentTable() -> Int {
        var count = 0;
        for index in 0...pageDisplayMaster.count - 1 {
            let display = pageDisplayMaster[index]
            if (display) {
                count++;
            }
            if (count == currentPage) {
                return index;
            }
        }
        return 0;
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var page = pager.currentPage;
        
        let previousPage = currentPage;
        
        title = pageTitles[page];
        currentPage = page;
        
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        return false;
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        let currentTableIndex = getCurrentTable();
        //@todo logic for directing user back to appropriate page
        //in the mean time, need to reload data to avoid view being smashed on return from back button
        switch(currentTableIndex) {
        case PagerConstants.activeChallengesIndex:
            activeTable.reloadData();
//        case PagerConstants.availableChallengesIndex:
//            challenges = upcomingChallenges;
//        case PagerConstants.upcomingChallengesIndex:
//            challenges = availableChallenges;
//        case PagerConstants.invitedChallengesIndex:
//            challenges = invitedChallenges;
        default:
            var i = 0;
        }

        activeTable.reloadData();
    }
}