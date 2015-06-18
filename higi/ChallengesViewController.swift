import Foundation
class ChallengesViewController: BaseViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headerImage: UIImageView!
    @IBOutlet weak var blankState: UIImageView!
    
    var activeTable, upcomingTable: UITableView?, availableTable: UITableView?, invitedTable: UITableView?;
    
    var pageTitles:[String] = [];
    
    var pageDisplayMaster = [false, false, false, false];
    
    var activeChallenges, upcomingChallenges, availableChallenges, invitedChallenges:[HigiChallenge]!;
    
    var currentPage = 0, totalPages = 0;
    
    let headerHeight: CGFloat = 83;
    
    var currentTable: UITableView!;
    
    var clickedChallenge: HigiChallenge?;
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        pager = UIPageControl(frame: CGRect(x: UIScreen.mainScreen().bounds.width / 2 - 50 / 2 , y: self.navigationController!.navigationBar.frame.size.height - 10, width: 50, height: 10));
        pager.currentPage = currentPage;
        initChallengeCards();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        pager.removeFromSuperview();
    }
    
    func initChallengeCards() {
        pageTitles = [];
        pageDisplayMaster = [false, false, false, false];
        activeTable?.removeFromSuperview();
        upcomingTable?.removeFromSuperview();
        availableTable?.removeFromSuperview();
        invitedTable?.removeFromSuperview();
        activeChallenges = [];
        upcomingChallenges = [];
        availableChallenges = [];
        invitedChallenges = [];
        totalPages = 0;
        
        var challenges = SessionController.Instance.challenges;
        let challengeName = clickedChallenge != nil ? clickedChallenge!.name : "";
        var challengeIndex = -1;
        
        if (challenges != nil && challenges.count > 0) {
            for challenge:HigiChallenge in challenges {
                switch(challenge.userStatus) {
                case "current":
                    activeChallenges.append(challenge);
                    pageDisplayMaster[0] = true;
                    challengeIndex = challengeName == challenge.name ? 0 : challengeIndex;
                case "upcoming":
                    upcomingChallenges.append(challenge);
                    pageDisplayMaster[1] = true;
                    challengeIndex = challengeName == challenge.name ? 1 : challengeIndex;
                case "public":
                    availableChallenges.append(challenge);
                    pageDisplayMaster[2] = true;
                    challengeIndex = challengeName == challenge.name ? 2 : challengeIndex;
                case "invited":
                    if (challenge.entryFee == 0) {
                        invitedChallenges.append(challenge);
                        pageDisplayMaster[3] = true;
                        challengeIndex = challengeName == challenge.name ? 3 : challengeIndex;
                    }
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
            if (clickedChallenge != nil) {
                pager.currentPage = actualTableIndex(challengeIndex);
                changePage(pager);
                clickedChallenge = nil;
            }
            if (pageTitles.count > 0) {
                title = pageTitles[currentPage];
            }
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height);
            
        } else {
            title = "Challenges";
            blankState.hidden = false;
        }
        pager.numberOfPages = totalPages;
        self.navigationController?.navigationBar.addSubview(pager);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView != self.scrollView) {
            updateNavbar();
        }
    }
    
    func updateNavbar() {
        if (currentTable != nil) {
            var scrollY = currentTable.contentOffset.y;
            if (scrollY >= 0) {
                var alpha = min(scrollY / 75, 1);
                self.fakeNavBar.alpha = alpha;
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
                pager.pageIndicatorTintColor = UIColor(white: 1 - alpha, alpha: 0.2);
                pager.currentPageIndicatorTintColor = UIColor(white: 1 - alpha, alpha: 1);
                if (alpha < 0.5) {
                    toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
                    toggleButton!.alpha = 1 - alpha;
                    pointsMeter.setLightText();
                    self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
                } else {
                    toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
                    toggleButton!.alpha = alpha;
                    pointsMeter.setDarkText();
                    self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
                }
            } else {
                self.fakeNavBar.alpha = 0;
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 1)];
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
                toggleButton!.alpha = 1;
                pager.pageIndicatorTintColor = UIColor(white: 1.0, alpha: 0.2);
                pager.currentPageIndicatorTintColor = UIColor.whiteColor();
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
        scrollView.frame = self.view.frame;
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height);
        if (pageDisplayMaster[0] && activeTable != nil) {
            activeTable!.frame.size.height = scrollView.frame.size.height;
        }
        if (pageDisplayMaster[1] && upcomingTable != nil) {
            upcomingTable!.frame.size.height = scrollView.frame.size.height;
        }
        if (pageDisplayMaster[2] && availableTable != nil) {
            availableTable!.frame.size.height = scrollView.frame.size.height;
        }
        if (pageDisplayMaster[3] && invitedTable != nil) {
            invitedTable!.frame.size.height = scrollView.frame.size.height;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInCurrentTableView(tableView);
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight));
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChallengeRowCell") as! ChallengeRowCell!;
        if (cell == nil) {
            cell = UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChallengeRowCell
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
        buildChallengeCell(cell, challenge: challenge);
        if (challenge != nil) {
            cell.title.text = challenge.name as String;
            cell.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.imageUrl as String));
        }
        var endDate:NSDate? = challenge.endDate;
        if (endDate != nil) {
            let days = Int(endDate!.timeIntervalSinceNow / 60 / 60 / 24) + 1;
            var formatter = NSDateFormatter();
            formatter.dateFormat = "yyyyMMdd";
            if (formatter.stringFromDate(NSDate()) == formatter.stringFromDate(endDate!)) {
                cell.daysLeft.text = "Ends today!";
            } else if (days > 0) {
                let s = days == 1 ? "" : "s";
                cell.daysLeft.text = "\(days)d left";
            } else {
                cell.daysLeft.text = "Finished!";
            }
        }
        //use tag to send to indentify which challenge selected when going to challenge details page
        cell.tag = indexPath.row;
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "gotoDetails:");
        cell.addGestureRecognizer(tapGestureRecognizer);
        if (indexPath.row != numberOfRowsInCurrentTableView(tableView) - 1) {
            let footer = UIView(frame: CGRect(x: 0, y: cell.frame.height - 10, width: cell.frame.width, height: 10));
            footer.backgroundColor = Utility.colorFromHexString("#EEEEEE");
            cell.addSubview(footer);
        }
        return cell;
    }
    
    func numberOfRowsInCurrentTableView(tableView: UITableView) -> Int {
        var count = 0;
        //check display master array instead of null checks to avoid crash
        if (pageDisplayMaster[0] && tableView == activeTable) {
            count = activeChallenges.count;
        } else if (pageDisplayMaster[1] && tableView == upcomingTable) {
            count = upcomingChallenges.count;
        } else if (pageDisplayMaster[2] && tableView == availableTable) {
            count = availableChallenges.count;
        } else if (pageDisplayMaster[3] && tableView == invitedTable) {
            count = invitedChallenges.count;
        }
        return count;
    }
    
    func buildChallengeCell(cell: ChallengeRowCell, challenge: HigiChallenge) {
        if (challenge.userStatus == "current") {
            buildActiveCell(cell, challenge: challenge);
        } else {
            buildInvitationCell(cell, challenge: challenge);
        }
    }
    
    func buildActiveCell(cell: ChallengeRowCell, challenge: HigiChallenge) {
        var nibOriginX:CGFloat = 0.0;
        var nibs = ChallengeUtility.getChallengeViews(challenge, frame: scrollView.frame, isComplex: false);
        for nib in nibs {
            nib.frame.origin.x = nibOriginX;
            cell.scrollView.addSubview(nib);
            nibOriginX += cell.scrollView.frame.size.width;
        }
        cell.pager.numberOfPages = nibs.count;
        cell.pager.currentPage = 0;
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * CGFloat(nibs.count), height: cell.frame.size.height);
    }
    
    func buildInvitationCell(cell: ChallengeRowCell, challenge: HigiChallenge) {
        var invitationView = ChallengeInvitationView.instanceFromNib(challenge);
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width, height: cell.frame.size.height);
        cell.scrollView.addSubview(invitationView);
        cell.daysLeft.hidden = true;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if (scrollView == self.scrollView) {
            let page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
            pager.currentPage = page;
            changePage(pager);
        }
    }
    
    func gotoDetails(sender: AnyObject) {
        Flurry.logEvent("ChallengeCard_Pressed");
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
        clickedChallenge = challenge;
        var challengeDetailViewController = ChallengeDetailsViewController(nibName: "ChallengeDetailsView", bundle: nil);
        challengeDetailViewController.challenge = challenge;
        self.navigationController!.pushViewController(challengeDetailViewController, animated: true);
    }
    
    func getCurrentTable() -> UITableView? {
        let index = actualTableIndex(currentPage);
        var table:UITableView?;
        switch(index) {
        case 0:
            table = activeTable!;
        case 1:
            table = upcomingTable!;
        case 2:
            table = availableTable!;
        case 3:
            table = invitedTable!;
        default:
            let i = 0;
        }
        return table!;
    }
    
    func actualTableIndex(page: Int) -> Int {
        var count = -1;
        for index in 0...pageDisplayMaster.count - 1 {
            if (pageDisplayMaster[index]) {
                count++;
            }
            if (count == page) {
                count = index;
                break;
            }
        }
        return count;
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as! UIPageControl;
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
}