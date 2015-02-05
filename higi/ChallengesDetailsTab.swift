import Foundation

class ChallengeDetailsTab: UITableView, UIAlertViewDelegate {
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var durationText: UILabel!
    @IBOutlet weak var typeText: UILabel!
    @IBOutlet weak var teamCountText: UILabel!
    @IBOutlet weak var individualCountText: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var teamCountView: UIView!
    @IBOutlet weak var participantIcon: UILabel!
    @IBOutlet weak var participantCountView: UIView!
    
    @IBOutlet weak var participantRowView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews();
        descriptionText.sizeToFit();
        descriptionText.center = descriptionView.center;
        descriptionText.textAlignment = NSTextAlignment.Center;
        
        individualCountText.sizeToFit();
        teamCountText.sizeToFit();
    }
    
    @IBOutlet weak var teamCountSubview: UIView!
    @IBOutlet weak var participantCountSubView: UIView!
    class func instanceFromNib(challenge: HigiChallenge) -> ChallengeDetailsTab {
        let tab = UINib(nibName: "ChallengeDetailsTab", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsTab;
        
        let firstWinCondition = challenge.winConditions[0];
        
        tab.descriptionText.text = challenge.shortDescription;
        if (challenge.endDate != nil) {
            tab.durationText.text = setDateRangeHelper(challenge.startDate, endDate: challenge.endDate);
        } else {
            tab.durationText.text = "Never ends!";
        }
        tab.typeText.text = "\(goalTypeDisplayHelper(firstWinCondition.goal.type.description, winnerType: firstWinCondition.winnerType)). \(limitDisplayHelper(challenge.dailyLimit, metric: challenge.metric))";
        tab.individualCountText.text = String(challenge.participantsCount);
        
        let teamCount = challenge.teams != nil ? challenge.teams.count : 0;
        if (teamCount > 0) {
            tab.teamCountText.text = String(challenge.teams.count);
        } else {
            tab.teamCountView.removeFromSuperview();
            tab.participantCountView.center = tab.participantRowView.center;
        }

        tab.participantIcon.text = "\u{f007}"
        return tab;
    }
    
    class func setPrize() {
        
    }
    
    class func setDateRangeHelper(startDate: NSDate, endDate: NSDate) -> String {
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM. dd, YYYY"
        return "\(dateFormatter.stringFromDate(startDate)) - \(dateFormatter.stringFromDate(endDate))";
    }
    
    class func goalTypeDisplayHelper(goalType: String, winnerType: String) -> String {
        var firstPart = winnerType == "individual" ? "Individual" : "Team";
        var secondPart = goalType == "most_points" ? "Points Challenge" : "Goal Challenge";
        return firstPart + " " + secondPart;
    }
    
    class func durationHelper(startDate: NSDate, endDate: NSDate?) -> String {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM. dd, YYYY"
        if (endDate != nil) {
            return "\(dateFormatter.stringFromDate(startDate)) - \(dateFormatter.stringFromDate(endDate!))";
        } else {
            return "\(dateFormatter.stringFromDate(startDate)) - No end date";
        }
    }
    
    class func limitDisplayHelper(limit: Int, metric: String) -> String {
        if (limit > 0) {
            return "Limit of \(limit) \(metric) per day.";
        } else {
            return "Unlimited \(metric) per day.";
        }
    }
    
//    class func addParticipantRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
//        let individuals = challenge.participantsCount;
//        let teams = challenge.teams != nil ? challenge.teams.count : 0;
//        var viewWidth = row.frame.size.width;
//        let viewHeight = row.frame.size.height;
//        
//        if (teams > 0) {
//            viewWidth = viewWidth/2;
//            let teamView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight));
//            
//            let teamIcon = ChallengeDetailsIcons.instanceFromNib(teams, isTeam: true);
//            teamIcon.center = teamView.center;
//            
//            row.addSubview(teamIcon);
//        }
//        
//        let w = row.frame.size.width - viewWidth
//        let individualView = UIView(frame: CGRect(x: row.frame.size.width - viewWidth, y: 0, width: viewWidth, height: viewHeight));
//        
//        let individualIcon = ChallengeDetailsIcons.instanceFromNib(individuals, isTeam: false);
//        individualIcon.center = individualView.center;
//        
//        row.addSubview(individualIcon);
//        row.sizeToFit();
//        return row;
//    }
//    
//    class func addTermsRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
//        let button = UIView(frame: CGRect(x: 0, y: 0, width: row.frame.size.width, height: 50));
//        button.backgroundColor = UIColor.lightGrayColor();
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: row.frame.size.width, height: 50));
//        label.center = button.center;
//        label.text = "Terms and Conditions";
//        label.textColor = UIColor.whiteColor();
//        label.font = UIFont.systemFontOfSize(12);
//        label.textAlignment = NSTextAlignment.Center;
//        
//        let tapGestureRecognizer = UITapGestureRecognizer();
//        tapGestureRecognizer.addTarget(row, action: "showTerms:");
//        row.addGestureRecognizer(tapGestureRecognizer);
//        
//        button.addSubview(label);
//        row.addSubview(button);
//        return row;
//    }
//    
//    class func addPrizesRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
//        var yPos:CGFloat = 0;
//        let view = UIView(frame: CGRect(x: 0, y: 30, width: 0, height: 80 * CGFloat(challenge.winConditions.count)));
//        for winCondition in challenge.winConditions {
//            let prize = ChallengeDetailsPrize.instanceFromNib(winCondition);
//            prize.frame = CGRect(x: 0, y: yPos, width: row.frame.size.width, height: 80);
//            view.addSubview(prize);
//            yPos += 80;
//        }
//        row.addSubview(view);
//        return row;
//    }
//    
    func showTerms(sender: AnyObject!) {
        UIAlertView(title: "Terms and Conditions", message: "Terms and conditions placeholder", delegate: self, cancelButtonTitle: "Reject", otherButtonTitles: "Accept").show();
    }
}