import Foundation

class ChallengesViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var blankState: UIImageView!
    
    var activeTable, upcomingTable: UITableView?, availableTable: UITableView?, invitedTable: UITableView?;
    
    var pageTitles:[String] = [];
    
    var pageDisplayMaster = [false, false, false, false];
    
    var activeChallenges, upcomingChallenges, availableChallenges, invitedChallenges:[HigiChallenge]!;
    
    var currentPage = 0, totalPages = 0;
    
    var screenWidth: CGFloat!;
    
    var currentTable: UITableView!;
    
    var clickedChallenge: HigiChallenge?;
    
    var universalLinkObserver: NSObjectProtocol? = nil
    
    var pageTitle: String? {
        didSet {
            self.navigationItem.title = pageTitle
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //fix for changing orientation bug when coming back from landscape screen
        screenWidth = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        scrollView.frame.size.width = screenWidth;
        pager = UIPageControl(frame: CGRect(x: screenWidth / 2 - 50 / 2 , y: self.navigationController!.navigationBar.frame.size.height - 10, width: 50, height: 10));

        // Ensure content offset is set to a 'page'
        scrollView.contentOffset.x = scrollView.bounds.width * CGFloat(currentPage)        

        // Temporary fix -- everything needs to be refactored.
        pager.currentPage = currentPage;
        initChallengeCards();

        pager.currentPage = currentPage;
        pager.updateCurrentPageDisplay()
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
        
        let challenges = SessionController.Instance.challenges;
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
                        pageTitles.append(NSLocalizedString("CHALLENGES_VIEW_PAGE_TITLE_ACTIVE_CHALLENGES", comment: "Title for active challenge page in challenges view."));
                        currentTable = activeTable;
                    case 1:
                        upcomingTable = addTableView(totalPages);
                        scrollView.addSubview(upcomingTable!);
                        pageTitles.append(NSLocalizedString("CHALLENGES_VIEW_PAGE_TITLE_UPCOMING_CHALLENGES", comment: "Title for upcoming challenge page in challenges view."));
                        if (currentTable == nil) {
                            currentTable = upcomingTable;
                        }
                    case 2:
                        availableTable = addTableView(totalPages);
                        scrollView.addSubview(availableTable!);
                        pageTitles.append(NSLocalizedString("CHALLENGES_VIEW_PAGE_TITLE_AVAILABLE_CHALLENGES", comment: "Title for available challenge page in challenges view."));
                        if (currentTable == nil) {
                            currentTable = availableTable;
                        }
                    case 3:
                        invitedTable = addTableView(totalPages);
                        scrollView.addSubview(invitedTable!);
                        pageTitles.append(NSLocalizedString("CHALLENGES_VIEW_PAGE_TITLE_INVITED_CHALLENGES", comment: "Title for invited challenge page in challenges view."));
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
                pageTitle = pageTitles[currentPage];
            }
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height);
            
        } else {
            pageTitle = NSLocalizedString("CHALLENGES_VIEW_PAGE_TITLE_CHALLENGES", comment: "Title for challenge page in challenges view with only one challenge.");
            blankState.hidden = false;
        }
        pager.numberOfPages = totalPages;
        self.navigationController?.navigationBar.addSubview(pager);
        if totalPages <= 1 {
            pager.hidden = true;
        }
    }
    
    func addTableView(page: Int) -> UITableView {
        let table = UITableView(frame: CGRect(x: CGFloat(page) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height));
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49.0, right: 0)
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChallengeRowCell") as! ChallengeRowCell!;
        if (cell == nil) {
            cell = UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChallengeRowCell
        }
        cell.frame.size.width = scrollView.frame.size.width;
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
        let endDate:NSDate? = challenge.endDate;
        if (endDate != nil) {
            let remainingDays = NSCalendar.currentCalendar().components(.Day, fromDate: NSDate(), toDate: endDate!, options: NSCalendarOptions(rawValue: 0)).day
            
            if (NSCalendar.currentCalendar().isDateInToday(endDate!)) {
                cell.daysLeft.text = NSLocalizedString("CHALLENGE_DETAILS_VIEW_CHALLENGE_DATE_ENDS_TODAY", comment: "Message for a challenge which ends today.")
                
            } else if (remainingDays >= 0) {
                let formattedDate = NSString.localizedStringWithFormat(NSLocalizedString("DAY_COUNT_SINGLE_PLURAL", comment: "Format for pluralization of days."), remainingDays+1)
                let format = NSLocalizedString("CHALLENGE_DETAILS_VIEW_CHALLENGE_DATE_STARTED_FORMAT", comment: "Format for a challenge which has started and has a given number of days remaining.")
                cell.daysLeft.text = NSString.localizedStringWithFormat(format, formattedDate) as String
                
            } else if (remainingDays < 0) {
                cell.daysLeft.text = NSLocalizedString("CHALLENGE_DETAILS_VIEW_CHALLENGE_DATE_FINISHED", comment: "Message for a challenge which has already ended.")
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
        let nibs = ChallengeUtility.getChallengeViews(challenge, frame: cell.frame, isComplex: false);
        for nib in nibs {
            nib.frame.origin.x = nibOriginX;
            cell.scrollView.addSubview(nib);
            nibOriginX += cell.frame.size.width;
        }
        cell.pager.numberOfPages = nibs.count;
        cell.pager.currentPage = 0;
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * CGFloat(nibs.count), height: cell.frame.size.height);
    }
    
    func buildInvitationCell(cell: ChallengeRowCell, challenge: HigiChallenge) {
        let invitationView = ChallengeInvitationView.instanceFromNib(challenge);
        invitationView.frame.size.width = cell.frame.size.width;
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
        self.showDetails(forChallenge: challenge)
    }
    
    func showDetails(forChallenge challenge: HigiChallenge) {
        let challengeDetailViewController = ChallengeDetailsViewController(nibName: "ChallengeDetailsView", bundle: nil)
        challengeDetailViewController.challenge = challenge
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.navigationController?.pushViewController(challengeDetailViewController, animated: true)
        })
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
        let pager = sender as! UIPageControl;
        let page = pager.currentPage;
        let previousPage = currentPage;
        pageTitle = pageTitles[page]
        currentPage = page;
        currentTable = getCurrentTable();
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        return false;
    }
}

