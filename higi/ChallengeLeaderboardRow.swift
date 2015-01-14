import Foundation

class ChallengeLeaderboardRow: UITableViewCell {
    @IBOutlet var rowContainer: UIView!
    class func instanceFromNib(challenge: HigiChallenge) -> ChallengeLeaderboardRow {
        let row = UINib(nibName: "ChallengeLeaderboardRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeLeaderboardRow;
        row.backgroundColor = UIColor.brownColor();
        
        return row;
    }
}