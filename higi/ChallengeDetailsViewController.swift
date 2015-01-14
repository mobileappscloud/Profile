//
//  ChallengeDetailsViewController.swift
//  higi
//
//  Created by Jack Miller on 1/9/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class ChallengeDetailsViewController: BaseViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
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
    @IBOutlet weak var calendarIcon: UILabel!
    @IBOutlet weak var challengeDaysLeft: UILabel!
    @IBOutlet weak var participantAvatar: UIImageView!
    @IBOutlet weak var participantPlace: UILabel!
    
    @IBOutlet weak var buttonContainer: UIView!
    var challengeName = "";
    var challenge:HigiChallenge!;
    
    var displayLeaderBoardTab = false;
    var displayProgressTab = false;
    
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
            //participantProgress = ;
        } else {
            participantAvatar.hidden = true;
            participantPoints.hidden = true;
            participantPlace.hidden = true;
            participantProgress.hidden = true;
        }
//
        challengeAvatar.setImageWithURL(Utility.loadImageFromUrl(challenge.imageUrl));
        challengeTitle.text = challenge.name;
//        challengeDaysLeft.text = daysLeftHelper();
        
        calendarIcon.text = "\u{f073}";
        
        minHeaderHeightThreshold = 50;
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
    
        var containerYValue = buttonContainer.frame.origin.y;
        
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
        var width:CGFloat = buttonContainer.frame.size.width / CGFloat(buttonText.count);
        
        for index in 0...buttonText.count - 1 {
            var image = UIImage(named: buttonIcons[index]) as UIImage!;
            image.drawInRect(CGRect(x: 0, y: 0, width: 30, height: 30));
            var button = UIButton.buttonWithType(UIButtonType.System) as UIButton
            button.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height);
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
    
    func populateScrollView() {
        
        scrollView.delegate = self;
        
        var table:UITableView;
        for index in 0...3 {
            if (index == 0) {
                if (displayLeaderBoardTab) {
                    leaderBoardTable = addTableView(totalPages);
                    scrollView.addSubview(leaderBoardTable);
                    tables.append(leaderBoardTable);
                    totalPages++;
                }
            } else if (index == 1) {
                if (displayProgressTab) {
                    progressTable = addTableView(totalPages);
                    scrollView.addSubview(progressTable);
                    tables.append(progressTable);
                    totalPages++;
                }
            } else if (index == 2) {
                detailsTable = addTableView(totalPages);
                scrollView.addSubview(detailsTable);
                tables.append(detailsTable);
                totalPages++;
            } else if (index == 3) {
                chatterTable = addTableView(totalPages);
                scrollView.addSubview(chatterTable);
                tables.append(chatterTable);
                totalPages++;
            }
        }
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
        
        var text = UILabel(frame: CGRect(x: 150, y: 400, width: 100, height: 25));
        text.text = "This is a test";
        text.textColor = UIColor.whiteColor();
        
        table.addSubview(text);
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
        return 200;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "");
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateScroll();
    }
    
    func updateScroll() {
        var headerXOffset:CGFloat = 50;
        var currentTable = tables[currentPage];
        var scrollY = currentTable.contentOffset.y;
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
                buttonContainer.frame.origin.y = buttonContainerOriginY - scrollY;
                
            }
        }
        for table in tables {
            if (table != currentTable) {
                table.contentOffset.y = min(scrollY, headerContainerHeight - minHeaderHeightThreshold);
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
    
    func changePage(page: Int) {
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
}