import Foundation

class ChallengeDetailsViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet var pointsLabel:UILabel?;
    
    @IBOutlet weak var participantName: UILabel!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var participantPoints: UILabel!
    @IBOutlet weak var participantProgress: UIView!
    @IBOutlet weak var challengeTitle: UILabel!
    @IBOutlet weak var challengeAvatar: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var participantContainer: UIView!
    @IBOutlet weak var challengeDaysLeft: UILabel!
    @IBOutlet weak var participantAvatar: UIImageView!
    @IBOutlet weak var participantPlace: UILabel!
    
    @IBOutlet weak var buttonContainer: UIView!
    
    var challengeName = "";
    var challenge:HigiChallenge!;
    
    var displayLeaderboardTab = false;
    var displayProgressTab = false;
    var displayChatterTab = false;
    
    var hasTeamGoalComponent = false;
    var hasIndividualGoalComponent = false;
    var hasTeamLeaderboardComponent = false;
    var hasIndividualLeaderboardComponent = false;
    
    var isIndividualLeaderboard = true;
    var isIndividualProgress = true;
    
    var leaderboardTable: UITableView!;
    var progressTable: UITableView!;
    var detailsTable: UITableView!;
    var chatterTable: UITableView!;

    var totalPages = 0;
    var currentPage = 0;
    var tables:[UITableView] = [];
    
    var headerContainerHeight:CGFloat = 0;
    var buttonContainerOriginY:CGFloat = 0;
    var headerAvatarOriginX:CGFloat = 0;
    var headerPlaceOriginX:CGFloat = 0;
    var headerProgressOriginX:CGFloat = 0;
    var headerProgressOriginWidth:CGFloat = 0;
    var headerPointsOriginX:CGFloat = 0;
    
    var scrollOffset = 0;
    
    var shouldScroll = true;
    var leaderboardToggleButtons:[UIButton] = [];
    var progressToggleButtons:[UIButton] = [];
    var greenBars:[UIView] = [];
    let progressGestureRecognizer = UITapGestureRecognizer();
    let leaderboardGestureRecognizer = UITapGestureRecognizer();
    
    var individualLeaderboardCount = 50;
    var teamLeaderboardCount = 50;
    var individualLeaderboardParticipants:[ChallengeParticipant] = [];
    var teamLeaderboardParticipants:[ChallengeTeam] = [];

    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor();
        (self.navigationController as MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        
        var session = SessionController.Instance;
        
        for winCondition in challenge.winConditions {
            if (challenge.participant != nil && winCondition.goal.type == "threshold_reached") {
                displayProgressTab = true;
                if (winCondition.winnerType == "individual") {
                    hasIndividualGoalComponent = true;
                } else if (winCondition.winnerType == "team") {
                    hasTeamGoalComponent = true;
                }
            } else if (winCondition.goal.type == "most_points" || winCondition.goal.type == "unit_goal_reached") {
                displayLeaderboardTab = true;
                if (winCondition.winnerType == "individual") {
                    hasIndividualLeaderboardComponent = true;
                } else if (winCondition.winnerType == "team") {
                    hasTeamLeaderboardComponent = true;
                }
            }
        }
        
        if (challenge.participant != nil) {
            displayChatterTab = true;
        }
        
        populateHeader();
        
        populateScrollViewWithTables();
        
        populateTabButtons();
        
        if (displayLeaderboardTab && hasIndividualLeaderboardComponent && hasTeamLeaderboardComponent) {
            addToggleButtons(leaderboardTable);
        }
        if (displayProgressTab && hasIndividualGoalComponent && hasTeamGoalComponent) {
            addToggleButtons(progressTable);
        }
        if (hasIndividualLeaderboardComponent) {
            individualLeaderboardParticipants = challenge.participants;
        }
        if (hasTeamLeaderboardComponent) {
            teamLeaderboardParticipants = challenge.teams;
        }
    }
    
    func addToggleButtons(table: UITableView) {
        let toggleButtonHeight:CGFloat = 60;
        let buttonMargin:CGFloat = 10;
        let header = UIControl(frame: CGRect(x: 0, y: buttonContainerOriginY + buttonContainer.frame.size.height + buttonMargin, width: contentView.frame.size.width, height: toggleButtonHeight  - buttonMargin));
        
        header.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        
        let toggleButtonsText = ["Individuals", "Teams"];
        for index in 0...1 {
            //no x padding for first button
            let buttonX = (CGFloat(1 - index) * buttonMargin) + (CGFloat(index) * (contentView.frame.size.width / 2));
            let buttonY = buttonContainerOriginY + buttonContainer.frame.size.height + buttonMargin;
            //subtract margin from width of second button
            let buttonWidth = contentView.frame.size.width / 2 - (CGFloat(index) * buttonMargin);
            let buttonHeight = toggleButtonHeight - buttonMargin * 2;
            var button = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight));
            button.setBackgroundImage(makeImageWithColor(UIColor.whiteColor()), forState: UIControlState.Selected);
            button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Selected);
            button.setBackgroundImage(makeImageWithColor(Utility.colorFromHexString("#E3E3E3")), forState: UIControlState.Normal);
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
            button.backgroundColor = UIColor.lightGrayColor();
            button.setTitle(toggleButtonsText[index], forState: UIControlState.Normal);
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(12);
            button.tintColor = UIColor.whiteColor();
            button.selected = index == 0;
            button.enabled = true;
            if (table == leaderboardTable) {
                leaderboardToggleButtons.append(button);
            } else {
                progressToggleButtons.append(button);
            }
            header.addSubview(button);
        }
        table.tableHeaderView = header;
    }
    
    func populateHeader() {
        if (challenge.participant != nil) {
            let participant = challenge.participant!;
            participantAvatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            participantPoints.text = "\(Int(participant.units)) pts";
            participantPlace.text = getUserRank();
            setProgressBar(participantProgress, points: Int(participant.units), highScore: Int(challenge.individualHighScore));
        } else {
            participantAvatar.hidden = true;
            participantPoints.hidden = true;
            participantPlace.hidden = true;
            participantProgress.hidden = true;
        }

        challengeAvatar.setImageWithURL(Utility.loadImageFromUrl(challenge.imageUrl));
        challengeTitle.text = challenge.name;
        
        headerContainerHeight = headerContainer.frame.size.height;
        buttonContainerOriginY = buttonContainer.frame.origin.y;
        
        headerAvatarOriginX = participantAvatar.frame.origin.x;
        headerPlaceOriginX = participantPlace.frame.origin.x;
        headerProgressOriginX = participantProgress.frame.origin.x;
        headerProgressOriginWidth = participantProgress.frame.size.width;
        headerPointsOriginX = participantPoints.frame.origin.x;
    }
    
    func populateTabButtons() {
        var buttons:[UILabel] = [];
    
        let containerYValue = buttonContainer.frame.origin.y;
        
        var buttonText:[String] = [];
        var buttonIcons:[String] = [];
        if (displayLeaderboardTab) {
            buttonText.append("Leaderboard");
            buttonIcons.append("ui_leaderboards.png");
        }
        if (displayProgressTab) {
            buttonText.append("Progress");
            buttonIcons.append("ui_progress.png");
        }
        buttonText.append("Details");
        buttonIcons.append("ui_details.png");
        if (displayChatterTab) {
            buttonText.append("Chatter");
            buttonIcons.append("ui_chatter.png");
        }
        
        let height:CGFloat = buttonContainer.frame.size.height;
        let buttonWidth = buttonContainer.frame.size.width / CGFloat(buttonText.count)
        
        for index in 0...buttonText.count - 1 {
            let tabGestureRecognizer = UITapGestureRecognizer();
            tabGestureRecognizer.addTarget(self, action: "selectButton:");
            let tabView = UIView(frame: CGRect(x: buttonWidth * CGFloat(index), y: 00, width: buttonWidth, height: height));
            tabView.backgroundColor = Utility.colorFromHexString("#FDFDFD");
            tabView.tag = index;
            let image = UIImageView(frame: CGRect(x: buttonWidth/2 - 30/2, y: 10, width: 30, height: 20));
            image.image = UIImage(named: buttonIcons[index]);
            let label = UILabel(frame: CGRect(x: 0, y: image.frame.origin.y + image.frame.size.height + 2, width: buttonWidth, height: 25));
            label.font = UIFont.systemFontOfSize(10);
            label.tintColor = UIColor.darkGrayColor();
            label.textAlignment = NSTextAlignment.Center;
            label.text = buttonText[index];
            let greenBar = UIView(frame: CGRect(x: 0, y: height - 3, width: buttonWidth, height: 3));
            greenBar.backgroundColor = Utility.colorFromHexString("#76C043");
            greenBar.hidden = index != 0;
            greenBars.append(greenBar);
            tabView.addSubview(greenBar);
            tabView.addSubview(image);
            tabView.addSubview(label);
            tabView.addGestureRecognizer(tabGestureRecognizer);
            buttonContainer.addSubview(tabView);
        }
    }
    
    func selectButton(sender: AnyObject) {
        let view = sender.view as UIView!;
        changePage(view.tag);
    }
    
    func moveGreenBar(page: Int) {
        for bar in greenBars {
            bar.hidden = true;
        }
        greenBars[page].hidden = false;
    }
    
    func toggleLeaderboardButtons(sender: AnyObject) {
        for button in leaderboardToggleButtons {
            button.selected = !button.selected;
        }
        isIndividualLeaderboard = leaderboardToggleButtons[0].selected;
        leaderboardTable.reloadData();
    }
    
    func toggleProgressButtons(sender: AnyObject) {
        for button in progressToggleButtons {
            button.selected = !button.selected;
        }
        isIndividualProgress = progressToggleButtons[0].selected;
        progressTable.reloadData();
    }
    
    func populateScrollViewWithTables() {
        var table:UITableView;
        if (displayLeaderboardTab) {
            leaderboardTable = addTableView(totalPages);
            scrollView.addSubview(leaderboardTable);
            tables.append(leaderboardTable);
            totalPages++;
        }
        if (displayProgressTab) {
            progressTable = addTableView(totalPages);
            scrollView.addSubview(progressTable);
            tables.append(progressTable);
            totalPages++;
        }
        
        detailsTable = addTableView(totalPages);
        scrollView.addSubview(detailsTable);
        tables.append(detailsTable);
        totalPages++;
        
        chatterTable = addTableView(totalPages);
        scrollView.addSubview(chatterTable);
        tables.append(chatterTable);
        totalPages++;
        
        scrollView.delegate = self;
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height);
        self.automaticallyAdjustsScrollViewInsets = false;

    }
    
    func addTableView(page: Int) -> UITableView {
        let viewWidth = scrollView.frame.size.width;
        let viewHeight:CGFloat = scrollView.frame.size.height;
        
        let table = UITableView(frame: CGRect(x: CGFloat(page) * viewWidth, y: 0, width: viewWidth, height: viewHeight));
        table.dataSource = self;
        table.delegate = self;
        table.separatorStyle = UITableViewCellSeparatorStyle.None;
        table.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        table.scrollEnabled = true;
        table.allowsSelection = false;
        
        return table;
    }
    
    func getUserRank() -> String {
        let gravityBoard = challenge.gravityBoard;
        for index in 0...challenge.gravityBoard.count - 1 {
            if (gravityBoard[index].participant.displayName == challenge.participant.displayName) {
                return Utility.getRankSuffix("\(index + 1)");
            }
        }
        return "";
    }
    
    func makeImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (shouldScroll) {
            updateScroll();
        }
    }
    
    var lastScrollY:CGFloat = 0;
    func updateScroll() {
        let headerXOffset:CGFloat = 50;
        let minHeaderHeightThreshold:CGFloat = 67;
        let currentTable = tables[currentPage];
        let scrollY = currentTable.contentOffset.y;
        
        //@todo for some reason there is a hiccup in scrolling at a couple places, same scrollY values each time
        
        lastScrollY = headerContainer.frame.origin.y;
        if (scrollY >= 0) {
            if (scrollY >= headerContainerHeight - minHeaderHeightThreshold) {
                headerContainer.frame.origin.y = minHeaderHeightThreshold - headerContainerHeight;
                buttonContainer.frame.origin.y = minHeaderHeightThreshold - 1;
            } else {
                participantPlace.frame.origin.x = headerPlaceOriginX + (scrollY / headerXOffset);
                participantProgress.frame.origin.x = headerProgressOriginX + (scrollY / headerXOffset);
 
                var xOffset = min(scrollY * (headerXOffset / ((headerContainerHeight - minHeaderHeightThreshold) / 2)),50);
                participantAvatar.frame = CGRect(x: headerAvatarOriginX + xOffset, y: participantAvatar.frame.origin.y, width: 30, height: 30);
                participantPlace.frame = CGRect(x: headerPlaceOriginX + xOffset, y: participantPlace.frame.origin.y, width: 58, height: 25);
                participantName.frame = CGRect(x: headerPlaceOriginX + xOffset, y: participantName.frame.origin.y, width: 162, height: 16);
                participantProgress.frame = CGRect(x: headerProgressOriginX + xOffset, y: participantPoints.frame.origin.y, width: headerProgressOriginWidth - xOffset, height: 15);

                headerContainer.frame.origin.y = -scrollY;
                //buttonContainer.frame.origin.y = buttonContainerOriginY - scrollY;
                buttonContainer.frame.origin.y = buttonContainerOriginY - scrollY;
            }
        }
        
        for index in 0...tables.count - 1 {
            if (index != currentPage) {
                tables[index].contentOffset.y = min(scrollY, headerContainer.frame.size.height);
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var x = scrollView.contentOffset.x;
        var w = scrollView.frame.size.width;
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        changePage(page);
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
        if (displayLeaderboardTab && hasIndividualLeaderboardComponent && hasTeamLeaderboardComponent && tableView == leaderboardTable) {
            leaderboardGestureRecognizer.addTarget(self, action: "toggleLeaderboardButtons:");
            view.addGestureRecognizer(leaderboardGestureRecognizer);
        } else if (displayProgressTab && hasIndividualGoalComponent && hasTeamGoalComponent && tableView == progressTable) {
            progressGestureRecognizer.addTarget(self, action: "toggleProgressButtons:");
            view.addGestureRecognizer(progressGestureRecognizer);
        }
        return view;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (displayLeaderboardTab && tableView == leaderboardTable) {
            return buttonContainerOriginY + buttonContainer.frame.size.height + 10;
        } else if (displayProgressTab && tableView == progressTable) {
            return buttonContainerOriginY + buttonContainer.frame.size.height + 10;
        }
        return buttonContainerOriginY + buttonContainer.frame.size.height;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (displayLeaderboardTab && tableView == leaderboardTable) {
            return isIndividualLeaderboard ? min(individualLeaderboardParticipants.count,challenge.participantsCount) : min(teamLeaderboardParticipants.count, challenge.teams.count);
        } else if (displayProgressTab && tableView == progressTable) {
            return 1;
        }
        return 1;
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == individualLeaderboardCount - 1) {
            if (displayLeaderboardTab && tableView == leaderboardTable && isIndividualLeaderboard) {
                individualLeaderboardCount = min(individualLeaderboardCount + 50, challenge.participantsCount);
                loadMoreParticipants();
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (displayLeaderboardTab && tableView == leaderboardTable) {
            var cell = tableView.dequeueReusableCellWithIdentifier("ChallengeLeaderboardRow") as ChallengeLeaderboardRow!;
            if (cell == nil) {
                if (isIndividualLeaderboard) {
                    cell = ChallengeLeaderboardRow.instanceFromNib(challenge, participant: individualLeaderboardParticipants[indexPath.row], index: indexPath.row);
                    if (challenge.participants[indexPath.row].displayName == challenge.participant.displayName) {
                        cell.backgroundColor = Utility.colorFromHexString("#d5ffb8");
                    }
                } else if (challenge.teams[indexPath.row].name == challenge.participant.team.name) {
                    cell = ChallengeLeaderboardRow.instanceFromNib(challenge, team: teamLeaderboardParticipants[indexPath.row], index: indexPath.row);
                    cell.backgroundColor = Utility.colorFromHexString("#d5ffb8");
                }
            }
            return cell;
        } else if (displayProgressTab && tableView == progressTable) {
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: 200));
            let consolodatedWinConditions = Utility.consolodateWinConditions(challenge.winConditions);
            var individualGoalViewIndex = 0;
            var teamGoalViewIndex = 0;
            // the win condition for getting 1 point messed up my logic here since we don't have a view for it
            var ignoreOnePointGoalWinCondition = false;
            for index in 0...consolodatedWinConditions.count - 1 {
                let winConditionList = consolodatedWinConditions[index];
                let firstWinCondition = winConditionList[0];
                if (firstWinCondition.goal.type == "threshold_reached") {
                    if (firstWinCondition.winnerType == "individual") {
                        if (firstWinCondition.goal.minThreshold == 1) {
                            ignoreOnePointGoalWinCondition = true;
                        } else {
                            individualGoalViewIndex = ignoreOnePointGoalWinCondition ? index - 1 : index;
                        }
                    } else {
                        teamGoalViewIndex = ignoreOnePointGoalWinCondition ? index - 1 : index;
                    }
                }
            }
            let nibs = Utility.getChallengeViews(challenge, isComplex: true);
            if (isIndividualProgress) {
                cell.addSubview(nibs[individualGoalViewIndex]);
            } else {
                cell.addSubview(nibs[teamGoalViewIndex])
            }
            return cell;
        } else if (tableView == detailsTable) {
            return ChallengeDetailsTab.instanceFromNib(challenge);
        } else {
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "");
        }
    }

    func setProgressBar(view: UIView, points: Int, highScore: Int) {
        let width = view.frame.size.width;
        let proportion = min(CGFloat(points)/CGFloat(highScore), 1);
        let newWidth = proportion * width;
        participantContainer.frame.size.width = proportion * width;
        
        let clearBar = UIView(frame: CGRect(x: 0, y: view.frame.origin.y / 2 - 5, width: width, height: 5));
        clearBar.backgroundColor = UIColor(white: 0.5, alpha: 0.5);
        clearBar.layer.cornerRadius = 2;
        view.addSubview(clearBar);
        
        let greenBar = UIView(frame: CGRect(x: 0, y: view.frame.origin.y / 2 - 5, width: newWidth, height: 5));
        greenBar.backgroundColor = Utility.colorFromHexString("#76C043");
        greenBar.layer.cornerRadius = 2;
        view.addSubview(greenBar);
    }

    func changePage(page: Int) {
        moveGreenBar(page);
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
        currentPage = page;
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
        shouldScroll = false;
    }
    
    func loadMoreParticipants(){
        showLoadingFooter();
        var participants:[ChallengeParticipant] = [];
        let url = challenge.pagingData != nil ? challenge.pagingData?.nextUrl : nil;
        if (url != nil) {
            HigiApi().sendGet(url!, success: {operation, responseObject in
                if (self.isIndividualLeaderboard) {
                    var serverParticipants = ((responseObject as NSDictionary)["response"] as NSDictionary)["data"] as? NSArray;
                    var participants:[ChallengeParticipant] = [];
                    if (serverParticipants != nil) {
                        for singleParticipant: AnyObject in serverParticipants! {
                            participants.append(ChallengeParticipant(dictionary: singleParticipant as NSDictionary));
                        }
                    }
                    for singleParticipant in participants {
                        self.individualLeaderboardParticipants.append(singleParticipant);
                    }
                    self.leaderboardTable.reloadData();
                    self.hideLoadingFooter();
                }
                }, failure: { operation, error in
            });
        }
    }
    
    func showLoadingFooter() {
        
    }
    
    func hideLoadingFooter() {
        
    }
}