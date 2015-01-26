import Foundation

class ChallengeDetailsRow: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var desc: UILabel!
    struct DetailRowConstants {
        static let descriptionIndex = 0;
        static let durationIndex = 1;
        static let goalIndex = 2;
        static let typeIndex = 3;
        static let participantsIndex = 4;
        static let prizesIndex = 5;
        static let topScoringTeamIndex = 6;
        static let termsIndex = 7;
    }
    
    class func instanceFromNib(challenge: HigiChallenge, index: Int) -> ChallengeDetailsRow {
        var row = UINib(nibName: "ChallengeDetailsRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsRow;
        
        row.title.text = getDetailRowTitle(index);
        row.desc.text = getDetailRowDescription(challenge, index: index);
        
        if (index == DetailRowConstants.participantsIndex) {
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
            title = "Terms and Conditions";
        default:
            let i = 0;
        }
        return title;
    }
    
    class func getDetailRowDescription(challenge: HigiChallenge, index: Int) -> String {
        var desc = "";
        switch index {
        case DetailRowConstants.descriptionIndex:
            desc = challenge.shortDescription;
        case DetailRowConstants.durationIndex:
            desc = durationHelper(challenge.startDate, endDate: challenge.endDate);
        case DetailRowConstants.goalIndex:
            desc = challenge.winConditions[0].description;
        case DetailRowConstants.typeIndex:
            desc = goalTypeDisplayHelper(challenge.winConditions[0].goal.type, winnerType: challenge.winConditions[0].winnerType);
        case DetailRowConstants.participantsIndex:
            desc = "";
        case DetailRowConstants.prizesIndex:
            desc = "Prizes";
        case DetailRowConstants.termsIndex:
            desc = "Terms and Conditions";
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

    class func addParticipantRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
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
////            let teamLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight));
////            teamLabel.text = "Individuals";
////            teamLabel.center = teamView.center;
////            let teamCount = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight));
////            teamCount.text = "\(challenge.participantsCount)";
////            teamCount.center = teamView.center;
////            let teamIcon = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight));
////            teamIcon.text = "\u{f0c0}";
//////            teamIcon.center = teamView.center;
////            
////            teamView.addSubview(teamLabel);
////            teamView.addSubview(teamCount);
////            teamView.addSubview(teamIcon);
//            
//            row.addSubview(teamView);
//        }
//        
//        let individualView = UIView(frame: CGRect(x: row.frame.size.width - viewWidth, y: 0, width: viewWidth, height: viewHeight));
//        
//        let individualIcon = ChallengeDetailsIcons.instanceFromNib(individuals, isTeam: false);
//        individualIcon.center = individualView.center;
//
////        let individualLabel = UILabel(frame: CGRect(x: viewWidth/2, y: viewHeight - 10, width:viewWidth, height: viewHeight));
////        individualLabel.text = "Individuals";
////        individualLabel.center = individualView.center;
////        let individualCount = UILabel(frame: CGRect(x: viewWidth/2, y: 0, width: viewWidth, height: viewHeight));
////        individualCount.text = "\(challenge.participantsCount)";
////        individualCount.center = individualView.center;
////        let personIcon = UILabel(frame: CGRect(x: viewWidth/2, y: 0, width: viewWidth, height: viewHeight));
////        personIcon.text = "\u{f007}";
////        personIcon.center = individualView.center;
////        
////        individualView.addSubview(individualLabel);
////        individualView.addSubview(individualCount);
////        individualView.addSubview(personIcon);
////        
//        
//        
//        row.addSubview(individualView);
        
        return row;
    }
    
    class func addTermsRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
        return row;
    }
    
    class func addPrizesRowLogic(row: ChallengeDetailsRow, challenge: HigiChallenge) -> ChallengeDetailsRow {
        return row;
    }
}