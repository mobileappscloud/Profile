import Foundation

class ChallengeLeaderboardRow: UITableViewCell {
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var progress: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    class func instanceFromNib(challenge: HigiChallenge, participant: ChallengeParticipant, place: String) -> ChallengeLeaderboardRow {
        let row = UINib(nibName: "ChallengeLeaderboardRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeLeaderboardRow;
        
        let highScore = challenge.individualHighScore != 0 ? challenge.individualHighScore : 1;
        row.avatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
        row.name.text = participant.displayName;
        row.points.text = "\(Int(participant.units)) \(challenge.metricAbbreviated())";
        row.place.text = Utility.getRankSuffix(place);
        setProgressBar(row.progress, points: Int(participant.units), highScore: Int(highScore));
        
        return row;
    }
    
    class func instanceFromNib(challenge: HigiChallenge, team: ChallengeTeam, index: Int) -> ChallengeLeaderboardRow {
        let row = UINib(nibName: "ChallengeLeaderboardRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeLeaderboardRow;
        
        let highScore = challenge.teamHighScore;
        row.avatar.setImageWithURL(Utility.loadImageFromUrl(team.imageUrl));
        row.name.text = team.name;
        let units = challenge.teams.count > 0 ? Int(team.units) / challenge.teams.count: 0;
        
        row.points.text = "\(units) \(challenge.metricAbbreviated())";
        row.place.text = Utility.getRankSuffix(String(index + 1));
        setProgressBar(row.progress, points: Int(team.units), highScore: Int(highScore));
        return row;
    }
    
    class func setProgressBar(view: UIView, points: Int, highScore: Int) {
        let width = view.frame.size.width;
        let proportion = min(CGFloat(points)/CGFloat(highScore), 1);
        let newWidth = proportion * width;
        
        let bar = UIView(frame: CGRect(x: 0, y: view.frame.origin.y - 5/2, width: newWidth, height: 4));
        bar.backgroundColor = Utility.colorFromHexString("#76C043");
        bar.layer.cornerRadius = 2;
        view.addSubview(bar);
    }
}