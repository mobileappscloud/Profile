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
    
    var scrollOffset = 0;
    
    func setChallengeName(name: String) {
        challengeName = name;
    }
    
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
        }
        
        populateHeader();
        
        populateScrollView();
        
        populateTabButtons();

    }
    
    func populateHeader() {
        if (challenge.participant != nil) {
            let participant = challenge.participant!;
            participantAvatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            participantPoints.text = "\(Int(participant.units)) pts";
            participantPlace.text = getUserRank();
            setProgressBar(participantProgress, points: Int(participant.units), highScore: challenge.highScore);
        } else {
            participantAvatar.hidden = true;
            participantPoints.hidden = true;
            participantPlace.hidden = true;
            participantProgress.hidden = true;
        }
//
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
        
        selectedGreenBar.frame = CGRect(x: 0, y: buttonContainer.frame.size.height - 4, width: buttonWidth, height: 4);
        selectedGreenBar.setNeedsDisplay();
        
        for index in 0...buttonText.count - 1 {
            var image = UIImage(named: buttonIcons[index]) as UIImage!;
            image.drawInRect(CGRect(x: 0, y: 0, width: 30, height: 30));
            var button = UIButton.buttonWithType(UIButtonType.System) as UIButton
            button.frame = CGRect(x: buttonWidth * CGFloat(index), y: 0, width: buttonWidth, height: height);
            button.backgroundColor = UIColor.lightGrayColor();
            button.setBackgroundImage(image, forState: UIControlState.Normal);
            button.setTitle(buttonText[index], forState: UIControlState.Normal);
            button.titleLabel?.font = UIFont.systemFontOfSize(10);
            button.tintColor = UIColor.darkGrayColor();
            button.tag = index;
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
    
    func populateScrollView() {
        scrollView.delegate = self;
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
    }
    
    func addTableView(page: Int) -> UITableView {
        let viewWidth = scrollView.frame.size.width;
        let viewHeight:CGFloat = scrollView.frame.size.height;
        
        let table = UITableView(frame: CGRect(x: CGFloat(page) * viewWidth, y: 0, width: viewWidth, height: viewHeight));
        table.dataSource = self;
        table.delegate = self;
        table.separatorStyle = UITableViewCellSeparatorStyle.None;
        table.backgroundColor = page % 2 == 0 ? UIColor.grayColor() : UIColor.blackColor();
        table.scrollEnabled = true;
        
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
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return buttonContainerOriginY + buttonContainer.frame.size.height;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == leaderBoardTable) {
            return min(50,challenge.participantsCount);
        }
        return 20;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView == leaderBoardTable) {
            var cell = tableView.dequeueReusableCellWithIdentifier("ChallengeLeaderboardRow") as ChallengeLeaderboardRow!;
            if (cell == nil) {
                var a = challenge.participants;
                var i = indexPath.row;
                cell = ChallengeLeaderboardRow.instanceFromNib(challenge, participant: challenge.participants[indexPath.row], index: indexPath.row);
            }
            return cell;
        } else {
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "");
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateScroll();
    }
    
    var lastScrollY:CGFloat = 0;
    func updateScroll() {
        var headerXOffset:CGFloat = 50;
        var currentTable = tables[currentPage];
        var scrollY = currentTable.contentOffset.y;
        
        if (scrollY < lastScrollY) {
            var t = 0;
        }
        lastScrollY = scrollY;
        if (scrollY >= 0) {
            if (scrollY >= headerContainerHeight - minHeaderHeightThreshold) {
                headerContainer.frame.origin.y = minHeaderHeightThreshold - headerContainerHeight;
                buttonContainer.frame.origin.y = minHeaderHeightThreshold - 1;
//
//                var t1 = minHeaderHeightThreshold - headerContainerHeight;
//                var t2 = headerContainer.frame.origin.y;
            } else {
                participantPlace.frame.origin.x = headerPlaceOriginX + (scrollY / headerXOffset);
                participantProgress.frame.origin.x = headerProgressOriginX + (scrollY / headerXOffset);
 
                var xOffset = min(scrollY * (headerXOffset / ((headerContainerHeight - minHeaderHeightThreshold) / 2)),50);
                participantAvatar.frame = CGRect(x: headerAvatarOriginX + xOffset, y: participantAvatar.frame.origin.y, width: 30, height: 30);
                participantPlace.frame = CGRect(x: headerPlaceOriginX + xOffset, y: participantPlace.frame.origin.y, width: 58, height: 25);
                participantName.frame = CGRect(x: headerPlaceOriginX + xOffset, y: participantName.frame.origin.y, width: 162, height: 16);
                participantProgress.frame = CGRect(x: headerProgressOriginX + xOffset, y: participantPoints.frame.origin.y, width: headerProgressOriginWidth - xOffset, height: 15);

                headerContainer.frame.origin.y = -scrollY;
                buttonContainer.frame.origin.y = buttonContainerOriginY - scrollY;
                
            }
        }
        
        for index in 0...tables.count - 1 {
            if (index != currentPage) {
                tables[index].contentOffset.y = scrollY;
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height - 10);
        self.automaticallyAdjustsScrollViewInsets = false;
        scrollView.setContentOffset(CGPointMake(0,0),animated: false);
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        currentPage = page;
        changePage(page);
    }
    
    func setProgressBar(view: UIView, points: Int, highScore: Int) {
        let width = view.frame.size.width;
        let newWidth = (CGFloat(points)/CGFloat(highScore)) * width;
        view.frame.size.width = (CGFloat(points)/CGFloat(highScore)) * width;
        
        let bar = UIView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y - 5, width: newWidth, height: 5));
        bar.backgroundColor = Utility.colorFromHexString("#76C043");
        bar.layer.cornerRadius = 2;
        view.addSubview(bar);
    }

    func changePage(page: Int) {
        moveGreenBar(page);
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
}