import Foundation

class CompetitiveChallengeView: UIView {

    @IBOutlet var firstPositionAvatar: UIImageView!
    @IBOutlet var secondPositionAvatar: UIImageView!
    @IBOutlet var thirdPositionAvatar: UIImageView!
    @IBOutlet var firstPositionRank: UILabel!
    @IBOutlet var secondPositionRank: UILabel!
    @IBOutlet var thirdPositionRank: UILabel!
    @IBOutlet var firstPositionName: UILabel!
    @IBOutlet var secondPositionName: UILabel!
    @IBOutlet var thirdPositionName: UILabel!
    @IBOutlet var firstPositionProgressBar: UIView!
    @IBOutlet var secondPositionProgressBar: UIView!
    @IBOutlet var thirdPositionProgressBar: UIView!
    @IBOutlet var firstPositionPoints: UILabel!
    @IBOutlet var secondPositionPoints: UILabel!
    @IBOutlet var thirdPositionPoints: UILabel!
    
    class func instanceFromNib(challenge: HigiChallenge, winConditions: [ChallengeWinCondition]) -> CompetitiveChallengeView {
        let competitiveView = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView;
        
        if (winConditions[0].winnerType == "individual") {
            let gravityBoard = challenge.gravityBoard;
            for (var i = 0; i < gravityBoard.count; i++) {
                if (i == 0) {
                    competitiveView.firstPositionName.text = gravityBoard[i].participant.displayName;
                    competitiveView.firstPositionPoints.text = "\(Int(gravityBoard[i].participant.units)) pts";
                    competitiveView.firstPositionRank.text = getRankSuffix(gravityBoard[i].place);
                    competitiveView.firstPositionAvatar.setImageWithURL(Utility.loadImageFromUrl(gravityBoard[i].participant.imageUrl));
                } else if (i == 1) {
                    competitiveView.secondPositionName.text = gravityBoard[i].participant.displayName;
                    competitiveView.secondPositionPoints.text = "\(Int(gravityBoard[i].participant.units)) pts";
                    competitiveView.secondPositionRank.text = getRankSuffix(gravityBoard[i].place);
                    competitiveView.secondPositionAvatar.setImageWithURL(Utility.loadImageFromUrl(gravityBoard[i].participant.imageUrl));
                } else {
                    competitiveView.thirdPositionName.text = gravityBoard[i].participant.displayName
                    competitiveView.thirdPositionPoints.text = "\(Int(gravityBoard[i].participant.units)) pts";
                    competitiveView.thirdPositionRank.text = getRankSuffix(gravityBoard[i].place);
                    competitiveView.thirdPositionAvatar.setImageWithURL(Utility.loadImageFromUrl(gravityBoard[i].participant.imageUrl));
                }
            }
        } else { // == "team"
            let gravityBoard = challenge.teams;
        }
        return competitiveView;
    }
    
    class func getRankSuffix(rank: NSString) -> String {
        if ( rank == "11" || rank == "12" || rank == "13") {
            return rank + "th"
        }
        
        let last = rank.substringFromIndex(rank.length - 1)
        switch(last) {
        case "1":
            return rank + "st"
        case "2":
            return rank + "nd"
        case "3":
            return rank + "rd"
        default:
            return rank + "th"
        }
    }
}