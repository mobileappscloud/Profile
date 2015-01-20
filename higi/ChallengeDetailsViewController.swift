//
//  ChallengeDetailsViewController.swift
//  higi
//
//  Created by Jack Miller on 1/9/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

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
    
    var displayLeaderBoardTab = false;
    var displayProgressTab = false;
    var hasTeamComponent = false;
    var hasIndividualComponent = false;
    var isIndividualLeaderboard = true;
    var isIndividualProgress = true;
    
    @IBOutlet weak var selectedGreenBar: UIView!
    var leaderBoardTable: UITableView!;
    var progressTable: UITableView!;
    var detailsTable: UITableView!;
    var chatterTable: UITableView!;

    var totalPages = 0;
    var currentPage = 0;
    var tables:[UITableView] = [];
    
    var minHeaderHeightThreshold:CGFloat = 0;
    var headerContainerHeight:CGFloat = 0;
    var buttonContainerOriginY:CGFloat = 0;
    var headerAvatarOriginX:CGFloat = 0;
    var headerPlaceOriginX:CGFloat = 0;
    var headerProgressOriginX:CGFloat = 0;
    var headerProgressOriginWidth:CGFloat = 0;
    var headerPointsOriginX:CGFloat = 0;
    
    let toggleButtonHeight:CGFloat = 60;
    var scrollOffset = 0;
    
    var shouldScroll = true;
    var toggleButtons:[UIButton] = [];
    
    let gestureRecognizer = UITapGestureRecognizer();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        (self.navigationController as MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        
        var session = SessionController.Instance;
        
        for thisChallenge:HigiChallenge in session.challenges {
            if (thisChallenge.name == challengeName) {
                challenge = thisChallenge;
                break;
            }
        }
        
        for winCondition in challenge.winConditions {
            if (winCondition.goal.type == "threshold_reached") {
                displayProgressTab = true;
            } else if (winCondition.goal.type == "most_points" || winCondition.goal.type == "unit_goal_reached") {
                displayLeaderBoardTab = true;
            }
            
            if (winCondition.winnerType == "individual") {
                hasIndividualComponent = true;
            } else if (winCondition.winnerType == "team") {
                hasTeamComponent = true;
            }
        }
        
        populateHeader();
        
        populateScrollViewWithTables();
        
        populateTabButtons();
        
        gestureRecognizer.addTarget(self, action: "toggleButton:");
        
        if (displayProgressTab && hasIndividualComponent && hasTeamComponent) {
            addToggleButtons(leaderBoardTable);
        } else if (false) {
            
        }
    }
    
    func addToggleButtons(table: UITableView) {
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
            button.addTarget(self, action: "toggleButton:", forControlEvents: UIControlEvents.TouchUpInside);
            button.enabled = true;

            toggleButtons.append(button);
            header.addSubview(button);
        }
        header.addTarget(self, action: "toggleButton:", forControlEvents: UIControlEvents.TouchUpInside);
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
        
        minHeaderHeightThreshold = 67;
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
        if (displayLeaderBoardTab) {
            buttonText.append("Leaderboard");
            buttonIcons.append("ui_leaderboards.png");
        }
        if (displayProgressTab) {
            buttonText.append("Progress");
            buttonIcons.append("ui_progress.png");
        }
        buttonText.append("Details");
        buttonIcons.append("ui_details.png");
        buttonText.append("Chatter");
        buttonIcons.append("ui_chatter.png");
        
        var height:CGFloat = buttonContainer.frame.size.height;
        let buttonWidth = buttonContainer.frame.size.width / CGFloat(buttonText.count)
        
        selectedGreenBar.frame = CGRect(x: 0, y: -4, width: buttonWidth, height: 4);
        selectedGreenBar.setNeedsDisplay();
        
        for index in 0...buttonText.count - 1 {
            var image = UIImage(named: buttonIcons[index]) as UIImage!;
            
            image.drawInRect(CGRect(x: 0, y: 0, width: 10, height: 10));
            var button = UIButton.buttonWithType(UIButtonType.System) as UIButton
            button.frame = CGRect(x: buttonWidth * CGFloat(index), y: 0, width: buttonWidth, height: height);
            button.backgroundColor = Utility.colorFromHexString("#FDFDFD");
            button.setImage(image, forState: UIControlState.Normal);
            button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15);
            button.setTitle(buttonText[index], forState: UIControlState.Normal);
            button.titleLabel?.font = UIFont.systemFontOfSize(12);
            button.tintColor = UIColor.darkGrayColor();
            button.tag = index;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
            button.contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom;
            button.contentEdgeInsets.bottom = 10;
            button.addTarget(self, action: "selectButton:", forControlEvents:UIControlEvents.TouchUpInside);
            buttonContainer.addSubview(button);
        }
    }
    
    func selectButton(sender: UIButton!) {
        changePage(sender.tag);
    }
    
    func moveGreenBar(page: Int) {
        selectedGreenBar.frame.origin.x = CGFloat(page) * selectedGreenBar.frame.size.width;
    }
    
    func toggleButton(sender: AnyObject) {
        for button in toggleButtons {
            button.selected = !button.selected;
        }
        isIndividualLeaderboard = toggleButtons[0].selected;
        leaderBoardTable.reloadData();
    }
    
    func populateScrollViewWithTables() {
        var table:UITableView;
        if (displayLeaderBoardTab) {
            leaderBoardTable = addTableView(totalPages);
            scrollView.addSubview(leaderBoardTable);
            tables.append(leaderBoardTable);
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
        view.addGestureRecognizer(gestureRecognizer);
        return view;
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (displayLeaderBoardTab && tableView == leaderBoardTable) {
            return buttonContainerOriginY + buttonContainer.frame.size.height + 10;
        }
        return buttonContainerOriginY + buttonContainer.frame.size.height;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (displayLeaderBoardTab && tableView == leaderBoardTable) {
            return isIndividualLeaderboard ? min(50,challenge.participantsCount) : min(50, challenge.teams.count);
        } else if (displayProgressTab && tableView == progressTable) {
            return 1;
        }
        return 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (displayLeaderBoardTab && tableView == leaderBoardTable) {
            //var cell = tableView.dequeueReusableCellWithIdentifier("ChallengeLeaderboardRow") as ChallengeLeaderboardRow!;
            //if (cell == nil) {
                var cell = ChallengeLeaderboardRow.instanceFromNib(challenge, index: indexPath.row, isIndividual: isIndividualLeaderboard);
            //}
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (shouldScroll) {
            updateScroll();
        }
    }
    
    var lastScrollY:CGFloat = 0;
    func updateScroll() {
        var headerXOffset:CGFloat = 50;
        var currentTable = tables[currentPage];
        var scrollY = currentTable.contentOffset.y;
        
        //@todo for some reason there is a hiccup in scrolling at 34 and 78 that resets scroll to 0
        if (scrollY == 34 || scrollY == 78) {
            var t = 0;
        }
        
        lastScrollY = headerContainer.frame.origin.y;
//        if (scrollY >= 0) {
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
//        }
        
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
}