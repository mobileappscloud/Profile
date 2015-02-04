import Foundation

class ChallengeInvitationView: UIView {
    
    @IBOutlet var inviter: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var starting: UILabel!
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
        let invitationView = UINib(nibName: "ChallengeInvitation", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeInvitationView;

        //we can just grab the first one bcuz win conditions prioritized by API
        let winCondition = challenge.winConditions[0];
        
        invitationView.goal.text = winCondition.goal.type == "most_points" ? "Most points" : "Threshold reached";
        invitationView.type.text = goalTypeDisplayHelper(winCondition.goal.type, winnerType: winCondition.winnerType);
        invitationView.prize.text = winCondition.prizeName != nil ? winCondition.prizeName : "Coming soon!";
        invitationView.participantCount.text = String(challenge.participantsCount)
        invitationView.starting.text = startsInDisplayHelper(challenge.startDate);
        invitationView.dateRange.text = dateRangeDisplayHelper(challenge.startDate, endDate: challenge.endDate?);
        //unicode values must be set here
        invitationView.calendarIcon.text = "\u{f073}";
        invitationView.participantIcon.text = "\u{f007}";

        return invitationView;
    }
    
    class func goalTypeDisplayHelper(goalType: String, winnerType: String) -> String {
        var firstPart = goalType == "individual" ? "Individual" : "Team";
        var secondPart = winnerType == "most_points" ? "Points Challenge" : "Goal Challenge";
        return firstPart + " " + secondPart;
    }
    
    class func startsInDisplayHelper(startDate: NSDate) -> String {
        var days = 0;
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
            formatter.dateFormat = "MMM d, ''yy";
            dateRange = "\(formatter.stringFromDate(startDate)) - \(formatter.stringFromDate(endDate!))";
        } else {
            dateRange = "Never ends!";
        }
        return dateRange;
    }
}