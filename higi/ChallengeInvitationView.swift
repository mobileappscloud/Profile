import Foundation

class ChallengeInvitationView: UIView {
    
    @IBOutlet var inviter: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var starting: UILabel!
    @IBOutlet weak var typeTitle: UILabel! {
        didSet {
            typeTitle.text = NSLocalizedString("CHALLENGE_INVITATION_VIEW_CHALLENGE_TYPE_TITLE", comment: "Title to display for a challenge type.");
        }
    }
    @IBOutlet weak var goalTitle: UILabel! {
        didSet {
            goalTitle.text = NSLocalizedString("CHALLENGE_INVITATION_VIEW_CHALLENGE_GOAL_TITLE", comment: "Title to display for a challenge goal.");
        }
    }
    @IBOutlet weak var prizeTitle: UILabel!{
        didSet {
            prizeTitle.text = NSLocalizedString("CHALLENGE_INVITATION_VIEW_CHALLENGE_PRIZE_TITLE", comment: "Title to display for a challenge prize.");
        }
    }
    @IBOutlet var type: UILabel!
    @IBOutlet var goal: UILabel!
    @IBOutlet var prize: UILabel!
    @IBOutlet var dateRange: UILabel!
    @IBOutlet var participantCount: UILabel!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var challengeLogo: UIImageView!
    @IBOutlet var startingIcon: UIImageView!
    @IBOutlet var join: UILabel!
    @IBOutlet var calendarIcon: UILabel!;
    @IBOutlet var participantIcon: UILabel!;
    
    class func instanceFromNib(challenge: HigiChallenge) -> ChallengeInvitationView {
        let invitationView = UINib(nibName: "ChallengeInvitation", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChallengeInvitationView;

        //we can just grab the first one bcuz win conditions prioritized by API
        let winCondition = challenge.winConditions[0];
        
        let pointsString = NSLocalizedString("CHALLENGE_INVITATION_VIEW_GOAL_TEXT_MOST_POINTS", comment: "Text to display if a challenge goal type is to accrue the most points.");
        let thresholdString = NSLocalizedString("CHALLENGE_INVITATION_VIEW_GOAL_TEXT_THRESHOLD", comment: "Text to display if a challenge goal type is to reach a threshold.");
        invitationView.goal.text = winCondition.goal.type == "most_points" ? pointsString : thresholdString;
        
        invitationView.type.text = goalTypeDisplayHelper(winCondition.goal.type as String, winnerType: winCondition.winnerType as String);
        invitationView.prize.text = winCondition.prizeName != nil ? winCondition.prizeName as String : "No prize";
        invitationView.participantCount.text = String(challenge.participantsCount);
        invitationView.starting.text = startsInDisplayHelper(challenge.startDate);
        invitationView.dateRange.text = dateRangeDisplayHelper(challenge.startDate, endDate: challenge.endDate);
        //unicode values must be set here
        invitationView.calendarIcon.text = "\u{f073}";
        invitationView.participantIcon.text = "\u{f007}";

        return invitationView;
    }
    
    class func goalTypeDisplayHelper(goalType: String, winnerType: String) -> String {
        let individualWinner = NSLocalizedString("CHALLENGE_INVITATION_VIEW_GOAL_TYPE_WINNER_INDIVIDUAL", comment: "Text to display for a challenge goal where the winner is an individual.");
        let teamWinner = NSLocalizedString("CHALLENGE_INVITATION_VIEW_GOAL_TYPE_WINNER_TEAM", comment: "Text to display for a challenge goal where the winner is a team.");
        let firstPart = winnerType == "individual" ? individualWinner : teamWinner;
        
        let pointsGoal = NSLocalizedString("CHALLENGE_INVITATION_VIEW_GOAL_TYPE_POINTS", comment: "Text to display if a challenge goal type is to accrue the most points.");
        let challengeGoal = NSLocalizedString("CHALLENGE_INVITATION_VIEW_GOAL_TYPE_CHALLENGE", comment: "Text to display if a challenge goal type is to reach a threshold.");
        let secondPart = goalType == "most_points" ? "Points Challenge" : "Goal Challenge";
        
        return firstPart + " " + secondPart;
    }
    
    // TODO: l10n verify copy and use pluralization dict
    class func startsInDisplayHelper(startDate: NSDate) -> String {
        var dateDisplay:String!
        if (Int(startDate.timeIntervalSinceNow) > 0) {
            let days = Int(startDate.timeIntervalSinceNow / 60 / 60 / 24) + 1;
            let s = days == 1 ? "" : "s";
            dateDisplay = "Starts in \(days) day\(s)";
        } else if (Int(startDate.timeIntervalSinceNow) < 0){
            let days = Int(startDate.timeIntervalSinceNow / 60 / 60 / 24) * -1 + 1;
            let s = days == 1 ? "" : "s";
            dateDisplay = "Started \(days) day\(s) ago";
        } else {
            dateDisplay = "Started today";
        }
        return dateDisplay;
    }
    
    class func dateRangeDisplayHelper(startDate: NSDate, endDate: NSDate?) -> String {
        var dateRange = "";
        if (endDate != nil) {
            let formatter = NSDateFormatter();
            let dateFormat = NSLocalizedString("CHALLENGE_INVITATION_VIEW_DATE_RANGE_DATE_FORMAT", comment: "Format for dates displayed on challenge invitation date range text.");
            formatter.dateFormat = dateFormat;
            dateRange = "\(formatter.stringFromDate(startDate)) - \(formatter.stringFromDate(endDate!))";
        } else {
            dateRange = NSLocalizedString("CHALLENGE_INVITATION_VIEW_DATE_RANGE_NO_END_DATE", comment: "Text to display on a challenge invitation if there is no end date.");
        }
        return dateRange;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        participantCount.sizeToFit();
    }
}