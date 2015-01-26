import Foundation

class ChallengeProgressLegendRow: UITableViewCell {
    
    @IBOutlet weak var prizeDescription: UILabel!
    @IBOutlet weak var prizeTitle: UILabel!
    @IBOutlet weak var legendIndex: UIView!
    @IBOutlet weak var goalPoints: UILabel!
    class func instanceFromNib(winCondition: ChallengeWinCondition) -> ChallengeProgressLegendRow {
        let row = UINib(nibName: "ChallengeProgressLegendRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeProgressLegendRow;
        
//        row.legendIndex
        row.prizeTitle.text = winCondition.prizeName;
        return row;
    }
}