import Foundation

class ChallengeLeaderboardRow: UITableViewCell {
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var progress: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var avatar: UIImageView!

    class func instanceFromNib(challenge: HigiChallenge, participant: ChallengeParticipant, index: Int) -> ChallengeLeaderboardRow {
        let row = UINib(nibName: "ChallengeLeaderboardRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeLeaderboardRow;
        
//        if (name == challenge.participant.team.name) {
//            setTextGreen(rows[index]);
//        }
//        setProgressBar(progressBar, points: Int(teamGravityBoard[index].units), highScore: highScore);
        
        row.avatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
        row.name.text = participant.displayName;
        row.points.text = "\(Int(participant.units)) pts";
        row.place.text = Utility.getRankSuffix(String(index + 1));
        
        return row;
    }
}