extension ChallengesViewController: UniversalLinkHandler {
    
    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?) {
        
        let appDelegate = AppDelegate.instance()
        if appDelegate.didRecentlyLaunchToContinueUserActivity() {
            let loadingViewController = self.presentLoadingViewController()
            
            self.universalLinkObserver = NSNotificationCenter.defaultCenter().addObserverForName(ApiUtility.CHALLENGES, object: nil, queue: nil, usingBlock: { (notification) in
                self.handle(URL, pathType: pathType, parameters: parameters, presentedViewController: loadingViewController)
                if let observer = self.universalLinkObserver {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
            })
        } else {
            self.handle(URL, pathType: pathType, parameters: parameters, presentedViewController: nil)
        }
    }
    
    private func handle(URL: NSURL, pathType: PathType, parameters: [String]?, presentedViewController: UIViewController?) {
        
        // Make sure there are no views presented over the tab bar controller
        presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        
        if pathType == .ChallengeDashboard {
            self.navigateToChallengesDashboard()
        } else if pathType == .ChallengeDetail || pathType == .ChallengeDetailSubPath {
            guard let params = parameters else {
                return
            }
            
            if let challenge = self.challenge(forChallengeParameters: params) {
                self.navigateToChallengeDetail(challenge)
            } else {
                ApiUtility.retrieveChallenges({
                    if let challenge = self.challenge(forChallengeParameters: params) {
                        self.navigateToChallengeDetail(challenge)
                    }
                })
            }
        }
    }
    
    private func challenge(forChallengeParameters parameters: [String]) -> HigiChallenge? {
        guard let challenges = SessionController.Instance.challenges else {
            return nil
        }
        
        var challenge: HigiChallenge? = nil;
        for currentChallenge in challenges {
            guard let currentChallengeURL = NSURL(string: currentChallenge.url as String) else {
                continue
            }
            
            if let challengeId = currentChallengeURL.pathComponents?.last, let parameterId = parameters.first where challengeId == parameterId {
                challenge = currentChallenge;
                break;
            }
        }
        return challenge;
    }
    
    private func challengesNavigationController() -> UINavigationController {
        let tabBar = Utility.mainTabBarController()!
        return tabBar.challengesNavController
    }
    
    func navigateToChallengesDashboard() {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            InterfaceOrientation.force(.Portrait)
            
            Utility.mainTabBarController()?.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            Utility.mainTabBarController()?.selectedIndex = TabBarController.ViewControllerIndex.Challenges.rawValue
            self?.challengesNavigationController().popToRootViewControllerAnimated(false)
        })
    }
    
    func navigateToChallengeDetail(challenge: HigiChallenge) {
        navigateToChallengesDashboard()

        guard let challengesViewController = Utility.mainTabBarController()?.challengesViewController else { return }
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            challengesViewController.showDetails(forChallenge: challenge)
        })
    }
}
