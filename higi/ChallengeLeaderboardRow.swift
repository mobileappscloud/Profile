import Foundation

class ChallengeLeaderboardRow: UITableViewCell {
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var progress: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    class func instanceFromNib(frame: CGRect, challenge: HigiChallenge, participant: ChallengeParticipant, place: String) -> ChallengeLeaderboardRow {
        let row = UINib(nibName: "ChallengeLeaderboardRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChallengeLeaderboardRow;
        let highScore = challenge.individualHighScore != 0 ? challenge.individualHighScore : 1;
        row.avatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl as String));
        row.name.text = participant.displayName as String;
        row.points.text = "\(Int(participant.units)) \(challenge.abbrMetric)";
        row.place.text = ChallengeUtility.getRankSuffix(place);
        row.progress.frame.size.width = frame.size.width - (row.place.frame.origin.x + row.place.frame.size.width + row.points.frame.size.width) - 8;
        setProgressBar(row.progress, points: Int(participant.units), highScore: Int(highScore));
        return row;
    }
    
    class func instanceFromNib(frame: CGRect, challenge: HigiChallenge, team: ChallengeTeam, index: Int) -> ChallengeLeaderboardRow {
        let row = UINib(nibName: "ChallengeLeaderboardRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChallengeLeaderboardRow;
        let highScore = challenge.teamHighScore;
        row.avatar.setImageWithURL(Utility.loadImageFromUrl(team.imageUrl as String));
        row.name.text = team.name as String;
        let units = Int(team.units);
        row.points.text = "\(units) \(challenge.abbrMetric)";
        row.place.text = ChallengeUtility.getRankSuffix(String(index + 1));
        row.progress.frame.size.width = frame.size.width - (row.place.frame.origin.x + row.place.frame.size.width + row.points.frame.size.width) - 8;
        setProgressBar(row.progress, points: Int(team.units), highScore: Int(highScore));
        return row;
    }
    
    class func setProgressBar(view: UIView, points: Int, highScore: Int) {
        let width = view.frame.size.width;
        let proportion = highScore != 0 ? min(CGFloat(points)/CGFloat(highScore), 1) : CGFloat(0);
        let newWidth = proportion * width;
        let barHeight:CGFloat = 4;
        let bar = UIView(frame: CGRect(x: 0, y: view.frame.origin.y - barHeight / 2, width: newWidth, height: barHeight));
        bar.backgroundColor = Utility.colorFromHexString(Constants.higiGreen);
        bar.layer.cornerRadius = barHeight / 2;
        view.addSubview(bar);
    }
}