import Foundation

class ChallengeProgressLegendRow: UITableViewCell {
    
    @IBOutlet weak var prizeDescription: UILabel!
    @IBOutlet weak var prizeTitle: UILabel!
    @IBOutlet weak var legendIndex: UIView!
    @IBOutlet weak var goalPoints: UILabel!
    
    override func layoutSubviews() {
        prizeDescription.frame.size.height = Utility.heightForTextView(prizeDescription.frame.size.width, text: prizeDescription.text ?? "", fontSize: 12, margin: 20);
        prizeTitle.frame.size.height = Utility.heightForTextView(prizeTitle.frame.size.width, text: prizeTitle.text ?? " ", fontSize: 12, margin: 5);
        prizeTitle.sizeToFit();
        prizeDescription.sizeToFit();
    }

    class func instanceFromNib(winCondition: ChallengeWinCondition, userPoints: Double, metric: String, index: Int) -> ChallengeProgressLegendRow {
        let row = UINib(nibName: "ChallengeProgressLegendRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChallengeProgressLegendRow;

        let thisGoalValue = Int(winCondition.goal.minThreshold);
        let number = GoalChallengeView.makeComplexGoalNode(0, posY: 0, thisGoalValue: thisGoalValue, participantPoints: Int(userPoints), goalIndex: index);
        row.legendIndex.addSubview(number);
        row.prizeTitle.text = winCondition.prizeName as? String ?? "";
        row.prizeDescription.text = winCondition.description as String;
        row.goalPoints.text = "\(String(thisGoalValue)) \(metric)";
//        row.prizeDescription.numberOfLines = 0;
//        row.prizeDescription.frame = CGRect(x: 42, y: 48, width: 234, height: 800);
//        row.prizeDescription.sizeToFit();
        return row;
    }

    class func heightForRowAtIndex(winCondition: ChallengeWinCondition) -> CGFloat {
        let row = UINib(nibName: "ChallengeProgressLegendRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChallengeProgressLegendRow;

        return 21 + 5 + Utility.heightForTextView(row.prizeTitle.frame.size.width, text: winCondition.prizeName as? String ?? " ", fontSize: 12, margin: 5) + Utility.heightForTextView(row.prizeDescription.frame.size.width, text: winCondition.description as String, fontSize: 12, margin: 5);
    }
}