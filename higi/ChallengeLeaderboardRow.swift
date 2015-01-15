import Foundation

class ChallengeLeaderboardRow: UITableViewCell {
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var progress: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var avatar: UIImageView!

    class func instanceFromNib(challenge: HigiChallenge, participant: ChallengeParticipant, index: Int, isIndividual: Bool) -> ChallengeLeaderboardRow {
        let row = UINib(nibName: "ChallengeLeaderboardRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeLeaderboardRow;
        
        if (isIndividual) {
            let highScore = challenge.individualHighScore;
            row.avatar.setImageWithURL(Utility.loadImageFromUrl(participant.imageUrl));
            row.name.text = participant.displayName;
            row.points.text = "\(Int(participant.units)) \(challenge.metric)";
            row.place.text = Utility.getRankSuffix(String(index + 1));
            setProgressBar(row.progress, points: Int(participant.units), highScore: Int(highScore));
        } else {
            let highScore = challenge.teamHighScore;
            row.avatar.setImageWithURL(Utility.loadImageFromUrl(participant.team.imageUrl));
            row.name.text = participant.team.name;
            let units = participant.team.memberCount > 0 ? Int(participant.team.units) / participant.team.memberCount : 0;
                
            row.points.text = "\(units) \(challenge.metric)";
            row.place.text = Utility.getRankSuffix(String(index + 1));
            setProgressBar(row.progress, points: Int(participant.team.units), highScore: Int(highScore));
        }
        return row;
    }
    
    class func setProgressBar(view: UIView, points: Int, highScore: Int) {
        let width = view.frame.size.width;
        let proportion = min(CGFloat(points)/CGFloat(highScore), 1);
        let newWidth = proportion * width;
        
        let bar = UIView(frame: CGRect(x: 0, y: view.frame.origin.y / 2, width: newWidth, height: 5));
        bar.backgroundColor = Utility.colorFromHexString("#76C043");
        bar.layer.cornerRadius = 2;
        view.addSubview(bar);
    }
}