import Foundation

class ChallengesViewController: BaseViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headerImage: UIImageView!
    
    var activeTable: UITableView?;
    var upcomingTable: UITableView?;
    var availableTable: UITableView?;
    var invitedTable: UITableView?;
    
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
    
    let headerHeight:CGFloat = 83;
    var currentTable:UITableView?;
    
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
        
        for index in 0...pageDisplayMaster.count-1 {
            if (pageDisplayMaster[index]) {
                switch(index) {
                case 0:
                    activeTable = addTableView(totalPages);
                    scrollView.addSubview(activeTable!);
                    pageTitles.append("Active Challenges");
                    currentTable = activeTable;
                case 1:
                    upcomingTable = addTableView(totalPages);
                    scrollView.addSubview(upcomingTable!);
                    pageTitles.append("Upcoming Challenges");
                    if (currentTable == nil) {
                        currentTable = upcomingTable;
                    }
                case 2:
                    availableTable = addTableView(totalPages);
                    scrollView.addSubview(availableTable!);
                    pageTitles.append("Available Challenges");
                    if (currentTable == nil) {
                        currentTable = availableTable;
                    }
                case 3:
                    invitedTable = addTableView(totalPages);
                    scrollView.addSubview(invitedTable!);
                    pageTitles.append("Invited Challenges");
                    if (currentTable == nil) {
                        currentTable = invitedTable;
                    }
                default:
                    var i = 0;
                }
                totalPages++;
            }
        }
        if (pageTitles.count > 0) {
            title = pageTitles[0];
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height);
        scrollView.setContentOffset(CGPointMake(0,0),animated: false);
        pager.numberOfPages = totalPages;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavbar();
    }
    
    func updateNavbar() {
        let table = getCurrentTable();
        if (table != nil) {
            var scrollY = table!.contentOffset.y;
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
    }

    func addTableView(page: Int) -> UITableView {
        let table = UITableView(frame: CGRect(x: CGFloat(page) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height));
        table.dataSource = self;
        table.delegate = self;
        table.separatorStyle = UITableViewCellSeparatorStyle.None;
        table.backgroundColor = UIColor.clearColor();
        table.scrollEnabled = true;
        table.showsVerticalScrollIndicator = false;
        table.rowHeight = 226;
        return table;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height);
        scrollView.setContentOffset(CGPointMake(0,0),animated: false);
        if (pageDisplayMaster[PagerConstants.activeChallengesIndex] && activeTable != nil) {
            activeTable!.frame.size.height = scrollView.frame.size.height;
        }
        if (pageDisplayMaster[PagerConstants.upcomingChallengesIndex] && upcomingTable != nil) {
            upcomingTable!.frame.size.height = scrollView.frame.size.height;
        }
        if (pageDisplayMaster[PagerConstants.availableChallengesIndex] && availableTable != nil) {
            availableTable!.frame.size.height = scrollView.frame.size.height;
        }
        if (pageDisplayMaster[PagerConstants.invitedChallengesIndex] && invitedTable != nil) {
            invitedTable!.frame.size.height = scrollView.frame.size.height;
        }
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0;
        //check display master array instead of null checks to avoid crash
        if (pageDisplayMaster[0] && tableView == activeTable && activeChallenges != nil) {
            count = activeChallenges.count;
        } else if (pageDisplayMaster[1] && tableView == upcomingTable && upcomingChallenges != nil) {
            count = upcomingChallenges.count;
        } else if (pageDisplayMaster[2] && tableView == availableTable && availableChallenges != nil) {
            count = availableChallenges.count;
        } else if (pageDisplayMaster[3] && tableView == invitedTable && invitedChallenges != nil) {
            count = invitedChallenges.count;
        }
        return count;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight));
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight;
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
        var challenge: HigiChallenge!;
        if (activeTable != nil && tableView == activeTable) {
            challenge = activeChallenges[indexPath.row];
        } else if (upcomingTable != nil && tableView == upcomingTable) {
            challenge = upcomingChallenges[indexPath.row];
        } else if (availableTable != nil && tableView == availableTable) {
            challenge = availableChallenges[indexPath.row];
        } else {
            challenge = invitedChallenges[indexPath.row];
        }
        cell = buildChallengeCell(cell, challenge: challenge);
        
        if (challenge != nil) {
            cell.title.text = challenge.name;
            cell.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.imageUrl));
        }
        
        var daysLeft:Int = 0;
        var endDate:NSDate? = challenge.endDate?;
        if (endDate != nil) {
            var compare:NSTimeInterval = endDate!.timeIntervalSinceNow
            if (Int(compare) > 0) {
                cell.daysLeft.text = "\(Int(compare) / 60 / 60 / 24)d left";
            }
        }
        
        //use tag to send to indentify which challenge selected when going to challenge details page
        cell.tag = indexPath.row;
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "gotoDetails:");
        cell.addGestureRecognizer(tapGestureRecognizer);
        let footer = UIView(frame: CGRect(x: 0, y: cell.frame.height - 10, width: cell.frame.width, height: 10));
        footer.backgroundColor = Utility.colorFromHexString("#EEEEEE");
        
        cell.addSubview(footer);
        return cell;
    }
    
    func buildEmptyCell(cell: ChallengeRowCell) {
        
    }
    
    func buildChallengeCell(cell: ChallengeRowCell, challenge: HigiChallenge) -> ChallengeRowCell {
        if (challenge.userStatus == "current") {
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
            nibOriginX += cell.scrollView.frame.size.width;
        }
        cell.pager.numberOfPages = nibs.count;
        cell.pager.currentPage = 0;
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * CGFloat(nibs.count), height: cell.frame.size.height);

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
        if (scrollView == self.scrollView) {
            let page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
            pager.currentPage = page;
            changePage(pager);
        }
    }
    
    func gotoDetails(sender: AnyObject) {
        
        let index = (sender.view as UIView!).tag;
        
        var challenges:[HigiChallenge] = [];
        
        var challenge: HigiChallenge!;
        
        let table = getCurrentTable()!;
        
        if (activeTable != nil && table == activeTable) {
            challenge = activeChallenges[index];
        } else if (availableTable != nil && table == availableTable) {
            challenge = availableChallenges[index];
        } else if (upcomingTable != nil && table == upcomingTable) {
            challenge = upcomingChallenges[index];
        } else if (invitedTable != nil && table == invitedTable) {
            challenge = invitedChallenges[index];
        }

        Flurry.logEvent("Challenge_Pressed");
        var challengeDetailViewController = ChallengeDetailsViewController(nibName: "ChallengeDetailsView", bundle: nil);
        
        challengeDetailViewController.challenge = challenge;
        self.navigationController!.pushViewController(challengeDetailViewController, animated: true);
    }
    
    func getCurrentTable() -> UITableView? {
        var count = -1;
        for index in 0...pageDisplayMaster.count - 1 {
            
            if (pageDisplayMaster[index]) {
                count++;
            }
            
            if (count == currentPage) {
                count = index;
                break;
            }
        }
        
        var table:UITableView?;
        switch(count) {
        case PagerConstants.activeChallengesIndex:
            table = activeTable!;
        case PagerConstants.availableChallengesIndex:
            table = availableTable!;
        case PagerConstants.upcomingChallengesIndex:
            table = upcomingTable!;
        case PagerConstants.invitedChallengesIndex:
            table = invitedTable!;
        default:
            let i = 0;
        }
        
        return table;
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var page = pager.currentPage;
        
        let previousPage = currentPage;
        
        title = pageTitles[page];
        currentPage = page;
        currentTable = getCurrentTable();
        
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
        updateNavbar();
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        return false;
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        let currentTable = getCurrentTable();
        if (currentTable != nil) {
            currentTable!.reloadData();
        } else {
            //@todo i believe this case would mean that there was one unjoined challenge as the only challenge
            //in a particular page, then the user clicked on it and joined it, then came back.  thus the page they 
            //were on does not exist
        }
    }
}