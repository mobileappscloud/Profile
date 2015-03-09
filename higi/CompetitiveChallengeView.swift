import Foundation

class CompetitiveChallengeView: ChallengeView, UIScrollViewDelegate {
    
    
    @IBOutlet weak var row1: UIView!
    @IBOutlet weak var row2: UIView!
    @IBOutlet weak var row3: UIView!
    
    class func instanceFromNib(frame: CGRect, challenge: HigiChallenge, winConditions: [ChallengeWinCondition]) -> CompetitiveChallengeView {
        let competitiveView = UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView;
        competitiveView.frame = frame;
        
        competitiveView.autoresizesSubviews = true;
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
                
                rows[index].frame.size.width = frame.size.width;
                rows[index].addSubview(row);
                
                row.setTranslatesAutoresizingMaskIntoConstraints(false);
                
                let xConstraint = NSLayoutConstraint(item: rows[index], attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: row, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0);
                let yConstraint = NSLayoutConstraint(item: rows[index], attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: row, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                let widthConstraint = NSLayoutConstraint(item: row, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: frame.size.width);
                
                rows[index].addConstraint(xConstraint);
                rows[index].addConstraint(yConstraint);
                row.addConstraint(widthConstraint);
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
                
                rows[index].frame.size.width = frame.size.width;
                rows[index].addSubview(row);

                row.setTranslatesAutoresizingMaskIntoConstraints(false);
 
                let xConstraint = NSLayoutConstraint(item: rows[index], attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: row, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0);
                let yConstraint = NSLayoutConstraint(item: rows[index], attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: row, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                let widthConstraint = NSLayoutConstraint(item: row, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: frame.size.width);
                
                rows[index].addConstraint(xConstraint);
                rows[index].addConstraint(yConstraint);
                row.addConstraint(widthConstraint);

            }
        }
        competitiveView.autoresizingMask = UIViewAutoresizing.FlexibleWidth;
        competitiveView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize);
        return competitiveView;
    }
    
    override func animate() {
        let innerRow1 = row1.subviews[0] as ChallengeLeaderboardRow;
        let innerRow2 = row2.subviews[0] as? ChallengeLeaderboardRow;
        let innerRow3 = row3.subviews[0] as? ChallengeLeaderboardRow;
        let width1 = (innerRow1.progress.subviews[0] as UIView).frame.size.width;
        (innerRow1.progress.subviews[0] as UIView).frame.size.width = 0;
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {
            (innerRow1.progress.subviews[0] as UIView).frame.size.width = width1;
            }, completion: nil);
        
        if (innerRow2 != nil) {
            let width2 = (innerRow2!.progress.subviews[0] as UIView).frame.size.width;
            (innerRow2!.progress.subviews[0] as UIView).frame.size.width = 0;
            UIView.animateWithDuration(1.0, delay: 0.1, options: .CurveEaseInOut, animations: {
                (innerRow2!.progress.subviews[0] as UIView).frame.size.width = width2;
                }, completion: nil);
        }
        
        if (innerRow3 != nil) {
            let width3 = (innerRow3!.progress.subviews[0] as UIView).frame.size.width;
            (innerRow3!.progress.subviews[0] as UIView).frame.size.width = 0;
            UIView.animateWithDuration(1.0, delay: 0.2, options: .CurveEaseInOut, animations: {
                (innerRow3!.progress.subviews[0] as UIView).frame.size.width = width3;
                }, completion: nil);
        }
    }
}