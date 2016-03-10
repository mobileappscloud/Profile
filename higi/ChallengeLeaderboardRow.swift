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
        
        row.frame.size.width = frame.size.width;
        row.setupLeaderBoardRow(participant.imageUrl as String, nameText: participant.displayName as String, pointsText: "\(Int(participant.units)) \(challenge.abbrMetric)", placeText: ChallengeUtility.getRankSuffix(place));
        setProgressBar(row.progress, points: Int(participant.units), highScore: Int(highScore));
        return row;
    }
    
    class func instanceFromNib(frame: CGRect, challenge: HigiChallenge, team: ChallengeTeam, rank: Int) -> ChallengeLeaderboardRow {
        let row = UINib(nibName: "ChallengeLeaderboardRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChallengeLeaderboardRow;
        let highScore = challenge.teamHighScore;
        let units = Int(team.units);

        row.frame.size.width = frame.size.width;
        row.setupLeaderBoardRow(team.imageUrl as String, nameText: team.name as String, pointsText: "\(units) \(challenge.abbrMetric)", placeText: ChallengeUtility.getRankSuffix(String(rank)));
        setProgressBar(row.progress, points: Int(team.units), highScore: Int(highScore));
        return row;
    }
    
    func setupLeaderBoardRow(avatarUrl: String, nameText: String, pointsText: String, placeText:String) {
        avatar.setImageWithURL(Utility.loadImageFromUrl(avatarUrl));
        name.text = nameText;
        points.text = pointsText;
        place.text = placeText;
        progress.frame.size.width = frame.size.width - (place.frame.origin.x + place.frame.size.width + points.frame.size.width) - 8;
        points.frame.origin.x = frame.size.width - points.frame.size.width;
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