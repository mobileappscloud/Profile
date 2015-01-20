import Foundation

class GoalChallengeView: UIView {
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var rank: UILabel!
    @IBOutlet var progressBar: UIView!
    
    struct ViewConstants {
        static let circleRadius:CGFloat = 5;
        static let labelMargin:CGFloat = 15;
        static let goalBarOffset:CGFloat = 100;
        static let goalBarHeight:CGFloat = 5;
        static let verticalLineHeight:CGFloat = 15;
        static let labelHeight:CGFloat = 15;
    }
    
    class func instanceFromNib(challenge: HigiChallenge, winConditions: [ChallengeWinCondition], isComplex: Bool) -> GoalChallengeView {
        let goalView = UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GoalChallengeView;
        if (challenge.participant != nil) {
            goalView.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.participant.imageUrl));
        }
        
        let participantPoints:Int = challenge.participant != nil ? Int(challenge.participant.units) : 0;
        
        var sortedWinConditions = winConditions;
        sortedWinConditions.sort { $0.goal.minThreshold! > $1.goal.minThreshold! };
        let maxGoalValue = sortedWinConditions[0].goal.minThreshold;
        
        drawParticipantProgress(goalView, participantPoints: participantPoints, maxGoalValue: maxGoalValue);
        
        drawGoals(goalView, participantPoints: participantPoints, winConditions: sortedWinConditions, maxGoalValue: maxGoalValue, isComplex: isComplex);
    
        //points label + vertical line pointing
        if (participantPoints < maxGoalValue) {
            drawParticipantPoints(goalView, participantPoints: participantPoints, maxGoalValue: maxGoalValue);
        }
        return goalView;
    }
    
    class func drawParticipantProgress(goalView: GoalChallengeView, participantPoints: Int, maxGoalValue: Int) {
        let barWidth = min((goalView.frame.width - ViewConstants.goalBarOffset) * CGFloat(participantPoints) / CGFloat(maxGoalValue),goalView.frame.width - ViewConstants.goalBarOffset + ViewConstants.circleRadius);
        let bar = UIView(frame: CGRect(x: ViewConstants.goalBarOffset, y: goalView.frame.height/2 - ViewConstants.goalBarHeight/2, width: barWidth, height: ViewConstants.goalBarHeight));
        bar.backgroundColor = Utility.colorFromHexString("#76C043");
        bar.layer.cornerRadius = 2;
        goalView.addSubview(bar);
    }
    
    class func drawParticipantPoints(goalView: GoalChallengeView, participantPoints: Int, maxGoalValue: Int) {
        let progressWidth = ViewConstants.goalBarOffset + (goalView.frame.width - ViewConstants.goalBarOffset) * (CGFloat(participantPoints) / CGFloat(maxGoalValue));
        let verticalLinePosY = goalView.frame.height/2 - ViewConstants.verticalLineHeight - ViewConstants.labelHeight;
        let verticalLine = UIView(frame: CGRect(x: progressWidth, y: goalView.frame.height/2 - ViewConstants.verticalLineHeight - ViewConstants.labelHeight, width: 1, height: ViewConstants.verticalLineHeight));
        verticalLine.backgroundColor = UIColor.lightGrayColor();
        
        var text = String(participantPoints);
        
        let labelPosY = verticalLinePosY - ViewConstants.labelHeight;
        let pointsLabel = UILabel(frame: CGRectMake(0, 0, goalView.frame.width, ViewConstants.labelHeight));
        pointsLabel.text = text;
        pointsLabel.center = CGPointMake(progressWidth, labelPosY);
        pointsLabel.textAlignment = NSTextAlignment.Center;
        pointsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline);
        
        goalView.addSubview(pointsLabel);
        goalView.addSubview(verticalLine);
    }
    
    class func drawGoals(goalView: GoalChallengeView, participantPoints: Int, winConditions: [ChallengeWinCondition], maxGoalValue: Int, isComplex: Bool) {
        let closestPointIndex = findClosestPointIndex(participantPoints, goalWinConditions: winConditions);
        
        var counter = 0;
        for index in 0...winConditions.count - 1 {
            let winCondition = winConditions[index];
            let displayLabelBottom = (closestPointIndex % 2 == counter % 2);
            //drawing goes from right to left so "index" is backwards
            addGoalNode(goalView, winCondition: winCondition, participantPoints: participantPoints, maxGoalValue: maxGoalValue, goalIndex: winConditions.count - index, isBottom: displayLabelBottom, isComplex: isComplex);
            counter++;
        }
    }
    
    class func addGoalNode(goalView: GoalChallengeView, winCondition: ChallengeWinCondition, participantPoints: Int!, maxGoalValue: Int!, goalIndex: Int, isBottom: Bool, isComplex: Bool) {
        
        let frameWidth = goalView.frame.width - ViewConstants.goalBarOffset;
        let frameHeight = goalView.frame.height / 2 - ViewConstants.circleRadius;
        let thisGoalValue = winCondition.goal.minThreshold;
        let proportion = CGFloat(thisGoalValue) / CGFloat(maxGoalValue);
        
        let posX = min(proportion * frameWidth + ViewConstants.goalBarOffset, frameWidth + ViewConstants.goalBarOffset);
        let posY = frameHeight;
        
        var labelMargin:CGFloat = 0;
        
        if (!isComplex) {
            let goalCircle = UIView(frame: CGRect(x: posX, y: posY, width: ViewConstants.circleRadius * 2, height: ViewConstants.circleRadius * 2));
            let circleColor:UIColor = (participantPoints > thisGoalValue) ? Utility.colorFromHexString("#76C043") : UIColor.lightGrayColor();
            goalCircle.backgroundColor = circleColor;
            goalCircle.layer.cornerRadius = ViewConstants.circleRadius;
            goalView.addSubview(goalCircle);
            
            labelMargin = isBottom ? -1.0 * ViewConstants.labelMargin + ViewConstants.circleRadius/2: ViewConstants.labelMargin + ViewConstants.circleRadius;
        } else {

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
            goalView.addSubview(goalCircle);

            labelMargin = isBottom ? -1.0 * ViewConstants.labelMargin - ViewConstants.circleRadius/2: ViewConstants.labelMargin + ViewConstants.circleRadius * 2;
        }
        var text = String(Int(thisGoalValue));
        let labelPosX = posX + ViewConstants.circleRadius;
        let labelPosY = posY + labelMargin;
        let goalLabel = UILabel(frame: CGRectMake(goalView.frame.width/2, labelPosY - labelMargin/2, goalView.frame.width, labelMargin));
        goalLabel.text = text;
        if (thisGoalValue == maxGoalValue) {
            goalLabel.textAlignment = NSTextAlignment.Right;
        } else {
            goalLabel.center = CGPointMake(labelPosX, labelPosY);
        }
        
        goalLabel.textAlignment = NSTextAlignment.Center;
        goalLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline);
        let goalLabelColor:UIColor = (participantPoints >= thisGoalValue) ? UIColor.blackColor() : UIColor.lightGrayColor();
        goalLabel.textColor = goalLabelColor;
        
        goalView.addSubview(goalLabel);
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