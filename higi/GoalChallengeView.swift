import Foundation

class GoalChallengeView: ChallengeView {
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var rank: UILabel!
    @IBOutlet var progress: UIView!
    
    var participantPoints: Int!;
    
    var verticalLine, progressBar: UIView!;
    
    var pointsLabel: UILabel!;
    
    var nodeViews: [(UIView, UILabel, Int)] = [];
    
    var maxPoints: Int!;
    
    struct ViewConstants {
        static let circleRadius:CGFloat = 5;
        static let labelMargin:CGFloat = 15;
        static let goalBarHeight:CGFloat = 4;
        static let verticalLineHeight:CGFloat = 15;
        static let labelHeight:CGFloat = 15;
    }
    
    class func instanceFromNib(frame: CGRect, challenge: HigiChallenge, winConditions: [ChallengeWinCondition], isComplex: Bool) -> GoalChallengeView {
        let goalView = UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! GoalChallengeView;
        goalView.frame = frame;
        goalView.autoresizingMask = UIViewAutoresizing.FlexibleWidth;
        let isTeam = winConditions[0].winnerType == "team";
        
        if (isTeam) {
            goalView.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.participant.team.imageUrl as String));
        } else {
            goalView.avatar.setImageWithURL(Utility.loadImageFromUrl(challenge.participant.imageUrl as String));
        }
        
        goalView.participantPoints = isTeam ? Int(challenge.participant.team.units) : Int(challenge.participant.units);
        
        var nonTrivialWinConditions:[ChallengeWinCondition] = [];
        for winCondition in winConditions {
            if (winCondition.goal.minThreshold > 1) {
                nonTrivialWinConditions.append(winCondition);
            }
        }
        
        var sortedWinConditions = nonTrivialWinConditions;
        sortedWinConditions.sort { $0.goal.minThreshold! < $1.goal.minThreshold! };
        goalView.maxPoints = sortedWinConditions[sortedWinConditions.count - 1].goal.minThreshold;
        
        drawParticipantProgress(goalView, participantPoints: goalView.participantPoints, maxGoalValue: goalView.maxPoints);
        
        drawGoals(goalView, participantPoints: goalView.participantPoints, winConditions: sortedWinConditions, maxGoalValue: goalView.maxPoints, isComplex: isComplex);
        
        //points label + vertical line pointing
        if (goalView.participantPoints < goalView.maxPoints) {
            drawParticipantPoints(goalView, participantPoints: goalView.participantPoints, maxGoalValue: goalView.maxPoints);
        }
        
        return goalView;
    }
    
    class func drawParticipantProgress(goalView: GoalChallengeView, participantPoints: Int, maxGoalValue: Int) {
        let barWidth = min((goalView.progress.frame.width) * CGFloat(participantPoints) / CGFloat(maxGoalValue), goalView.progress.frame.width);
        goalView.progressBar = UIView(frame: CGRect(x: 0, y: goalView.progress.frame.height / 2 - ViewConstants.goalBarHeight / 2, width: barWidth, height: ViewConstants.goalBarHeight));
        goalView.progressBar.backgroundColor = Utility.colorFromHexString("#76C043");
        goalView.progressBar.layer.cornerRadius = 2;
        goalView.progress.addSubview(goalView.progressBar);
    }
    
    class func drawParticipantPoints(goalView: GoalChallengeView, participantPoints: Int, maxGoalValue: Int) {
        let progressWidth = (goalView.progress.frame.width) * (CGFloat(participantPoints) / CGFloat(maxGoalValue));
        let verticalLinePosY = goalView.progress.frame.height / 2 - ViewConstants.verticalLineHeight - ViewConstants.labelHeight;
        goalView.verticalLine = UIView(frame: CGRect(x: progressWidth, y: goalView.progress.frame.height / 2 - ViewConstants.verticalLineHeight - ViewConstants.labelHeight, width: 1, height: ViewConstants.verticalLineHeight));
        goalView.verticalLine.backgroundColor = UIColor.lightGrayColor();
        
        var text = String(participantPoints);
        
        let labelPosY = verticalLinePosY - ViewConstants.labelHeight;
        goalView.pointsLabel = UILabel(frame: CGRectMake(0, 0, goalView.progress.frame.width, ViewConstants.labelHeight));
        goalView.pointsLabel.text = text;
        goalView.pointsLabel.center = CGPointMake(progressWidth, labelPosY);
        goalView.pointsLabel.textAlignment = NSTextAlignment.Center;
        goalView.pointsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline);
        goalView.pointsLabel.textColor = Utility.colorFromHexString("#444444");
        
        goalView.progress.addSubview(goalView.pointsLabel);
        goalView.progress.addSubview(goalView.verticalLine);
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
        var goalCircle: UIView!;
        if (!isComplex) {
            goalCircle = UIView(frame: CGRect(x: posX, y: posY, width: ViewConstants.circleRadius * 2, height: ViewConstants.circleRadius * 2));
            let circleColor:UIColor = (participantPoints > thisGoalValue) ? Utility.colorFromHexString("#76C043") : Utility.colorFromHexString("#CDCDCD");
            goalCircle.backgroundColor = circleColor;
            goalCircle.layer.cornerRadius = ViewConstants.circleRadius;
            goalView.progress.addSubview(goalCircle);
            labelMargin = isBottom ? -1.0 * ViewConstants.labelMargin + ViewConstants.circleRadius/2: ViewConstants.labelMargin + ViewConstants.circleRadius;
        } else {
            
            goalCircle = makeComplexGoalNode(posX, posY: posY, thisGoalValue: thisGoalValue, participantPoints: participantPoints, goalIndex: goalIndex);
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
        let node: (UIView, UILabel, Int) = (goalCircle, goalLabel, thisGoalValue);
        goalView.nodeViews.append(node);
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
    
    override func animate() {
        let finalWidth = progressBar.frame.size.width;
        progressBar.frame.size.width = 0;
        verticalLine.alpha = 0.0;
        pointsLabel.transform = CGAffineTransformScale(pointsLabel.transform, 0.01, 0.01);
        pointsLabel.frame.origin.y += 20;
        var toAnimate: [(UIView, UILabel, Int)] = [];
        for (view, label, points) in nodeViews {
            if (points <= participantPoints) {
                view.backgroundColor = Utility.colorFromHexString("#CDCDCD");
                label.transform = CGAffineTransformScale(label.transform, 0.01, 0.01);
                toAnimate.append((view, label, points));
            }
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            NSThread.sleepForTimeInterval(0.25);
            var progress = 0.0;
            let startTime = NSDate.timeIntervalSinceReferenceDate() * 1000;
            let duration = 1000.0;
            while (progress < 1.0) {
                let currentTime = NSDate.timeIntervalSinceReferenceDate() * 1000;
                progress = min((currentTime - startTime) / duration, 1.0);
                var easeProgress = progress * 2;
                var newWidth: CGFloat!;
                var currentPoints: CGFloat!;
                if (easeProgress < 1) {
                    newWidth = finalWidth / 2 * pow(CGFloat(easeProgress), 3);
                    currentPoints = CGFloat(self.participantPoints) / 2.0 * pow(CGFloat(easeProgress), 3);
                } else {
                    easeProgress -= 2;
                    newWidth = finalWidth / 2 * (pow(CGFloat(easeProgress), 3) + 2);
                    currentPoints = CGFloat(self.participantPoints) / 2.0 * (pow(CGFloat(easeProgress), 3) + 2);
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.progressBar.frame.size.width = newWidth;
                    var toKeep: [(UIView, UILabel, Int)] = [];
                    for (view, label, points) in toAnimate {
                        if (Int(currentPoints) >= points) {
                            view.backgroundColor = Utility.colorFromHexString("#76C043");
                            UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseIn, animations: {
                                view.frame.size.width = ViewConstants.circleRadius * 3;
                                view.frame.size.height = ViewConstants.circleRadius * 3;
                                view.frame.origin.x -= 2;
                                view.frame.origin.y -= 2;
                                view.layer.cornerRadius = ViewConstants.circleRadius * 1.5;
                                label.transform = CGAffineTransformScale(label.transform, 125, 125);
                                }, completion: { completed in
                                    UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
                                        view.frame.size.width = ViewConstants.circleRadius * 2;
                                        view.frame.size.height = ViewConstants.circleRadius * 2;
                                        view.frame.origin.x += 2;
                                        view.frame.origin.y += 2;
                                        view.layer.cornerRadius = ViewConstants.circleRadius;
                                        label.transform = CGAffineTransformScale(label.transform, 0.8, 0.8);
                                        }, completion: nil);
                            });
                        } else {
                            toKeep.append((view, label, points));
                        }
                    }
                    toAnimate = toKeep;
                });
                
                
                NSThread.sleepForTimeInterval(0.02);
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.pointsLabel.transform = CGAffineTransformScale(self.pointsLabel.transform, 100, 100);
                    self.pointsLabel.frame.origin.y -= 20;
                    }, completion: { completed in
                        UIView.animateWithDuration(1.0, delay: 0, options: .CurveEaseInOut, animations: {
                            self.verticalLine.alpha = 1.0;
                            }, completion: nil);
                });
                
            });
            
        });
    }
}