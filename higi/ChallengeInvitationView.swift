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
        let secondPart = goalType == "most_points" ? pointsGoal : challengeGoal;
        
        return firstPart + " " + secondPart;
    }
    
    class func startsInDisplayHelper(startDate: NSDate) -> String {
        var dateDisplay:String!

        let elapsedDays = NSCalendar.currentCalendar().components(.Day, fromDate: NSDate(), toDate: startDate, options: NSCalendarOptions(rawValue: 0)).day
    
        if (elapsedDays > 0) {
            let formattedDate = NSString.localizedStringWithFormat(NSLocalizedString("DAY_COUNT_SINGLE_PLURAL", comment: "Format for pluralization of days."), elapsedDays+1)
            let format = NSLocalizedString("CHALLENGE_INVITATION_VIEW_CHALLENGE_DATE_NOT_STARTED_FORMAT", comment: "Format for challenge which has not started yet.")
            dateDisplay = NSString.localizedStringWithFormat(format, formattedDate) as String
        } else if (elapsedDays < 0) {
            let formattedDate = NSString.localizedStringWithFormat(NSLocalizedString("DAY_COUNT_SINGLE_PLURAL", comment: "Format for pluralization of days."), elapsedDays+1)
            let format = NSLocalizedString("CHALLENGE_INVITATION_VIEW_CHALLENGE_DATE_ONGOING_FORMAT", comment: "Format for an ongoing challenge which has started and does not have a specific end date.")
            dateDisplay = NSString.localizedStringWithFormat(format, formattedDate) as String
        } else {
            dateDisplay = NSLocalizedString("CHALLENGE_INVITATION_VIEW_CHALLENGE_DATE_TODAY_FORMAT", comment: "Format for a challenge which started today.")
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