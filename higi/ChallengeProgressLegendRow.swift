import Foundation

class ChallengeProgressLegendRow: UITableViewCell {
    
    @IBOutlet weak var prizeDescription: UILabel!
    @IBOutlet weak var prizeTitle: UILabel!
    @IBOutlet weak var legendIndex: UIView!
    @IBOutlet weak var goalPoints: UILabel!
    class func instanceFromNib(winCondition: ChallengeWinCondition, userPoints: Double, metric: String, index: Int) -> ChallengeProgressLegendRow {
        let row = UINib(nibName: "ChallengeProgressLegendRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeProgressLegendRow;

        let thisGoalValue = Int(winCondition.goal.minThreshold);
        let number = GoalChallengeView.makeComplexGoalNode(0, posY: 0, thisGoalValue: thisGoalValue, participantPoints: Int(userPoints), goalIndex: index);
//        number.center = row.legendIndex.center;
        row.legendIndex.addSubview(number);
        row.prizeTitle.text = winCondition.prizeName;
        row.prizeDescription.text = winCondition.description;
        row.goalPoints.text = "\(String(thisGoalValue)) \(metric)";
        
        return row;
    }

}