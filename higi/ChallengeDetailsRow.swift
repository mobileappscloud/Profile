import Foundation

class ChallengeDetailsRow: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var description: UILabel!
    class func instanceFromNib(winCondition: ChallengeWinCondition, userPoints: Double, metric: String, index: Int) -> ChallengeDetailsRow {
        let row = UINib(nibName: "ChallengeDetailsRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsRow;
        return row;
    }
    
}