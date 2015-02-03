import Foundation

class ChallengeDetailsTab: UITableViewCell, UIWebViewDelegate {
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var durationText: UILabel!
    @IBOutlet weak var goalText: UILabel!
    @IBOutlet weak var typeText: UILabel!
    @IBOutlet weak var teamCountText: UILabel!
    @IBOutlet weak var individualCountText: UILabel!
    @IBOutlet weak var prizesText: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    
    class func instanceFromNib(challenge: HigiChallenge) -> ChallengeDetailsTab {
        let tab = UINib(nibName: "ChallengeDetailsTab", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsTab;
        
        let firstWinCondition = challenge.winConditions[0];
        
        tab.descriptionText.text = challenge.shortDescription;
//        let webView = UIWebView(frame: CGRect(x: 0, y: 20, width: tab.frame.size.width, height: 400));
//        webView.loadHTMLString(challenge.description, baseURL: nil);
//        tab.descriptionView.addSubview(webView);
//
        if (challenge.endDate != nil) {
            tab.durationText.text = setDateRangeHelper(challenge.startDate, endDate: challenge.endDate);
        } else {
            tab.durationText.text = "Never ends!";
        }
        tab.goalText.text = firstWinCondition.description;
        tab.typeText.text = goalTypeDisplayHelper(firstWinCondition.goal.type.description, winnerType: firstWinCondition.winnerType);
        tab.individualCountText.text = String(challenge.participantsCount);
        if (challenge.teams != nil) {
            tab.teamCountText.text = String(challenge.teams.count);
        } else {
            tab.teamCountText.text = "0";
        }
        tab.prizesText.text = firstWinCondition.prizeName;
        
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
        var firstPart = goalType == "individual" ? "Individual" : "Team";
        var secondPart = winnerType == "most_points" ? "Points Challenge" : "Goal Challenge";
        return firstPart + " " + secondPart;
    }
}