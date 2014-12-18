import Foundation

class GoalChallengeView: UIView {
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var rank: UILabel!
    @IBOutlet var progressBar: UIView!
    
    let circleRadius:CGFloat = 5;
    let labelMargin:CGFloat = 15;
    let goalBarOffset:CGFloat = 100;
    let goalBarHeight:CGFloat = 5;
    let verticalLineHeight:CGFloat = 15;
    let labelHeight:CGFloat = 10;
    
    func instanceFromNib(challenge: HigiChallenge, winConditions: [ChallengeWinCondition]) -> GoalChallengeView {
        let goalView = UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GoalChallengeView;
        
        if (challenge.participant != nil) {
            goalView.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.participant.imageUrl));
        }
        
        let participantPoints = challenge.participant != nil ? Int(challenge.participant.units) : 0;
        let maxGoalValue = winConditions[0].goal.minThreshold;
        
        drawGoals(goalView, participantPoints: participantPoints, winConditions: winConditions);
        
        drawParticipantProgress(goalView, participantPoints: participantPoints, maxGoalValue: maxGoalValue);
        
        //points label + vertical line pointing
        if (participantPoints < maxGoalValue) {
            drawParticipantPoints(goalView, participantPoints: participantPoints, maxGoalValue: maxGoalValue);
        }
        
        return goalView;
    }
    
    func drawGoals(goalView: UIView, participantPoints: Int, winConditions: [ChallengeWinCondition]) {
        var goalWinConditions = winConditions;
        goalWinConditions.sort { $0.goal.minThreshold! > $1.goal.minThreshold! };
        let maxGoalThreshold = goalWinConditions[0].goal.minThreshold;
        
        let closestPointIndex = findClosestPointIndex(participantPoints, goalWinConditions: goalWinConditions);
        
        var counter = 0;
        for winCondition in winConditions {
            let displayLabelBottom = (closestPointIndex % 2 == counter % 2);
            addGoalNode(goalView, winCondition: winCondition, participantPoints: participantPoints, maxGoalValue: maxGoalThreshold, isBottom: displayLabelBottom);
            counter++;
        }
    }
    
    func drawParticipantProgress(goalView: UIView, participantPoints: Int, maxGoalValue: Int) {
        let barWidth = (goalView.frame.width - goalBarOffset) * CGFloat(participantPoints) / CGFloat(maxGoalValue);
        let bar = UIView(frame: CGRect(x: goalBarOffset, y: goalView.frame.height/2 - goalBarHeight/2, width: barWidth, height: goalBarHeight));
        bar.backgroundColor = Utility.colorFromHexString("#76C043");
        bar.layer.cornerRadius = 2;
        goalView.addSubview(bar);
    }
    
    func drawParticipantPoints(goalView: UIView, participantPoints: Int, maxGoalValue: Int) {
        let progressWidth = goalBarOffset + (goalView.frame.width - goalBarOffset) * (CGFloat(participantPoints) / CGFloat(maxGoalValue));
        let verticalLinePosY = goalView.frame.height/2 - verticalLineHeight - labelHeight;
        let verticalLine = UIView(frame: CGRect(x: progressWidth, y: goalView.frame.height/2 - verticalLineHeight - labelHeight, width: 1, height: verticalLineHeight));
        verticalLine.backgroundColor = UIColor.lightGrayColor();
        
        var text = String(participantPoints);
        
        let labelPosY = verticalLinePosY - labelHeight;
        let pointsLabel = UILabel(frame: CGRectMake(0, 0, goalView.frame.width, labelHeight));
        pointsLabel.text = text;
        pointsLabel.center = CGPointMake(progressWidth, labelPosY);
        pointsLabel.textAlignment = NSTextAlignment.Center;
        pointsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline);
        
        goalView.addSubview(pointsLabel);
        goalView.addSubview(verticalLine);
    }
    
    func addGoalNode(goalView: UIView, winCondition: ChallengeWinCondition, participantPoints: Int!, maxGoalValue: Int!, isBottom: Bool) {
        
        let frameWidth = goalView.frame.width - goalBarOffset;
        let frameHeight = goalView.frame.height / 2 - circleRadius;
        let thisGoalValue = winCondition.goal.minThreshold;
        let proportion = CGFloat(thisGoalValue) / CGFloat(maxGoalValue);
        
        let posX = proportion * frameWidth + goalBarOffset;
        let posY = frameHeight;
        
        let goalCircle = UIView(frame: CGRect(x: posX, y: posY, width: circleRadius * 2, height: circleRadius * 2));
        let circleColor:UIColor = (participantPoints > thisGoalValue) ? Utility.colorFromHexString("#76C043") : UIColor.lightGrayColor();
        goalCircle.backgroundColor = circleColor;
        goalCircle.layer.cornerRadius = circleRadius;
        
        var labelHeight:CGFloat = isBottom ? -1.0 * labelMargin + circleRadius/2: labelMargin + circleRadius;
        var text = String(Int(thisGoalValue));
        let labelPosX = posX + circleRadius;
        let labelPosY = posY + labelHeight;
        let goalLabel = UILabel(frame: CGRectMake(0, 0, goalView.frame.width, labelHeight));
        goalLabel.text = text;
        goalLabel.center = CGPointMake(labelPosX, labelPosY);
        goalLabel.textAlignment = NSTextAlignment.Center;
        goalLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline);
        goalView.addSubview(goalLabel);
        goalView.addSubview(goalCircle);
    }
    
    class func findClosestPointIndex(participantPoints: Int, goalWinConditions: [ChallengeWinCondition]) -> Int {
        let size = goalWinConditions.count;
        var distance = goalWinConditions[size - 1].goal.minThreshold;
        
        for index in 0...size-1 {
            let thisDistance = abs(goalWinConditions[index].goal.minThreshold - participantPoints);
            if (thisDistance < distance) {
                distance = thisDistance;
            } else {
                return index;
            }
        }
        return size - 1;
    }
}