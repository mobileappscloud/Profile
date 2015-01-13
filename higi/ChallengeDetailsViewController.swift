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
    
    @IBOutlet weak var participantPoints: UILabel!
    @IBOutlet weak var participantProgress: UIView!
    @IBOutlet weak var challengeTitle: UILabel!
    @IBOutlet weak var challengeAvatar: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
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
    }
    
    func populateTabButtons() {
        var buttons:[UILabel] = [];
    
        var containerYValue = buttonContainer.frame.origin.y;
        
        var buttonText:[String] = [];
        if (displayLeaderBoardTab) {
            buttonText.append("Leaderboard");
        }
        if (displayProgressTab) {
            buttonText.append("Progress");
        }
        buttonText.append("Details");
        buttonText.append("Chatter");
        
        var height:CGFloat = buttonContainer.frame.size.height;
        var width:CGFloat = buttonContainer.frame.size.width / CGFloat(buttonText.count);
        
        var buttonIcons:[UIImageView] = [];
        for index in 0...buttonText.count - 1 {
            var button = UILabel(frame: CGRect(x: width * CGFloat(index), y: 0, width: width, height: height));
            button.text = buttonText[index];
            button.font.fontWithSize(5);
            button.backgroundColor = UIColor.blueColor();
            button.textAlignment = NSTextAlignment.Center;
//            var icon = UIImageView();
//            icon.setImage
//            button.addSubview(icon);
            buttonContainer.addSubview(button);
        }
    }
    func populateScrollView() {
        
        scrollView.delegate = self;
        scrollView.contentSize = contentView.frame.size;
        
        var table:UITableView;
        for index in 0...3 {
            if (index == 0) {
                if (displayLeaderBoardTab) {
                    leaderBoardTable = addTableView(totalPages);
                    scrollView.addSubview(leaderBoardTable);
                    totalPages++;
                }
            } else if (index == 1) {
                if (displayProgressTab) {
                    progressTable = addTableView(totalPages);
                    scrollView.addSubview(progressTable);
                    totalPages++;
                }
            } else if (index == 2) {
                detailsTable = addTableView(totalPages);
                scrollView.addSubview(detailsTable);
                totalPages++;
            } else if (index == 3) {
                chatterTable = addTableView(totalPages);
                scrollView.addSubview(chatterTable);
                totalPages++;
            }
        }
    }
    
    func addTableView(page: Int) -> UITableView {
        let viewWidth = scrollView.frame.size.width;
        let viewHeight:CGFloat = 1800;
        
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
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "");
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateScroll();
    }
    
    func updateScroll() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height + 300);
        scrollView.setContentOffset(CGPointMake(0,0),animated: false);
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        changePage(page);
    }
    
    func changePage(page: Int) {
        var frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
}