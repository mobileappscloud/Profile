import Foundation

class ChallengeDetailsViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate {
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
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
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
    var detailsTable: ChallengeDetailsTab!;
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
    
    var tabButtonLabels:[String] = [];
    var tabButtonIcons:[String] = [];
    var leaderboardToggleButtons:[UIButton] = [];
    var progressToggleButtons:[UIButton] = [];
    var greenBars:[UIView] = [];
    
    var individualLeaderboardCount = 50;
    
    var prizesHeight:CGFloat = 0;

    var individualLeaderboardParticipants:[ChallengeParticipant] = [];
    var teamLeaderboardParticipants:[ChallengeTeam] = [];

    var individualGoalWinConditions:[ChallengeWinCondition] = [];
    var teamGoalWinConditions:[ChallengeWinCondition] = [];
    var nonTrivialWinConditions = 0;
    
    var challengeChatterComments:[Comments] = [];
    
    var isLeaving = false;
    
    var userChatter:String?;
    var actionButton:UIButton!;
    var actionButtonY:CGFloat = 0;
    var chatterView:UIView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        initBackButton();
        initializeDetailView();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        if (userChatter != nil) {
            sendUserChatter(userChatter!);
            userChatter = nil;
        }
    }
    
    func initBackButton() {
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    func initializeDetailView() {
        for winCondition in challenge.winConditions {
            if (challenge.participant != nil && winCondition.goal.type == "threshold_reached" && challenge.userStatus == "current" && winCondition.goal.minThreshold > 1) {
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
        
        individualGoalWinConditions.sort { $0.goal.minThreshold! > $1.goal.minThreshold! }
        teamGoalWinConditions.sort { $0.goal.minThreshold! > $1.goal.minThreshold! }
        
        if (displayLeaderboardTab && !hasIndividualLeaderboardComponent && hasTeamLeaderboardComponent) {
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
    
    func addToggleButtons(table: UITableView) {
        let toggleButtonHeight:CGFloat = 60;
        let buttonMargin:CGFloat = 10;
        let header = UIView(frame: CGRect(x: 0, y: buttonContainerOriginY + buttonContainer.frame.size.height + buttonMargin, width: contentView.frame.size.width, height: toggleButtonHeight - buttonMargin));
        
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
            var button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
            button.frame = CGRect(x: buttonX, y: 0, width: buttonWidth, height: buttonHeight);
            button.setBackgroundImage(makeImageWithColor(Utility.colorFromHexString("#76C043")), forState: UIControlState.Selected);
            button.setBackgroundImage(makeImageWithColor(UIColor.blackColor()), forState: UIControlState.Normal);
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
            button.setTitle(toggleButtonsText[index], forState: UIControlState.Normal);
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(12);
            button.selected = index == 0;
            button.enabled = true;
            button.userInteractionEnabled = true;
            button.layer.cornerRadius = 6;
            button.clipsToBounds = true;
            
            if (table == leaderboardTable) {
                leaderboardToggleButtons.append(button);
                button.addTarget(self, action: "toggleLeaderboardButtons:", forControlEvents: UIControlEvents.TouchUpInside);
            } else {
                progressToggleButtons.append(button);
                button.addTarget(self, action: "toggleProgressButtons:", forControlEvents: UIControlEvents.TouchUpInside);
            }
            header.addSubview(button);
        }
        table.addSubview(header);
    }

    func populateHeader() {
        if (challenge.participant != nil) {
            participantAvatar.hidden = false;
            participantPoints.hidden = false;
            participantProgress.hidden = false;
            participantPlace.hidden = false;
            joinButton.hidden = true;
            let participant = challenge.participant!;
            if (challenge.winConditions[0].winnerType == "individual") {
                participantPoints.text = "\(Int(participant.units)) \(challenge.abbrMetric)";
                if (challenge.winConditions[0].goal.type == "threshold_reached") {
                    participantPlace.text = "";
                } else {
                    participantPlace.text = getUserRank(false);
                }
                setProgressBar(participantProgress, points: Int(participant.units), highScore: Int(challenge.individualHighScore));
                participantAvatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            } else {
                participantPoints.text = "\(Int(participant.team.units)) \(challenge.abbrMetric)";
                if (challenge.winConditions[0].goal.type == "threshold_reached") {
                    participantPlace.text = "";
                } else {
                    participantPlace.text = getUserRank(true);
                }
                setProgressBar(participantProgress, points: Int(participant.team.units), highScore: Int(challenge.teamHighScore));
                participantAvatar.setImageWithURL(Utility.loadImageFromUrl(participant.team.imageUrl));
            }
            participantPoints.sizeToFit();
        } else {
            participantAvatar.hidden = true;
            participantPoints.hidden = true;
            participantProgress.hidden = true;
            participantPlace.hidden = true;
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
        Flurry.logEvent("ChallengeJoined");
        joinButton.hidden = true;
        loadingSpinner.hidden = false;
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
        } else if (endDate != nil) {
            var formatter = NSDateFormatter();
            formatter.dateFormat = "yyyyMMdd";
            if (formatter.stringFromDate(NSDate()) == formatter.stringFromDate(endDate!)) {
                dateDisplay = "Ends today!";
            } else if (Int(endDate!.timeIntervalSinceNow) > 0) {
                let days = Int(endDate!.timeIntervalSinceNow / 60 / 60 / 24) + 1;
                let s = days == 1 ? "" : "s";
                dateDisplay = "\(days) day\(s) left";
            } else if (Int(endDate!.timeIntervalSinceNow) < 0) {
                dateDisplay = "Challenge finished!";
            }
        } else {
            dateDisplay = "";
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
            self.loadingSpinner.hidden = true;
            }, failure: { operation, error in
                let e = error;
                UIAlertView(title: "Uh oh", message: "Cannot join challenge at this time.  Please try again later.", delegate: self, cancelButtonTitle: "OK").show();
                self.joinButton.hidden = false;
                self.loadingSpinner.hidden = true;
        });
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
        } else {
            joinButton.hidden = false;
            loadingSpinner.hidden = true;
        }
    }
    
    func refreshChallenge() {
        self.loadingSpinner.hidden = true;
        let challenges = SessionController.Instance.challenges;
        for challenge in challenges {
            if (self.challenge.name == challenge.name) {
                self.challenge = challenge;
            }
        }
        clearExistingViews();
        initializeDetailView();
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
        greenBars = [];
        totalPages = 0;
        tables = [];
        tabButtonIcons = [];
        tabButtonLabels = [];
    }
    
    func populateTabButtons() {
        let containerYValue = buttonContainer.frame.origin.y;
        
        let buttonHeight:CGFloat = buttonContainer.frame.size.height;
        let buttonWidth = buttonContainer.frame.size.width / CGFloat(tabButtonLabels.count);
        
        for index in 0...tabButtonLabels.count - 1 {
            buttonContainer.addSubview(makeTabButton(tabButtonLabels[index], buttonImageName: tabButtonIcons[index], index: index, height: buttonHeight, width: buttonWidth));
        }
    }
    
    func makeTabButton(buttonText: String, buttonImageName: String, index: Int, height: CGFloat, width: CGFloat) -> UIView {
        let tabGestureRecognizer = UITapGestureRecognizer();
        tabGestureRecognizer.addTarget(self, action: "selectTabButton:");
        let tabView = UIView(frame: CGRect(x: width * CGFloat(index), y: 0, width: width, height: height));
        tabView.backgroundColor = Utility.colorFromHexString("#FDFDFD");
        tabView.tag = index;
        let image = UIImageView(frame: CGRect(x: width/2 - 15, y: 10, width: 30, height: 20));
        image.image = UIImage(named: buttonImageName);
        let label = UILabel(frame: CGRect(x: 0, y: image.frame.origin.y + image.frame.size.height + 2, width: width, height: 25));
        label.font = UIFont.systemFontOfSize(10);
        label.tintColor = UIColor.darkGrayColor();
        label.textAlignment = NSTextAlignment.Center;
        label.text = buttonText;
        let greenBar = UIView(frame: CGRect(x: 0, y: height - 3, width: width, height: 3));
        greenBar.backgroundColor = Utility.colorFromHexString("#76C043");
        greenBar.hidden = index != 0;
        greenBars.append(greenBar);
        tabView.addSubview(greenBar);
        tabView.addSubview(image);
        tabView.addSubview(label);
        tabView.userInteractionEnabled = true;
        tabView.addGestureRecognizer(tabGestureRecognizer);
        return tabView;
    }
    
    func selectTabButton(sender: AnyObject) {
        let view = sender.view as UIView!;
        Flurry.logEvent("\(tabButtonLabels[view.tag])Tab_Pressed");
        changePage(view.tag);
    }
    
    func moveGreenBar(page: Int) {
        for bar in greenBars {
            bar.hidden = true;
        }
        greenBars[page].hidden = false;
    }
    
    func toggleLeaderboardButtons(sender: UIButton!) {
        for button in leaderboardToggleButtons {
            button.selected = false;
        }
        sender.selected = true;
        isIndividualLeaderboard = leaderboardToggleButtons[0].selected;
        leaderboardTable!.reloadData();
    }
    
    func toggleProgressButtons(sender: UIButton!) {
        for button in progressToggleButtons {
            button.selected = false;
        }
        sender.selected = true;
        isIndividualProgress = progressToggleButtons[0].selected;
        progressTable!.reloadData();
    }
    
    func populateScrollViewWithTables() {
        if (displayLeaderboardTab) {
            tabButtonLabels.append("Leaderboard");
            tabButtonIcons.append("ui_leaderboards.png");
            leaderboardTable = addTableView(totalPages);
            leaderboardTable!.tableFooterView?.hidden = true;
            scrollView.addSubview(leaderboardTable!);
            tables.append(leaderboardTable!);
            totalPages++;
        }
        if (displayProgressTab) {
            tabButtonLabels.append("Progress");
            tabButtonIcons.append("ui_progress.png");
            progressTable = addTableView(totalPages);
            scrollView.addSubview(progressTable!);
            tables.append(progressTable!);
            totalPages++;
        }
        
        tabButtonLabels.append("Details");
        tabButtonIcons.append("ui_details.png");
        detailsTable = initDetailsTable();
        scrollView.addSubview(detailsTable);
        tables.append(detailsTable);
        totalPages++;
        
        if (displayChatterTab) {
            tabButtonLabels.append("Chatter");
            tabButtonIcons.append("ui_chatter.png");
            chatterTable = addTableView(totalPages);
            chatterTable!.backgroundColor = Utility.colorFromHexString("#F4F4F4");
            
            chatterView = UIView(frame: CGRect(x: chatterTable!.frame.origin.x, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height));
            chatterTable!.frame.origin.x = 0;
            
            let actionButtonWidth:CGFloat = 40;
            let actionButtonMargin:CGFloat = 8;
            actionButtonY = UIScreen.mainScreen().bounds.size.height - actionButtonWidth - actionButtonMargin;
            actionButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.size.width - (actionButtonWidth + actionButtonMargin), y: actionButtonY, width: actionButtonWidth, height: actionButtonWidth));
            actionButton.setTitle("+", forState: UIControlState.Normal);
            actionButton.titleLabel?.center = actionButton.center;
            actionButton.titleLabel?.textColor = UIColor.whiteColor();
            actionButton.backgroundColor = Utility.colorFromHexString("#76C043");
            actionButton.layer.cornerRadius = actionButtonWidth / 2;
            actionButton.addTarget(self, action: "gotoChatterInput:", forControlEvents: UIControlEvents.TouchUpInside);
            
            chatterView.addSubview(chatterTable!);
            chatterView.addSubview(actionButton);
            scrollView.addSubview(chatterView);
            tables.append(chatterTable!);
            totalPages++;
        }
        
        scrollView.delegate = self;
        self.automaticallyAdjustsScrollViewInsets = false;
        scrollView.frame = UIScreen.mainScreen().bounds;
        scrollView.contentSize = CGSize(width: UIScreen.mainScreen().bounds.width * CGFloat(totalPages), height: 1);
    }

    func gotoChatterInput(sender: AnyObject) {
        var chatterInputController = ChatterInputViewController(nibName: "ChatterInputView", bundle: nil);
        chatterInputController.parent = self;
        self.presentViewController(chatterInputController, animated: false, completion: nil);
    }

    func initDetailsTable() -> ChallengeDetailsTab {
        let rowTextYOffset:CGFloat = 30;
        let table = UINib(nibName: "ChallengeDetailsTab", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsTab;
        let firstWinCondition = challenge.winConditions[0];
        
        table.descriptionText.text = challenge.shortDescription.stringByDecodingHTMLEntities();
        if (challenge.endDate != nil) {
            table.durationText.text = setDateRangeHelper(challenge.startDate, endDate: challenge.endDate);
        } else {
            table.durationText.text = "Never ends!";
        }
        table.typeText.text = "\(goalTypeDisplayHelper(firstWinCondition.goal.type.description, winnerType: firstWinCondition.winnerType)). \(limitDisplayHelper(challenge.dailyLimit, metric: challenge.metric))";
        
        let teamCount = challenge.teams != nil ? challenge.teams.count : 0;
        if (teamCount > 0) {
            table.teamCountText.text = String(challenge.teams.count);
            table.participantIcon.text = "\u{f007}";
            table.individualCountText.text = String(challenge.participantsCount);
        } else {
            table.teamCountView.removeFromSuperview();
            table.participantCountView.removeFromSuperview();
            let participantRowView = UINib(nibName: "ChallengeDetailsParticipantIconView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsParticipantIcon;
            participantRowView.icon.text = "\u{f007}"
            participantRowView.count.text = String(challenge.participantsCount);
            participantRowView.center.x = table.participantRowView.center.x;
            participantRowView.frame.origin.y = rowTextYOffset;
            table.participantRowView.addSubview(participantRowView);
        }
        
        var termsButton = table.termsButton;
        
        termsButton.addTarget(self, action: "termsClick:", forControlEvents: UIControlEvents.TouchUpInside);
        
        var yOffset = rowTextYOffset;
        for winCondition in challenge.winConditions {
            if (winCondition.prizeName != nil && winCondition.prizeName != "") {
                let prizeRow = createDetailsPrizeCell(winCondition);
                prizeRow.frame.origin.y = yOffset;
                
                table.prizesContainer.addSubview(prizeRow);
                yOffset += prizeRow.height;
            }
        }
        if (yOffset == rowTextYOffset) {
            let prizeRow = createDetailsPrizeCell(nil);
            prizeRow.frame.origin.y = yOffset;
            
            table.prizesContainer.addSubview(prizeRow);
            yOffset += prizeRow.height;
        }
        prizesHeight = yOffset;
        table.prizesContainer.frame.size.height = yOffset;
        table.frame = UIScreen.mainScreen().bounds;
        table.frame.origin.x = CGFloat(totalPages) * UIScreen.mainScreen().bounds.size.width;
        table.dataSource = self;
        table.delegate = self;
        table.separatorStyle = UITableViewCellSeparatorStyle.None;
        table.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        table.scrollEnabled = true;
        table.allowsSelection = false;
        table.showsVerticalScrollIndicator = false;
        table.headerView.frame.size.height = termsButton.frame.origin.y + termsButton.frame.size.height;
        table.reloadData();
        table.layoutIfNeeded();
        return table;
    }
    
    func setDateRangeHelper(startDate: NSDate, endDate: NSDate) -> String {
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM. dd, YYYY"
        return "\(dateFormatter.stringFromDate(startDate)) - \(dateFormatter.stringFromDate(endDate))";
    }
    
    func goalTypeDisplayHelper(goalType: String, winnerType: String) -> String {
        var firstPart = winnerType == "individual" ? "Individual" : "Team";
        var secondPart = goalType == "most_points" ? "Points Challenge" : "Goal Challenge";
        return firstPart + " " + secondPart;
    }
    
    func durationHelper(startDate: NSDate, endDate: NSDate?) -> String {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM. dd, YYYY"
        if (endDate != nil) {
            return "\(dateFormatter.stringFromDate(startDate)) - \(dateFormatter.stringFromDate(endDate!))";
        } else {
            return "\(dateFormatter.stringFromDate(startDate)) - No end date";
        }
    }
    
    func limitDisplayHelper(limit: Int, metric: String) -> String {
        if (limit > 0) {
            return "Limit of \(limit) \(metric) per day.";
        } else {
            return "Unlimited \(metric) per day.";
        }
    }
    
    func termsClick(sender: AnyObject) {
        var termsController = TermsAndConditionsViewController(nibName: "TermsAndConditionsView", bundle: nil);
        termsController.html = challenge.terms;
        self.presentViewController(termsController, animated: false, completion: nil);
    }
    
    func addTableView(page: Int) -> UITableView {
        let viewWidth = UIScreen.mainScreen().bounds.size.width;
        let viewHeight:CGFloat = UIScreen.mainScreen().bounds.size.height;
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView != self.scrollView) {
            updateScroll();
        }
    }
    
    func updateScroll() {
        let headerXOffset:CGFloat = 50;
        let minHeaderHeightThreshold:CGFloat = 67;
        let maxProgressOffset:CGFloat = participantPoints.frame.origin.x - participantProgress.frame.origin.x - participantProgress.frame.size.width;
        
        if (!isLeaving && tables.count > currentPage) {
            let currentTable = tables[currentPage];
            scrollY = currentTable.contentOffset.y;
            if (scrollY >= 0) {
                if (scrollY > headerContainerHeight - minHeaderHeightThreshold) {
                    headerContainer.frame.origin.y = minHeaderHeightThreshold - headerContainerHeight;
                    buttonContainer.frame.origin.y = minHeaderHeightThreshold - 1;
                } else {
                    participantPlace.frame.origin.x = headerPlaceOriginX + (scrollY / headerXOffset);
                    var xOffset = min(scrollY * (headerXOffset / ((headerContainerHeight - minHeaderHeightThreshold) / 2)),headerXOffset);
                    var progressOffset = min(xOffset / 2, headerXOffset);
                    participantAvatar.frame.origin.x = headerAvatarOriginX + xOffset;
                    participantPlace.frame.origin.x = headerPlaceOriginX + xOffset;
                    participantProgress.frame.origin.x = headerProgressOriginX + min(progressOffset, maxProgressOffset);

                    headerContainer.frame.origin.y = -scrollY;
                    buttonContainer.frame.origin.y = buttonContainerOriginY - scrollY;
                }
            } else {
                participantPlace.frame.origin.x = headerPlaceOriginX;
                participantProgress.frame.origin.x = headerProgressOriginX;
                participantAvatar.frame.origin.x = headerAvatarOriginX;
                participantPlace.frame.origin.x = headerPlaceOriginX;
                participantProgress.frame.origin.x = headerProgressOriginX;
                
                headerContainer.frame.origin.y = 0;
                buttonContainer.frame.origin.y = buttonContainerOriginY;
            }
            
            for index in 0...tables.count - 1 {
                if (index != currentPage) {
                    tables[index].contentOffset.y = min(scrollY, headerContainer.frame.size.height);
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();

        updateScroll();

        let minTableHeight = UIScreen.mainScreen().bounds.size.height + (buttonContainerOriginY - buttonContainer.frame.size.height);
        if (displayLeaderboardTab && leaderboardTable != nil ) {
            leaderboardTable!.frame.size.height = UIScreen.mainScreen().bounds.size.height;
            leaderboardTable!.contentSize.height = max(leaderboardTable!.contentSize.height, minTableHeight - 10);
        }
        if (displayProgressTab && progressTable != nil) {
            progressTable!.frame.size.height = UIScreen.mainScreen().bounds.size.height;
            progressTable!.contentSize.height = max(progressTable!.contentSize.height, minTableHeight);
        }
        var frame = detailsTable.prizesContainer.frame;
        var height = detailsTable.prizesContainer.frame.origin.y + prizesHeight + 305;
        var descFrame = detailsTable.descriptionView.frame;
        detailsTable.contentSize.height = max(height, minTableHeight);
        detailsTable.headerView.frame.size.height = detailsTable.termsButton.frame.origin.y + detailsTable.termsButton.frame.size.height;
        
        if (displayChatterTab && chatterTable != nil) {
            chatterView.frame.size.height = UIScreen.mainScreen().bounds.size.height;
            chatterTable!.frame.size.height = UIScreen.mainScreen().bounds.size.height;
            chatterTable!.contentSize.height = max(chatterTable!.contentSize.height, minTableHeight - 10);
        }
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if (scrollView == self.scrollView) {
            var page = lround(Double(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width));
            changePage(page);
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
        view.userInteractionEnabled = false;
        return view;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (displayLeaderboardTab && leaderboardTable != nil && tableView == leaderboardTable) {
            var height = buttonContainerOriginY + buttonContainer.frame.size.height;
            if (leaderboardToggleButtons.count > 0) {
                height += 50;
            }
            return height;
        } else if (displayProgressTab && progressTable != nil && tableView == progressTable) {
            var height = buttonContainerOriginY + buttonContainer.frame.size.height + 10
            if (progressToggleButtons.count > 0) {
                height += 50;
            }
            return height;
        } else {
            return buttonContainerOriginY + buttonContainer.frame.size.height;
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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
            return createDetailsPrizeCell(challenge.winConditions[indexPath.row]).height;
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //@todo show loading footer
//        if (showLoadingFooter) {
//            let footer = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: 10));
//            let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 10, height: 10));
//            footer.addSubview(spinner);
//            spinner.startAnimating();
//            footer.backgroundColor = UIColor.blackColor();
//            return footer;
//        } else {
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
//        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (displayLeaderboardTab && leaderboardTable != nil && tableView == leaderboardTable) {
            return isIndividualLeaderboard ? min(individualLeaderboardParticipants.count, challenge.participantsCount) : min(teamLeaderboardParticipants.count, challenge.teams.count);
        } else if (displayProgressTab && progressTable != nil && tableView == progressTable) {
            //one row for each win condition plus 1 for graph view
            return isIndividualProgress ? individualGoalWinConditions.count + 1: teamGoalWinConditions.count + 1;
        } else if (detailsTable != nil && tableView == detailsTable) {
            return 0;
//            return challenge.winConditions.count;
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
            return createDetailsPrizeCell(challenge.winConditions[indexPath.row])
        } else {
            return createChatterTable(indexPath.row);
        }
    }
    
    func createDetailsPrizeCell(winCondition: ChallengeWinCondition!) -> ChallengeDetailsPrize {
//        var cell = detailsTable!.dequeueReusableCellWithIdentifier("ChallengeDetailsPrize") as ChallengeDetailsPrize!;
//        if (cell == nil) {
            var cell = UINib(nibName: "ChallengeDetailsPrizes", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsPrize;
            if (winCondition != nil && winCondition.prizeName != nil && winCondition.prizeName != "") {
                cell.title.text = winCondition.prizeName;
                cell.desc.text = winCondition.description;
            } else {
                cell.title.text = "No prize, doing this simply for the love of the game.";
                cell.desc.text = "";
            }
            
            cell.title.sizeToFit();
            cell.desc.sizeToFit();
        
            cell.height = cell.desc.frame.origin.y + cell.desc.frame.size.height + 20;
//        }
        return cell;
    }
    
    func setProgressBar(view: UIView, points: Int, highScore: Int) {
        let width = view.frame.size.width;
        let barHeight:CGFloat = 4;
        let nodeHeight:CGFloat = 10;
        //** idk why this is + and not - ...auto-layout?
        let posY = view.frame.origin.y / 2 + barHeight / 2;
        var proportion:CGFloat;
        if (challenge.winConditions[0].goal.type == "threshold_reached") {
            var largestGoal = challenge.winConditions[0].winnerType == "individual" ? individualGoalWinConditions[0].goal.minThreshold : teamGoalWinConditions[0].goal.minThreshold;
            if (largestGoal == 0) {
                largestGoal = 1;
            }
            let participantPoints = challenge.winConditions[0].winnerType == "individual" ? challenge.participant.units : challenge.participant.team.units;
            proportion = min(CGFloat(participantPoints) / CGFloat(largestGoal), 1);
            for winCondition in individualGoalWinConditions {
                let goalVal = winCondition.goal.minThreshold;
                let posX = min(width, CGFloat(goalVal) / CGFloat(largestGoal) * width) - nodeHeight / 2;
                //** idk why this is / 4 instead of /2 ... auto-layout?
                let goalCircle = UIView(frame: CGRect(x: posX, y: posY - nodeHeight / 4 , width: nodeHeight, height: nodeHeight));
                let circleColor:UIColor = participantPoints > Double(goalVal) ? Utility.colorFromHexString("#76C043") : UIColor(white: 0.5, alpha: 1);
                goalCircle.backgroundColor = circleColor;
                goalCircle.layer.cornerRadius = nodeHeight / 2;
                view.addSubview(goalCircle);
            }
        } else {
            proportion = highScore != 0 ? min(CGFloat(points)/CGFloat(highScore), 1) : 0;
        }
        
        let newWidth = proportion * width;
        
        let clearBar = UIView(frame: CGRect(x: 0, y: posY, width: width, height: barHeight));
        clearBar.backgroundColor = UIColor(white: 0.5, alpha: 0.5);
        clearBar.layer.cornerRadius = barHeight / 2;
        view.addSubview(clearBar);
        
        let greenBar = UIView(frame: CGRect(x: 0, y: posY, width: newWidth, height: barHeight));
        greenBar.backgroundColor = Utility.colorFromHexString("#76C043");
        greenBar.layer.cornerRadius = barHeight / 2;
        
        view.addSubview(greenBar);
    }

    func getUserRank(isTeam: Bool) -> String {
        if (isTeam) {
            let gravityTuple = Utility.getTeamGravityBoard(challenge);
            let teamGravityBoard = gravityTuple.0;
            let teamRanks = gravityTuple.1;
            
            let highScore = challenge.teamHighScore;
            for index in 0...teamGravityBoard.count - 1 {
                let name = teamGravityBoard[index].name;
                if (name == challenge.participant.team.name) {
                    return Utility.getRankSuffix(String(teamRanks[index]));
                }
            }
        } else {
            let gravityBoard = challenge.gravityBoard;
            if (gravityBoard != nil && gravityBoard.count > 0) {
                for index in 0...gravityBoard.count - 1 {
                    if (gravityBoard[index].participant.url == challenge.participant.url) {
                        return Utility.getRankSuffix(gravityBoard[index].place!);
                    }
                }
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
    
    func changePage(page: Int) {
        moveGreenBar(page);
        var frame = UIScreen.mainScreen().bounds;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
        currentPage = page;
    }
    
    func goBack(sender: AnyObject!) {
        isLeaving = true;
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
                cell = ChallengeLeaderboardRow.instanceFromNib(CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 40),challenge: challenge, participant: individualLeaderboardParticipants[index], place: String(index + 1));
                if (challenge.participant != nil && individualLeaderboardParticipants[index].url == challenge.participant.url) {
                    cell.backgroundColor = Utility.colorFromHexString("#d5ffb8");
                }
            } else {
                cell = ChallengeLeaderboardRow.instanceFromNib(CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 40), challenge: challenge, team: teamLeaderboardParticipants[index], index: index);
                if (challenge.participant != nil && teamLeaderboardParticipants[index].name == challenge.participant.team.name) {
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
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 200));
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
        let nibs = Utility.getChallengeViews(challenge, frame: cell.frame, isComplex: true);
        if (isIndividualProgress) {
            cell.addSubview(nibs[individualGoalViewIndex]);
        } else {
            cell.addSubview(nibs[teamGoalViewIndex])
        }
        cell.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        return cell;
    }
    
    func createProgressLegendRow(index: Int) -> UITableViewCell {
        let winConditions = isIndividualProgress ? individualGoalWinConditions : teamGoalWinConditions;
        return ChallengeProgressLegendRow.instanceFromNib(winConditions[winConditions.count - index - 1], userPoints: challenge.participant.units,  metric: challenge.abbrMetric, index: index + 1);
    }
    
    func getChatterRowHeight(index: Int) -> CGFloat {
        return ChallengeDetailsChatterRow.heightForIndex(challengeChatterComments[index]);
    }
    
    func createChatterTable(index: Int) -> UITableViewCell {
        let chatter = challengeChatterComments[index];
        let cell = ChallengeDetailsChatterRow.instanceFromNib(chatter.comment, participant: chatter.participant, timeSincePosted: chatter.timeSincePosted, isYou: chatter.participant.url == challenge.participant.url, isTeam: challenge.winConditions[0].winnerType == "team");
        cell.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        return cell;
    }

    func sendUserChatter(chatter: String) {
        Flurry.logEvent("ChatterSent");
        let userId = !HigiApi.EARNDIT_DEV ? SessionData.Instance.user.userId : "rQIpgKhmd0qObDSr5SkHbw";
        var contents = NSMutableDictionary();
        contents.setObject(userId, forKey: "userId");
        contents.setObject(chatter, forKey: "comment");
        HigiApi().sendPost(challenge.commentsUrl, parameters: contents, success: {operation, responseObject in
            self.addPlaceholderChatter(chatter);
            self.refreshChatter();
//            ApiUtility.retrieveChallenges(self.refreshChallenge);
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