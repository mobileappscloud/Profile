import Foundation

class CompetitiveChallengeView: ChallengeView, UIScrollViewDelegate {
    
    @IBOutlet weak var row1: UIView!
    @IBOutlet weak var row2: UIView!
    @IBOutlet weak var row3: UIView!
    
    class func instanceFromNib(frame: CGRect, challenge: HigiChallenge, winConditions: [ChallengeWinCondition]) -> CompetitiveChallengeView {
        let competitiveView = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! CompetitiveChallengeView;
        competitiveView.frame = frame;
        
        var rows = [competitiveView.row1, competitiveView.row2, competitiveView.row3];
        let isTeamChallenge = winConditions[0].winnerType == "team";
        
        var rowCount = 0;
        if (isTeamChallenge) {
            let gravityTuple = ChallengeUtility.getTeamGravityBoard(challenge);
            let teamGravityBoard = gravityTuple.0;
            let ranks = gravityTuple.1
            for index in 0...teamGravityBoard.count - 1 {
                let name = teamGravityBoard[index].name;
                let row = ChallengeLeaderboardRow.instanceFromNib(frame, challenge: challenge, team: teamGravityBoard[index], rank: ranks[index]);
                if (name == challenge.participant.team.name) {
                    row.name.textColor = Utility.colorFromHexString(Constants.higiGreen);
                    row.place.textColor = Utility.colorFromHexString(Constants.higiGreen);
                }
                rows[index].frame.size.width = frame.size.width;
                rows[index].addSubview(row);
                rowCount++;
            }
        } else {
            let individualGravityBoard = challenge.gravityBoard;
            for index in 0...individualGravityBoard.count - 1 {
                let name = individualGravityBoard[index].participant.displayName;
                let place = individualGravityBoard[index].place!;
                let row = ChallengeLeaderboardRow.instanceFromNib(frame, challenge: challenge, participant: individualGravityBoard[index].participant, place: place as String);
                if (name == challenge.participant.displayName) {
                    row.name.textColor = Utility.colorFromHexString(Constants.higiGreen);
                    row.place.textColor = Utility.colorFromHexString(Constants.higiGreen);
                }
                rows[index].frame.size.width = frame.size.width;
                rows[index].addSubview(row);
                rowCount++;
            }
        }
        let margin:CGFloat = 8;
        switch rowCount {
        case 1:
            competitiveView.frame.size.height = competitiveView.row1.frame.origin.y + competitiveView.row1.frame.size.height + margin;
        case 2:
            competitiveView.frame.size.height = competitiveView.row2.frame.origin.y + competitiveView.row2.frame.size.height + margin;
        case 3:
            competitiveView.frame.size.height = competitiveView.row3.frame.origin.y + competitiveView.row3.frame.size.height + margin * 2;
        default:
            let i = 0;
        }
        return competitiveView;
    }
    
    override func animate() {
        let innerRow1 = row1.subviews[0] as! ChallengeLeaderboardRow;
        var innerRow2: ChallengeLeaderboardRow!;
        if (row2.subviews.count > 0) {
            innerRow2 = row2.subviews[0] as! ChallengeLeaderboardRow;
        }
        var innerRow3: ChallengeLeaderboardRow!;
        if (row3.subviews.count > 0) {
            innerRow3 = row3.subviews[0] as! ChallengeLeaderboardRow;
        }
        let width1 = (innerRow1.progress.subviews[0] ).frame.size.width;
        (innerRow1.progress.subviews[0] ).frame.size.width = 0;
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {
            (innerRow1.progress.subviews[0] ).frame.size.width = width1;
            }, completion: nil);
        
        if (innerRow2 != nil) {
            let width2 = (innerRow2!.progress.subviews[0] ).frame.size.width;
            (innerRow2!.progress.subviews[0] ).frame.size.width = 0;
            UIView.animateWithDuration(1.0, delay: 0.1, options: .CurveEaseInOut, animations: {
                (innerRow2!.progress.subviews[0] ).frame.size.width = width2;
                }, completion: nil);
        }
        
        if (innerRow3 != nil) {
            let width3 = (innerRow3!.progress.subviews[0] ).frame.size.width;
            (innerRow3!.progress.subviews[0] ).frame.size.width = 0;
            UIView.animateWithDuration(1.0, delay: 0.2, options: .CurveEaseInOut, animations: {
                (innerRow3!.progress.subviews[0] ).frame.size.width = width3;
                }, completion: nil);
        }
    }
}