import Foundation

class ChallengeDetailsViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITextFieldDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet var pointsLabel:UILabel?;
    

    @IBOutlet weak var joinButton: UIButton!
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
    var challengeTeamSelected:Int?;
    
    var displayLeaderboardTab = false;
    var displayProgressTab = false;
    var displayChatterTab = false;
    
    var hasTeamGoalComponent = false;
    var hasIndividualGoalComponent = false;
    var hasTeamLeaderboardComponent = false;
    var hasIndividualLeaderboardComponent = false;
    
    var isIndividualLeaderboard = true;
    var isIndividualProgress = true;
    
    var showLoadingFooter = false;
    
    var leaderboardTable: UITableView?;
    var progressTable: UITableView?;
    var detailsTable: UITableView!;
    var chatterTable: UITableView?;

    var scrollY: CGFloat = 0;
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
    
    var leaderboardToggleButtons:[UIButton] = [];
    var progressToggleButtons:[UIButton] = [];
    var greenBars:[UIView] = [];
    let progressGestureRecognizer = UITapGestureRecognizer();
    let leaderboardGestureRecognizer = UITapGestureRecognizer();
    
    var individualLeaderboardCount = 50;
    var teamLeaderboardCount = 50;
    var individualLeaderboardParticipants:[ChallengeParticipant] = [];
    var teamLeaderboardParticipants:[ChallengeTeam] = [];

    var individualGoalWinConditions:[ChallengeWinCondition] = [];
    var teamGoalWinConditions:[ChallengeWinCondition] = [];
    var nonTrivialWinConditions = 0;
    
    var challengeChatterComments:[Comments] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        (self.navigationController as MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        
        var session = SessionController.Instance;
        
        initializeDetailView();
    }
    
    func initializeDetailView() {
        for winCondition in challenge.winConditions {
            if (challenge.participant != nil && winCondition.goal.type == "threshold_reached" && challenge.userStatus == "current") {
                displayProgressTab = true;
                if (winCondition.winnerType == "individual") {
                    hasIndividualGoalComponent = true;
                    individualGoalWinConditions.append(winCondition);
                } else if (winCondition.winnerType == "team") {
                    hasTeamGoalComponent = true;
                    teamGoalWinConditions.append(winCondition);
                }
            } else if (challenge.status != "registration" && winCondition.goal.type == "most_points" || winCondition.goal.type == "unit_goal_reached" && challenge.userStatus == "current") {
                displayLeaderboardTab = true;
                
                if (winCondition.winnerType == "individual") {
                    hasIndividualLeaderboardComponent = true;
                } else if (winCondition.winnerType == "team") {
                    hasTeamLeaderboardComponent = true;
                }
            }
            if (winCondition.goal.minThreshold > 1) {
                nonTrivialWinConditions++;
            }
        }
        
        if (displayLeaderboardTab && !hasIndividualGoalComponent && hasTeamLeaderboardComponent) {
            isIndividualLeaderboard = false;
        }
        if (challenge.participant != nil) {
            displayChatterTab = true;
            challengeChatterComments = challenge.chatter.comments;
        }
        
        populateHeader();
        
        populateScrollViewWithTables();
        
        populateTabButtons();
        
        if (displayLeaderboardTab && hasIndividualLeaderboardComponent && hasTeamLeaderboardComponent) {
            addToggleButtons(leaderboardTable!);
        }
        if (displayProgressTab && hasIndividualGoalComponent && hasTeamGoalComponent) {
            addToggleButtons(progressTable!);
        }
        if (hasIndividualLeaderboardComponent) {
            individualLeaderboardParticipants = challenge.participants;
        }
        if (hasTeamLeaderboardComponent) {
            teamLeaderboardParticipants = challenge.teams;
        }
    }
    
    func clearExistingViews() {
        if (displayLeaderboardTab) {
            leaderboardTable!.removeFromSuperview();
        }
        if (displayProgressTab) {
            progressTable!.removeFromSuperview();
        }
        detailsTable!.removeFromSuperview();
        if (displayChatterTab) {
            chatterTable!.removeFromSuperview();
        }
    }
    
    func addToggleButtons(table: UITableView) {
        let toggleButtonHeight:CGFloat = 60;
        let buttonMargin:CGFloat = 10;
        let header = UIControl(frame: CGRect(x: 0, y: buttonContainerOriginY + buttonContainer.frame.size.height + buttonMargin, width: contentView.frame.size.width, height: toggleButtonHeight  - buttonMargin));
        
        header.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        
        let toggleButtonsText = ["You", "Teams"];
        for index in 0...1 {
            //no x padding for first button
            let xPadding = index == 0 ? buttonMargin : buttonMargin / 2;
            let buttonX = xPadding + (CGFloat(index) * contentView.frame.size.width / 2);
            let buttonY = buttonContainerOriginY + buttonContainer.frame.size.height + buttonMargin;
            //subtract margin from width of second button
            let buttonWidth = (contentView.frame.size.width / 2) - (3/2 * buttonMargin);
            let buttonHeight = toggleButtonHeight - buttonMargin * 2;
            var button = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight));
            button.setBackgroundImage(makeImageWithColor(Utility.colorFromHexString("#76C043")), forState: UIControlState.Selected);
            button.setBackgroundImage(makeImageWithColor(UIColor.blackColor()), forState: UIControlState.Normal);
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
            button.setTitle(toggleButtonsText[index], forState: UIControlState.Normal);
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(12);
            button.selected = index == 0;
            button.enabled = true;
            button.layer.cornerRadius = 5;
            button.clipsToBounds = true;
            
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
            joinButton.hidden = true;
            let participant = challenge.participant!;
            participantAvatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            if (challenge.userStatus == "current") {
                participantPoints.hidden = false;
                participantPlace.hidden = false;
                participantProgress.hidden = false;
                participantAvatar.hidden = false;
                
                participantPoints.text = "\(Int(participant.units)) pts";
                participantPlace.text = getUserRank();
                setProgressBar(participantProgress, points: Int(participant.units), highScore: Int(challenge.individualHighScore));
            } else {
                participantPoints.hidden = true;
                participantPlace.hidden = true;
                participantProgress.hidden = true;
                participantAvatar.hidden = true;
            }
        } else {
            participantAvatar.hidden = true;
            participantPoints.hidden = true;
            participantPlace.hidden = true;
            participantProgress.hidden = true;
            //@todo make this static and global.  hide show it with other header elements
            //@todo loading spinner on button click
            joinButton.hidden = false;
        }

        challengeAvatar.setImageWithURL(Utility.loadImageFromUrl(challenge.imageUrl));
        challengeTitle.text = challenge.name;
        challengeDaysLeft.text = dateDisplayHelper();
        headerContainerHeight = headerContainer.frame.size.height;
        buttonContainerOriginY = buttonContainer.frame.origin.y;
        
        headerAvatarOriginX = participantAvatar.frame.origin.x;
        headerPlaceOriginX = participantPlace.frame.origin.x;
        headerProgressOriginX = participantProgress.frame.origin.x;
        headerProgressOriginWidth = participantProgress.frame.size.width;
        headerPointsOriginX = participantPoints.frame.origin.x;
    }
    
    @IBAction func joinButtonClick(sender: AnyObject) {
        let joinUrl =  challenge.joinUrl;
        if (joinUrl != nil) {
            joinChallenge(joinUrl);
        } else {
            showTeamsPicker();
        }
    }
    
    func dateDisplayHelper() -> String {
        var dateDisplay:String!
        let startDate:NSDate? = challenge.startDate?
        let endDate:NSDate? = challenge.endDate?
        if (Int(startDate!.timeIntervalSinceNow) > 0) {
            let days = Int(startDate!.timeIntervalSinceNow / 60 / 60 / 24) + 1;
            let s = days == 1 ? "" : "s";
            dateDisplay = "Starts in \(days) day\(s)";
        } else if (endDate != nil && Int(endDate!.timeIntervalSinceNow) > 0) {
            let days = Int(endDate!.timeIntervalSinceNow / 60 / 60 / 24) + 1;
            let s = days == 1 ? "" : "s";
            dateDisplay = "\(days) day\(s) left";
        } else if (endDate != nil && Int(endDate!.timeIntervalSinceNow) < 0) {
            dateDisplay = "Challenge finished!";
        } else {
            let days = Int(startDate!.timeIntervalSinceNow / 60 / 60 / 24) * -1;
            let s = days == 1 ? "" : "s";
            dateDisplay = "Started \(days) day\(s) ago";
        }
        return dateDisplay;
    }
    
    func joinChallenge(joinUrl: String) {
//        //@todo show terms and conditions?
//        showTermsAndConditions();
        let userId = !HigiApi.EARNDIT_DEV ? SessionData.Instance.user.userId : "rQIpgKhmd0qObDSr5SkHbw";
        var contents = NSMutableDictionary();
        contents.setObject(userId, forKey: "userId");
        HigiApi().sendPost(joinUrl, parameters: contents, success: {operation, responseObject in
            ApiUtility.retrieveChallenges(self.refreshChallenge);
            }, failure: { operation, error in
                let e = error;
                UIAlertView(title: "Uh oh", message: "Cannot join challenge at this time.  Please try again later.", delegate: self, cancelButtonTitle: "OK").show();
        });
    }
    
    func joinButtonClick(sender: AnyObject!) {
        let joinUrl =  challenge.joinUrl;
        if (joinUrl != nil) {
            joinChallenge(joinUrl);
        } else {
            showTeamsPicker();
        }
    }
    
    func showTermsAndConditions() {
        UIAlertView(title: "Terms and Conditions", message: "Terms and conditions placeholder", delegate: self, cancelButtonTitle: "Reject", otherButtonTitles: "Accept").show();
    }
    
    func showTeamsPicker() {
        let picker = UIActionSheet(title: "Select a team to join", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil);
        for team in challenge.teams {
            picker.addButtonWithTitle(team.name);
        }
        picker.addButtonWithTitle("Back");
        picker.cancelButtonIndex = challenge.teams.count;
        picker.showInView(scrollView);
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex != challenge.teams.count) {
            joinChallenge(challenge.teams[buttonIndex].joinUrl);
        }
    }
    func refreshChallenge() {
        let name = challenge.name;
        let challenges = SessionController.Instance.challenges;
        for challenge in challenges {
            if (name == challenge.name) {
                self.challenge = challenge;
            }
        }
        clearExistingViews();
        initializeDetailView();
    }
    
    func populateTabButtons() {
        var buttons:[UILabel] = [];
        greenBars = [];
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
            tabView.userInteractionEnabled = true;
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
        leaderboardTable!.reloadData();
    }
    
    func toggleProgressButtons(sender: AnyObject) {
        for button in progressToggleButtons {
            button.selected = !button.selected;
        }
        isIndividualProgress = progressToggleButtons[0].selected;
        progressTable!.reloadData();
    }
    
    func populateScrollViewWithTables() {
        var table:UITableView;
        //need to reset total pages for when we join a challenge
        totalPages = 0;
        tables = [];
        if (displayLeaderboardTab) {
            leaderboardTable = addTableView(totalPages);
            leaderboardTable!.tableFooterView?.hidden = true;
            scrollView.addSubview(leaderboardTable!);
            tables.append(leaderboardTable!);
            totalPages++;
        }
        if (displayProgressTab) {
            progressTable = addTableView(totalPages);
            scrollView.addSubview(progressTable!);
            tables.append(progressTable!);
            totalPages++;
        }
        detailsTable = ChallengeDetailsTab.instanceFromNib(challenge);
        detailsTable.frame = CGRect(x: CGFloat(totalPages) * scrollView.frame.size.width, y: buttonContainerOriginY + buttonContainer.frame.size.height, width: scrollView.frame.size.width, height: scrollView.frame.size.height);
        detailsTable.dataSource = self;
        detailsTable.delegate = self;
        detailsTable.separatorStyle = UITableViewCellSeparatorStyle.None;
        detailsTable.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        detailsTable.scrollEnabled = true;
        detailsTable.allowsSelection = false;
        detailsTable.showsVerticalScrollIndicator = false;
        scrollView.addSubview(detailsTable);
        tables.append(detailsTable);
        totalPages++;
        
//        detailsTable = addTableView(totalPages);
//        scrollView.addSubview(detailsTable);
//        tables.append(detailsTable);
//        totalPages++;
        
        if (displayChatterTab) {
            chatterTable = addTableView(totalPages);
            chatterTable!.backgroundColor = Utility.colorFromHexString("#F4F4F4");
            let textField = addChatterInputBox();
            chatterTable?.addSubview(textField);
            scrollView.addSubview(chatterTable!);
            tables.append(chatterTable!);
            totalPages++;
        }
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
        table.showsVerticalScrollIndicator = false;
        return table;
    }
    
    func getUserRank() -> String {
        let gravityBoard = challenge.gravityBoard;
        for index in 0...challenge.gravityBoard.count - 1 {
            if (gravityBoard[index].participant.url == challenge.participant.url) {
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
        if (scrollView != self.scrollView) {
            updateScroll();
        }
    }
    
    func updateScroll() {
        let headerXOffset:CGFloat = 50;
        let minHeaderHeightThreshold:CGFloat = 67;
        let currentTable = tables[currentPage];
        scrollY = currentTable.contentOffset.y;
        
        //@todo for some reason there is a hiccup in scrolling at a couple places, same scrollY values each time
        
        if (scrollY >= 0) {
            if (scrollY > headerContainerHeight - minHeaderHeightThreshold) {
                headerContainer.frame.origin.y = minHeaderHeightThreshold - headerContainerHeight;
                buttonContainer.frame.origin.y = minHeaderHeightThreshold - 1;
            } else {
                participantPlace.frame.origin.x = headerPlaceOriginX + (scrollY / headerXOffset);
                participantProgress.frame.origin.x = headerProgressOriginX + (scrollY / headerXOffset);
                
                var xOffset = min(scrollY * (headerXOffset / ((headerContainerHeight - minHeaderHeightThreshold) / 2)),50);
                participantAvatar.frame = CGRect(x: headerAvatarOriginX + xOffset, y: participantAvatar.frame.origin.y, width: 30, height: 30);
                participantPlace.frame = CGRect(x: headerPlaceOriginX + xOffset, y: participantPlace.frame.origin.y, width: 58, height: 25);
                participantProgress.frame = CGRect(x: headerProgressOriginX + xOffset, y: participantPoints.frame.origin.y, width: headerProgressOriginWidth - xOffset, height: 15);
                
                headerContainer.frame.origin.y = -scrollY;
                buttonContainer.frame.origin.y = buttonContainerOriginY - scrollY;
            }
        } else {
            participantPlace.frame.origin.x = headerPlaceOriginX;
            participantProgress.frame.origin.x = headerProgressOriginX;
            
            participantAvatar.frame = CGRect(x: headerAvatarOriginX, y: participantAvatar.frame.origin.y, width: 30, height: 30);
            participantPlace.frame = CGRect(x: headerPlaceOriginX, y: participantPlace.frame.origin.y, width: 58, height: 25);
            participantProgress.frame = CGRect(x: headerProgressOriginX, y: participantPoints.frame.origin.y, width: headerProgressOriginWidth, height: 15);
            
            headerContainer.frame.origin.y = 0;
            buttonContainer.frame.origin.y = buttonContainerOriginY;
        }
        
        for index in 0...tables.count - 1 {
            if (index != currentPage) {
                tables[index].contentOffset.y = min(scrollY, headerContainer.frame.size.height);
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        updateScroll();
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height);
        if (displayLeaderboardTab && leaderboardTable != nil ) {
            leaderboardTable!.frame.size.height = scrollView.frame.size.height;
        }
        if (displayProgressTab && progressTable != nil) {
            progressTable!.frame.size.height = scrollView.frame.size.height;
        }
        detailsTable.frame.size.height = scrollView.frame.size.height;
        if (displayChatterTab && chatterTable != nil) {
            chatterTable!.frame.size.height = scrollView.frame.size.height;
        }
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if (scrollView == self.scrollView) {
            let x = scrollView.contentOffset.x;
            let w = scrollView.frame.size.width;
            
            var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
            changePage(page);
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
        if (displayLeaderboardTab && hasIndividualLeaderboardComponent && hasTeamLeaderboardComponent && leaderboardTable != nil && tableView == leaderboardTable) {
            leaderboardGestureRecognizer.addTarget(self, action: "toggleLeaderboardButtons:");
            view.addGestureRecognizer(leaderboardGestureRecognizer);
        } else if (displayProgressTab && hasIndividualGoalComponent && hasTeamGoalComponent && progressTable != nil && tableView == progressTable) {
            progressGestureRecognizer.addTarget(self, action: "toggleProgressButtons:");
            view.addGestureRecognizer(progressGestureRecognizer);
        }
        return view;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (displayLeaderboardTab && leaderboardTable != nil && tableView == leaderboardTable) {
            return buttonContainerOriginY + buttonContainer.frame.size.height + 10;
        } else if (displayProgressTab && progressTable != nil && tableView == progressTable) {
            return buttonContainerOriginY + buttonContainer.frame.size.height + 10;
        } else if (displayChatterTab && chatterTable != nil && tableView == chatterTable) {
//            return -50;
        }
        return buttonContainerOriginY + buttonContainer.frame.size.height;
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (displayChatterTab && chatterTable != nil && tableView == chatterTable) {
            return showLoadingFooter ? 10 + 50: 50
        }
        return showLoadingFooter ? 10 : 0;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (displayLeaderboardTab && leaderboardTable != nil && tableView == leaderboardTable) {
            return leaderboardTable!.rowHeight;
        } else if (displayProgressTab && progressTable != nil && tableView == progressTable) {
            return indexPath.row == 0 ? 150 : 100;
        } else if (displayChatterTab && chatterTable != nil && tableView == chatterTable) {
            return getChatterRowHeight(indexPath.row);
        } else {
//            return getDetailsRowHeight(indexPath.row);
            return 800;
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
        if (displayChatterTab && chatterTable != nil && tableView == chatterTable) {
            view = UIView(frame: CGRect(x: chatterTable!.frame.origin.x, y: scrollView.frame.size.height - 50, width: scrollView.frame.size.width, height: 50));
            let textField = UITextField(frame: CGRect(x: 10, y: 0, width: scrollView.frame.size.width, height: 50));
            view.backgroundColor = UIColor.whiteColor();
            textField.placeholder = "Talk some smack!";
            textField.font = textField.font.fontWithSize(14);
            textField.delegate = self;
            textField.returnKeyType = UIReturnKeyType.Done;
            view.addSubview(textField);
        }
        return view;
        //@todo show loading footer
//        if (showLoadingFooter) {
//            let footer = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: 10));
//            let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 10, height: 10));
//            footer.addSubview(spinner);
//            spinner.startAnimating();
//            footer.backgroundColor = UIColor.blackColor();
//            return footer;
//        } else {
//            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
//        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (displayLeaderboardTab && leaderboardTable != nil && tableView == leaderboardTable) {
            return isIndividualLeaderboard ? min(individualLeaderboardParticipants.count,challenge.participantsCount) : min(teamLeaderboardParticipants.count, challenge.teams.count);
        } else if (displayProgressTab && progressTable != nil && tableView == progressTable) {
            //one row for each win condition plus 1 for graph view
            return isIndividualProgress ? individualGoalWinConditions.count + 1: teamGoalWinConditions.count + 1;
        } else if (detailsTable != nil && tableView == detailsTable) {
            return challenge.winConditions.count;
        } else if (displayChatterTab && chatterTable != nil && tableView == chatterTable) {
            return challengeChatterComments.count;
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (displayLeaderboardTab && leaderboardTable != nil && tableView == leaderboardTable && isIndividualLeaderboard && individualLeaderboardCount != challenge.participantsCount && indexPath.row == individualLeaderboardCount - 1) {
            individualLeaderboardCount = min(individualLeaderboardCount + 50, challenge.participantsCount);
            loadMoreParticipants();
        } else if (displayChatterTab && chatterTable != nil && tableView == chatterTable && indexPath.row == challengeChatterComments.count - 1) {
            loadMoreChatter();
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (displayLeaderboardTab && leaderboardTable != nil && tableView == leaderboardTable) {
            return createLeaderboardCell(indexPath.row);
        } else if (displayProgressTab && progressTable != nil && tableView == progressTable) {
            return createProgressTable(indexPath.row);
        } else if (detailsTable != nil && tableView == detailsTable) {
            return ChallengeDetailsPrize.instanceFromNib(challenge.winConditions[indexPath.row]);
        } else {
            return createChatterTable(indexPath.row);
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
    }
    
    func loadMoreParticipants(){
        showLoadingFooter = true;
        leaderboardTable!.reloadData();
        //showLoadingFooter();
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
                    self.showLoadingFooter = false;
                    self.leaderboardTable!.reloadData();
                    //self.showLoadingFooter = false;
                    //self.hideLoadingFooter();
                }
                }, failure: { operation, error in
            });
        }
    }
    
    func refreshChatter() {
        var comments:[Comments] = [];
        let url = challenge.commentsUrl;
        if (url != nil && url != "") {
            HigiApi().sendGet(url!, success: {operation, responseObject in
                self.challengeChatterComments = [];
                var chatter:Chatter;
                let serverComments = ((responseObject as NSDictionary)["response"] as NSDictionary)["data"] as? NSArray;
                if (serverComments != nil) {
                    self.challenge.chatter.paging.nextUrl = ((responseObject as NSDictionary)["response"] as NSDictionary)["paging"] as? NSString;
                    for challengeComment in serverComments! {
                        let comment = (challengeComment as NSDictionary)["comment"] as NSString;
                        let timeSinceLastPost = (challengeComment as NSDictionary)["timeSincePosted"] as NSString;
                        let commentParticipant = ChallengeParticipant(dictionary: (challengeComment as NSDictionary)["participant"] as NSDictionary);
                        let commentTeam = commentParticipant.team?;
                        var pagingData = 0;
                        
                        self.challengeChatterComments.append(Comments(comment: comment, timeSincePosted: timeSinceLastPost, participant: commentParticipant, team: commentTeam))
                    }
                }
                self.chatterTable!.reloadData();
                }, failure: { operation, error in
                    let e = error;
            });
        }
    }

    func loadMoreChatter() {
        showLoadingFooter = true;
        var comments:[Comments] = [];
        let url = challenge.chatter.paging.nextUrl;
        if (url != nil && url != "") {
            HigiApi().sendGet(url!, success: {operation, responseObject in
                var chatter:Chatter;
                let serverComments = ((responseObject as NSDictionary)["response"] as NSDictionary)["data"] as? NSArray;
                if (serverComments != nil) {
                    self.challenge.chatter.paging.nextUrl = ((responseObject as NSDictionary)["response"] as NSDictionary)["paging"] as? NSString;
                    for challengeComment in serverComments! {
                        let comment = (challengeComment as NSDictionary)["comment"] as NSString;
                        let timeSinceLastPost = (challengeComment as NSDictionary)["timeSincePosted"] as NSString;
                        let commentParticipant = ChallengeParticipant(dictionary: (challengeComment as NSDictionary)["participant"] as NSDictionary);
                        let commentTeam = commentParticipant.team?;
                        var pagingData = 0;
                        
                        self.challengeChatterComments.append(Comments(comment: comment, timeSincePosted: timeSinceLastPost, participant: commentParticipant, team: commentTeam))
                    }
                }
                self.showLoadingFooter = false;
                self.chatterTable!.reloadData();
                //self.showLoadingFooter = false;
                //self.hideLoadingFooter();
                }, failure: { operation, error in
                    let e = error;
            });
        }
    }
    
    func createLeaderboardCell(index: Int) -> UITableViewCell {
        var cell = leaderboardTable!.dequeueReusableCellWithIdentifier("ChallengeLeaderboardRow") as ChallengeLeaderboardRow!;
        if (cell == nil) {
            if (isIndividualLeaderboard) {
                cell = ChallengeLeaderboardRow.instanceFromNib(challenge, participant: individualLeaderboardParticipants[index], place: String(index + 1));
                if (individualLeaderboardParticipants[index].url == challenge.participant.url) {
                    cell.backgroundColor = Utility.colorFromHexString("#d5ffb8");
                }
            } else {
                cell = ChallengeLeaderboardRow.instanceFromNib(challenge, team: teamLeaderboardParticipants[index], index: index);
                if (teamLeaderboardParticipants[index].name == challenge.participant.team.name) {
                    cell.backgroundColor = Utility.colorFromHexString("#d5ffb8");
                }
            }
        }
        return cell;
    }
    
    func createProgressTable(index: Int) -> UITableViewCell {
        if (index == 0) {
            return createProgressGraph();
        } else {
            return createProgressLegendRow(index - 1);
        }
    }
    
    func createProgressGraph() -> UITableViewCell {
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
        cell.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        return cell;
    }
    
    func createProgressLegendRow(index: Int) -> UITableViewCell {
        let displayIndex = index + 1;
        let winConditions = isIndividualProgress ? individualGoalWinConditions : teamGoalWinConditions;
        return ChallengeProgressLegendRow.instanceFromNib(winConditions[index], userPoints: challenge.participant.units,  metric: challenge.metricAbbreviated(), index: displayIndex);
    }
    
    func createDetailsTable(index: Int) -> UITableViewCell {
        return ChallengeDetailsRow.instanceFromNib(challenge, index: index);
    }
    
    func getDetailsRowHeight(index: Int) -> CGFloat {
        return 50 + ChallengeDetailsRow.heightForIndex(challenge, index: index, width: detailsTable.frame.size.width, margin: 0);
    }
    
    func getChatterRowHeight(index: Int) -> CGFloat {
        return 50 + ChallengeDetailsChatterRow.heightForIndex(challengeChatterComments[index]);
    }
    
    func createChatterTable(index: Int) -> UITableViewCell {
        let chatter = challengeChatterComments[index];
        let cell = ChallengeDetailsChatterRow.instanceFromNib(chatter.comment, participant: chatter.participant, timeSincePosted: chatter.timeSincePosted, isYou: chatter.participant.url == challenge.participant.url);
        cell.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        return cell;
    }
    
    func addChatterInputBox() -> UIView {
        let view = UIView(frame: CGRect(x: chatterTable!.frame.origin.x, y: scrollView.frame.size.height - 50, width: scrollView.frame.size.width, height: 50));
        return view;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let text = textField.text;
        if (textField.text != "") {
            sendUserChatter(textField.text);
        }
        return true;
    }
    
    func sendUserChatter(chatter: String) {
        //@todo add message row while waiting for server response
        
        let userId = !HigiApi.EARNDIT_DEV ? SessionData.Instance.user.userId : "rQIpgKhmd0qObDSr5SkHbw";
        var contents = NSMutableDictionary();
        contents.setObject(userId, forKey: "userId");
        contents.setObject(chatter, forKey: "comment");
        HigiApi().sendPost(challenge.commentsUrl, parameters: contents, success: {operation, responseObject in
            self.addPlaceholderChatter(chatter);
            self.refreshChatter();
//            ApiUtility.retrieveChallenges(self.refreshChallenge);
            //@todo refresh comments, i.e. get comments from server again
            let i = 0;
            }, failure: { operation, error in
                let e = error;
                UIAlertView(title: "Uh oh", message: "Cannot send chatter at this time.  Please try again later.", delegate: self, cancelButtonTitle: "OK").show();
        });
    }
    
    func addPlaceholderChatter(comment: String) {
        let userChatter = Comments(comment: comment, timeSincePosted: "Sending...", participant: challenge.participant, team: challenge.participant.team);
        challengeChatterComments.insert(userChatter, atIndex: 0);
        chatterTable!.reloadData();
        chatterTable!.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true);
        //@todo scroll to top
    }
    
}