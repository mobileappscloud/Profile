import Foundation

class GoalChallengeView: UIView {
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var rank: UILabel!
    @IBOutlet var progress: UIView!
    
    struct ViewConstants {
        static let circleRadius:CGFloat = 5;
        static let labelMargin:CGFloat = 15;
        static let goalBarHeight:CGFloat = 4;
        static let verticalLineHeight:CGFloat = 15;
        static let labelHeight:CGFloat = 15;
    }
    
    class func instanceFromNib(frame: CGRect, challenge: HigiChallenge, winConditions: [ChallengeWinCondition], isComplex: Bool) -> GoalChallengeView {
        let goalView = UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GoalChallengeView;
        goalView.frame = frame;
        goalView.autoresizingMask = UIViewAutoresizing.FlexibleWidth;
        let isTeam = winConditions[0].winnerType == "team";
        
        if (isTeam) {
            goalView.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.participant.team.imageUrl));
        } else {
            goalView.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.participant.imageUrl));
        }
        
        let participantPoints = isTeam ? Int(challenge.participant.team.units) : Int(challenge.participant.units);
        
        var sortedWinConditions = winConditions;
        sortedWinConditions.sort { $0.goal.minThreshold! < $1.goal.minThreshold! };
        let maxGoalValue = sortedWinConditions[winConditions.count - 1].goal.minThreshold;
        
        drawParticipantProgress(goalView, participantPoints: participantPoints, maxGoalValue: maxGoalValue);
        
        drawGoals(goalView, participantPoints: participantPoints, winConditions: sortedWinConditions, maxGoalValue: maxGoalValue, isComplex: isComplex);
    
        //points label + vertical line pointing
        if (participantPoints < maxGoalValue) {
            drawParticipantPoints(goalView, participantPoints: participantPoints, maxGoalValue: maxGoalValue);
        }
        
        return goalView;
    }
    
    class func drawParticipantProgress(goalView: GoalChallengeView, participantPoints: Int, maxGoalValue: Int) {
        let barWidth = min((goalView.progress.frame.width) * CGFloat(participantPoints) / CGFloat(maxGoalValue), goalView.progress.frame.width);
        let bar = UIView(frame: CGRect(x: 0, y: goalView.progress.frame.height / 2 - ViewConstants.goalBarHeight / 2, width: barWidth, height: ViewConstants.goalBarHeight));
        bar.backgroundColor = Utility.colorFromHexString("#76C043");
        bar.layer.cornerRadius = 2;
        goalView.progress.addSubview(bar);
    }
    
    class func drawParticipantPoints(goalView: GoalChallengeView, participantPoints: Int, maxGoalValue: Int) {
        let progressWidth = (goalView.progress.frame.width) * (CGFloat(participantPoints) / CGFloat(maxGoalValue));
        let verticalLinePosY = goalView.progress.frame.height / 2 - ViewConstants.verticalLineHeight - ViewConstants.labelHeight;
        let verticalLine = UIView(frame: CGRect(x: progressWidth, y: goalView.progress.frame.height / 2 - ViewConstants.verticalLineHeight - ViewConstants.labelHeight, width: 1, height: ViewConstants.verticalLineHeight));
        verticalLine.backgroundColor = UIColor.lightGrayColor();
        
        var text = String(participantPoints);
        
        let labelPosY = verticalLinePosY - ViewConstants.labelHeight;
        let pointsLabel = UILabel(frame: CGRectMake(0, 0, goalView.progress.frame.width, ViewConstants.labelHeight));
        pointsLabel.text = text;
        pointsLabel.center = CGPointMake(progressWidth, labelPosY);
        pointsLabel.textAlignment = NSTextAlignment.Center;
        pointsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline);
        pointsLabel.textColor = Utility.colorFromHexString("#444444");
        
        goalView.progress.addSubview(pointsLabel);
        goalView.progress.addSubview(verticalLine);
    }
    
    class func drawGoals(goalView: GoalChallengeView, participantPoints: Int, winConditions: [ChallengeWinCondition], maxGoalValue: Int, isComplex: Bool) {
        let closestPointIndex = findClosestPointIndex(participantPoints, goalWinConditions: winConditions);
        
        var counter = 0;
        for index in 0...winConditions.count - 1 {
            let winCondition = winConditions[index];
            let displayLabelBottom = closestPointIndex % 2 != counter % 2;
            //drawing goes from right to left so "index" is backwards
            addGoalNode(goalView, winCondition: winCondition, participantPoints: participantPoints, maxGoalValue: maxGoalValue, goalIndex: index + 1, isBottom: displayLabelBottom, isComplex: isComplex);
            counter++;
        }
    }
    
    class func addGoalNode(goalView: GoalChallengeView, winCondition: ChallengeWinCondition, participantPoints: Int!, maxGoalValue: Int!, goalIndex: Int, isBottom: Bool, isComplex: Bool) {
        
        let frameWidth = goalView.progress.frame.width;
        let frameHeight = goalView.progress.frame.height / 2 - ViewConstants.circleRadius;
        let thisGoalValue = winCondition.goal.minThreshold;
        let proportion = CGFloat(thisGoalValue) / CGFloat(maxGoalValue);
        
        let posX = min(proportion * frameWidth - ViewConstants.circleRadius, frameWidth - 2 * ViewConstants.circleRadius);
        let posY = frameHeight;
        
        var labelMargin:CGFloat = 0;
        
        if (!isComplex) {
            let goalCircle = UIView(frame: CGRect(x: posX, y: posY, width: ViewConstants.circleRadius * 2, height: ViewConstants.circleRadius * 2));
            let circleColor:UIColor = (participantPoints > thisGoalValue) ? Utility.colorFromHexString("#76C043") : UIColor.lightGrayColor();
            goalCircle.backgroundColor = circleColor;
            goalCircle.layer.cornerRadius = ViewConstants.circleRadius;
            goalView.progress.addSubview(goalCircle);
            
            labelMargin = isBottom ? -1.0 * ViewConstants.labelMargin + ViewConstants.circleRadius/2: ViewConstants.labelMargin + ViewConstants.circleRadius;
        } else {

            let goalCircle = makeComplexGoalNode(posX, posY: posY, thisGoalValue: thisGoalValue, participantPoints: participantPoints, goalIndex: goalIndex);
            goalView.progress.addSubview(goalCircle);

            labelMargin = isBottom ? -1.0 * ViewConstants.labelMargin - ViewConstants.circleRadius/2: ViewConstants.labelMargin + ViewConstants.circleRadius * 2;
        }
        var text = String(Int(thisGoalValue));
        let labelPosX = posX + ViewConstants.circleRadius;
        let labelPosY = posY + labelMargin;
        var goalLabel:UILabel;
        
        if (thisGoalValue == maxGoalValue) {
            goalLabel = UILabel(frame: CGRectMake(0, labelPosY - labelMargin/2, goalView.frame.width - goalView.progress.frame.origin.x - 5, labelMargin));
            goalLabel.textAlignment = NSTextAlignment.Right;
        } else {
            goalLabel = UILabel(frame: CGRectMake(goalView.progress.frame.width/2, labelPosY - labelMargin/2, goalView.progress.frame.width, labelMargin));
            goalLabel.center = CGPointMake(labelPosX, labelPosY);
            goalLabel.textAlignment = NSTextAlignment.Center;
        }
        goalLabel.text = text;
        goalLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline);
        let goalLabelColor:UIColor = (participantPoints >= thisGoalValue) ? Utility.colorFromHexString("#444444") : UIColor.lightGrayColor();
        goalLabel.textColor = goalLabelColor;
        
        goalView.progress.addSubview(goalLabel);
    }
    
    class func makeComplexGoalNode(posX: CGFloat, posY: CGFloat, thisGoalValue: Int, participantPoints: Int, goalIndex: Int) -> UIView {
        let goalCircle = UILabel(frame: CGRect(x: posX - ViewConstants.circleRadius, y: posY - ViewConstants.circleRadius, width: ViewConstants.circleRadius * 4, height: ViewConstants.circleRadius * 4));
        let circleColor:UIColor = (participantPoints > thisGoalValue) ? Utility.colorFromHexString("#76C043") : UIColor.lightGrayColor();
        goalCircle.backgroundColor = UIColor.whiteColor();
        goalCircle.layer.cornerRadius = ViewConstants.circleRadius * 2;
        goalCircle.layer.borderWidth = 2;
        goalCircle.layer.borderColor = circleColor.CGColor;
        goalCircle.text = String(goalIndex);
        goalCircle.textAlignment = NSTextAlignment.Center;
        goalCircle.font = UIFont.systemFontOfSize(10);
        goalCircle.layer.masksToBounds = true;
        
        return goalCircle;
    }
    
    class func findClosestPointIndex(participantPoints: Int, goalWinConditions: [ChallengeWinCondition]) -> Int {
        let size = goalWinConditions.count;
        var distance = goalWinConditions[size - 1].goal.minThreshold;
        let lastNode = distance;
        
        for index in 0...size-1 {
            let thisDistance = abs(goalWinConditions[index].goal.minThreshold - min(participantPoints, lastNode));
            if (thisDistance < distance) {
                distance = thisDistance;
            } else {
                return index - 1;
            }
        }
        return size - 1;
    }
}