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
        
        //invitationView.title.text = challenge.name;
        //invitationView.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.imageUrl))
        invitationView.goal.text = winCondition.goal.type == "most_points" ? "Most points" : "Threshold reached";
        invitationView.type.text = goalTypeDisplayHelper(winCondition.goal.type, winnerType: winCondition.winnerType);
        invitationView.prize.text = winCondition.prizeName != nil ? winCondition.prizeName : "Coming soon!";
        invitationView.participantCount.text = String(challenge.participantsCount)
        
        var days:Int = 0
        var message:String!
        var startDate:NSDate? = challenge.startDate?
        var endDate:NSDate? = challenge.endDate?
        if (startDate != nil) {
            let compare:NSTimeInterval = startDate!.timeIntervalSinceNow
            
            if ( Int(compare) > 0) {
                days = Int(compare) / 60 / 60 / 24
                message = "Starts in \(days) days!"
            } else if ( Int(compare) < 0 ) {
                days = abs(Int(compare)) / 60 / 60 / 24
                message = "Started \(days) days ago!"
            } else {
                message = "Starting today!"
            }
        }
        invitationView.starting.text = message;
        
        let formatter = NSDateFormatter();
        formatter.dateFormat = "MMM d, ''yy";
        var startDateShort = formatter.stringFromDate(startDate!);
        var endDateShort = formatter.stringFromDate(endDate!);

        //unicode values must be set here
        invitationView.calendarIcon.text = "\u{f073}";
        invitationView.participantIcon.text = "\u{f007}";

        invitationView.dateRange.text = "\(startDateShort) - \(endDateShort)";
        
        return invitationView;
    }
    
    class func goalTypeDisplayHelper(goalType: String, winnerType: String) -> String {
        //either individual or team, only
        var firstPart = goalType == "individual" ? "Individual" : "Team";
        var secondPart = winnerType == "most_points" ? "Points Challenge" : "Goal Challenge";
        return firstPart + " " + secondPart;
        
    }
}