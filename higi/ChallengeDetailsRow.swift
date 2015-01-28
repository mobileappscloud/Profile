import Foundation

class ChallengeDetailsRow: UITableViewCell, UIAlertViewDelegate {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var desc: UILabel!
    struct DetailRowConstants {
        static let descriptionIndex = 0;
        static let durationIndex = 1;
        static let goalIndex = 2;
        static let typeIndex = 3;
        static let participantsIndex = 4;
        static let prizesIndex = 5;
        static let termsIndex = 6;
        
        static let prizeRowHeight:CGFloat = 80;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        desc.sizeToFit();
    }
    
    class func instanceFromNib(challenge: HigiChallenge, index: Int) -> ChallengeDetailsRow {
        var row = UINib(nibName: "ChallengeDetailsRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsRow;
        
        row.title.text = getDetailRowTitle(index);
        row.desc.text = getDetailRowDescription(challenge, index: index);
        
        if (index == DetailRowConstants.descriptionIndex) {
            row = addDescriptionRowLogic(row, challenge: challenge);
        } else if (index == DetailRowConstants.participantsIndex) {
            row = addParticipantRowLogic(row, challenge: challenge);
        } else if (index == DetailRowConstants.termsIndex) {
            row = addTermsRowLogic(row, challenge: challenge);
        } else if (index == DetailRowConstants.prizesIndex) {
            row = addPrizesRowLogic(row, challenge: challenge);
        }
        
        if (index % 2 == 0) {
            row.backgroundColor = Utility.colorFromHexString("#F4F4F4");
        }
        
        return row;
    }
    
    class func heightForIndex(challenge: HigiChallenge, index:Int, width: CGFloat, margin: CGFloat) -> CGFloat {
        let d = getDetailRowDescription(challenge, index: index);
        let a = Utility.heightForTextView(width, text: getDetailRowDescription(challenge, index: index), fontSize: 11, margin: margin);
        if (index == DetailRowConstants.participantsIndex) {
            return 80;
        } else if (index == DetailRowConstants.prizesIndex) {
            return 80 * CGFloat(challenge.winConditions.count);
        } else {
            return Utility.heightForTextView(width, text: getDetailRowDescription(challenge, index: index), fontSize: 11, margin: margin);
        }
    }
    
    class func getDetailRowTitle(index: Int) -> String {
        var title = "";
        switch index {
        case DetailRowConstants.descriptionIndex:
            title = "Description";
        case DetailRowConstants.durationIndex:
            title = "Duration";
        case DetailRowConstants.goalIndex:
            title = "Goal";
        case DetailRowConstants.typeIndex:
            title = "Type";
        case DetailRowConstants.participantsIndex:
            title = "Participants";
        case DetailRowConstants.prizesIndex:
            title = "Prizes";
        case DetailRowConstants.termsIndex:
            title = "";
        default:
            let i = 0;
        }
        return title;
    }
    
    class func getDetailRowDescription(challenge: HigiChallenge, index: Int) -> String {
        var desc = "";
        switch index {
        case DetailRowConstants.descriptionIndex:
//            desc = Utility.htmlDecodeString(challenge.shortDescription);
            desc = challenge.shortDescription;
        case DetailRowConstants.durationIndex:
            desc = durationHelper(challenge.startDate, endDate: challenge.endDate);
        case DetailRowConstants.goalIndex:
            desc = challenge.winConditions[0].description;
        case DetailRowConstants.typeIndex:
            desc = "\(goalTypeDisplayHelper(challenge.winConditions[0].goal.type, winnerType: challenge.winConditions[0].winnerType)). \(limitDisplayHelper(challenge.dailyLimit, metric: challenge.metric)) ";
        case DetailRowConstants.participantsIndex:
            desc = "";
        case DetailRowConstants.prizesIndex:
            desc = "Prizes";
        case DetailRowConstants.termsIndex:
            desc = "";
        default:
            let i = 0;
        }
        return desc;
    }
    
    class func durationHelper(startDate: NSDate, endDate: NSDate) -> String {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMM. dd, YYYY"
        return "\(dateFormatter.stringFromDate(startDate)) - \(dateFormatter.stringFromDate(endDate))";
    }
    
    class func goalTypeDisplayHelper(goalType: String, winnerType: String) -> String {
        let firstPart = goalType == "individual" ? "Individual" : "Team";
        let secondPart = winnerType == "most_points" ? "Points Challenge" : "Goal Challenge";
        return firstPart + " " + secondPart;
    }
    
    class func limitDisplayHelper(limit: Int, metric: String) -> String {
        if (limit > 0) {
            return "Limit of \(limit) \(metric) per day.";
        } else {
            return "Unlimited \(metric) per day.";
        }
    }
    class func addDescriptionRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
        return row;
    }
    
    class func addParticipantRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
        let individuals = challenge.participantsCount;
        let teams = challenge.teams != nil ? challenge.teams.count : 0;
        var viewWidth = row.frame.size.width;
        let viewHeight = row.frame.size.height;

        if (teams > 0) {
            viewWidth = viewWidth/2;
            let teamView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight));
            
            let teamIcon = ChallengeDetailsIcons.instanceFromNib(teams, isTeam: true);
            teamIcon.center = teamView.center;

            row.addSubview(teamIcon);
        }

        let w = row.frame.size.width - viewWidth
        let individualView = UIView(frame: CGRect(x: row.frame.size.width - viewWidth, y: 0, width: viewWidth, height: viewHeight));
        
        let individualIcon = ChallengeDetailsIcons.instanceFromNib(individuals, isTeam: false);
        individualIcon.center = individualView.center;
        
        row.addSubview(individualIcon);
        row.sizeToFit();
        return row;
    }
    
    class func addTermsRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
        let button = UIView(frame: CGRect(x: 0, y: 0, width: row.frame.size.width, height: 50));
        button.backgroundColor = UIColor.lightGrayColor();
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: row.frame.size.width, height: 50));
        label.center = button.center;
        label.text = "Terms and Conditions";
        label.textColor = UIColor.whiteColor();
        label.font = UIFont.systemFontOfSize(12);
        label.textAlignment = NSTextAlignment.Center;
        
        let tapGestureRecognizer = UITapGestureRecognizer();
        tapGestureRecognizer.addTarget(row, action: "showTerms:");
        row.addGestureRecognizer(tapGestureRecognizer);
        
        button.addSubview(label);
        row.addSubview(button);
        return row;
    }
    
    class func addPrizesRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
        var yPos:CGFloat = 0;
        let view = UIView(frame: CGRect(x: 0, y: 30, width: 0, height: 80 * CGFloat(challenge.winConditions.count)));
        for winCondition in challenge.winConditions {
            let prize = ChallengeDetailsPrize.instanceFromNib(winCondition);
            prize.frame = CGRect(x: 0, y: yPos, width: row.frame.size.width, height: 80);
            view.addSubview(prize);
            yPos += 80;
        }
        row.addSubview(view);
        return row;
    }
    
    func showTerms(sender: AnyObject!) {
        UIAlertView(title: "Terms and Conditions", message: "Terms and conditions placeholder", delegate: self, cancelButtonTitle: "Reject", otherButtonTitles: "Accept").show();
    }
}