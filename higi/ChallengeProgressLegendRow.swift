import Foundation

class ChallengeProgressLegendRow: UITableViewCell {
    
    @IBOutlet weak var prizeDescription: UILabel!
    @IBOutlet weak var prizeTitle: UILabel!
    @IBOutlet weak var legendIndex: UIView!
    @IBOutlet weak var goalPoints: UILabel!
    
//    override func layoutSubviews() {
//        prizeDescription.sizeToFit();
//    }
    
    class func instanceFromNib(winCondition: ChallengeWinCondition, userPoints: Double, metric: String, index: Int) -> ChallengeProgressLegendRow {
        let row = UINib(nibName: "ChallengeProgressLegendRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeProgressLegendRow;

        let thisGoalValue = Int(winCondition.goal.minThreshold);
        let number = GoalChallengeView.makeComplexGoalNode(0, posY: 0, thisGoalValue: thisGoalValue, participantPoints: Int(userPoints), goalIndex: index);
        row.legendIndex.addSubview(number);
        row.prizeTitle.text = winCondition.prizeName;
        row.prizeDescription.text = winCondition.description;
        row.goalPoints.text = "\(String(thisGoalValue)) \(metric)";
        return row;
    }

    class func heightForRowAtIndex(winCondition: ChallengeWinCondition) -> CGFloat {
        let row = UINib(nibName: "ChallengeProgressLegendRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeProgressLegendRow;

        return 21 + 21 + 5 + Utility.heightForTextView(row.prizeDescription.frame.size.width, text: winCondition.description, fontSize: 12, margin: 5);
    }
}