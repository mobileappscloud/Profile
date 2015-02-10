import Foundation

class CompetitiveChallengeView: UIView, UIScrollViewDelegate {
    
    
    @IBOutlet weak var row1: UIView!
    @IBOutlet weak var row2: UIView!
    @IBOutlet weak var row3: UIView!
    
    class func instanceFromNib(frame: CGRect, challenge: HigiChallenge, winConditions: [ChallengeWinCondition]) -> CompetitiveChallengeView {
        let competitiveView = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView;
        competitiveView.frame = frame;
        var rows = [competitiveView.row1, competitiveView.row2, competitiveView.row3];
        let isTeamChallenge = winConditions[0].winnerType == "team";
        
        if (isTeamChallenge) {
            let gravityTuple = Utility.getTeamGravityBoard(challenge);
            let teamGravityBoard = gravityTuple.0;
            let teamRanks = gravityTuple.1;
            
            let highScore = challenge.teamHighScore;
            for index in 0...teamGravityBoard.count - 1 {
                let name = teamGravityBoard[index].name;
                let row = ChallengeLeaderboardRow.instanceFromNib(frame, challenge: challenge, team: teamGravityBoard[index], index: index);
                if (name == challenge.participant.team.name) {
                    row.name.textColor = Utility.colorFromHexString("#76C044");
                    row.place.textColor = Utility.colorFromHexString("#76C044");
                }
                rows[index].addSubview(row);
            }
        } else {
            let individualGravityBoard = challenge.gravityBoard;
            
            let highScore = challenge.individualHighScore;
            for index in 0...individualGravityBoard.count - 1 {
                let name = individualGravityBoard[index].participant.displayName;
                let place = individualGravityBoard[index].place!;
                let row = ChallengeLeaderboardRow.instanceFromNib(frame, challenge: challenge, participant: individualGravityBoard[index].participant, place: place);
                if (name == challenge.participant.displayName) {
                    row.name.textColor = Utility.colorFromHexString("#76C044");
                    row.place.textColor = Utility.colorFromHexString("#76C044");
                }
                rows[index].addSubview(row);
            }
        }
        competitiveView.autoresizingMask = UIViewAutoresizing.FlexibleWidth;
        competitiveView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize);
        return competitiveView;
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview();
        let a = self.superview?.frame.size.height;
        let b = self.superview?.frame.size.width;
        let i = 0;
    }
}