import Foundation

class ChallengeDetailsChatterRow: UITableViewCell {
    
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var time: UILabel!
    
    class func instanceFromNib(winCondition: ChallengeDetailsChatterRow, userPoints: Double, metric: String, index: Int) -> ChallengeDetailsChatterRow {
        let row = UINib(nibName: "ChallengeDetailsChatterRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeDetailsChatterRow;
        

        return row;
    }
    
}