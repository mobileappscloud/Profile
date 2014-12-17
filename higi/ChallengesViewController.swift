import Foundation

class ChallengesViewController: BaseViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var activeChallengesTable: UITableView!
    @IBOutlet var upcomingChallengesTable: UITableView!
    @IBOutlet var availableChallengesTable: UITableView!
    @IBOutlet var invitationsTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    
    var currentPage  = 0;
    
    let pageTitles:[String] = ["Active Challenges","Upcoming Challenges","Available Challenges","Invitations"]
    var activeChallenges:[HigiChallenge] = []
    var upcomingChallenges:[HigiChallenge] = []
    var availableChallenges:[HigiChallenge] = []
    var invitations:[HigiChallenge] = []
    
    override func viewDidLoad() {
        super.viewDidLoad();
        pager.currentPage = currentPage;
        title = pageTitles[currentPage];
        
        var session = SessionController.Instance
        
        for challenge:HigiChallenge in session.challenges {
            
            switch(challenge.userStatus) {
            case "current":
                    activeChallenges.append(challenge);
            case "public":
                availableChallenges.append(challenge)
            case "upcoming":
                upcomingChallenges.append(challenge)
            case "invited":
                invitations.append(challenge)
            default:
                var i = 0;
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 4, height: self.scrollView.frame.size.height);
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (activeChallengesTable == tableView) {
            return activeChallenges.count
        } else if (upcomingChallengesTable == tableView) {
            return upcomingChallenges.count
        } else if (availableChallengesTable == tableView) {
            return availableChallenges.count
        } else if (invitationsTable == tableView) {
            return invitations.count
        }
        
        return 0
    }
    
    func populateView(challenge:HigiChallenge, winConditions:[ChallengeWinCondition]) -> UIView {
        var nib:UIView!
        
        //build win conditions
        for wincondition in winConditions {
            var winconditionName = wincondition.name;
            var winnerType = wincondition.winnerType;
            var goalMin = wincondition.goal.minThreshold;
            var goalMax = wincondition.goal.maxThreshold;
            var goalType = wincondition.goal.type;
            
            if (goalType == "most_points" || goalType == "unit_goal_reached") {
                if (challenge.userStatus == "current") {
                    nib = populateCompetitiveView(challenge);
                }
            }
            else if (goalType == "threshold_reached") {
                nib = populateGoalView(challenge, winConditions: winConditions);
            }
        }
        
        return nib;
    }
    
    func populateCompetitiveView(challenge : HigiChallenge) -> UIView {
        let competitiveView = CompetitiveChallengeView.instanceFromNib();
        let gravityBoard = challenge.gravityBoard;
        
        for (var i = 0; i < gravityBoard.count; i++) {
            if (i == 0) {
                competitiveView.firstPositionName.text = gravityBoard[i].participant.displayName;
                competitiveView.firstPositionPoints.text = "\(Int(gravityBoard[i].participant.units)) pts";
                competitiveView.firstPositionRank.text = getRankSuffix(gravityBoard[i].place);
                competitiveView.firstPositionAvatar.setImageWithURL(loadImageFromUrl(gravityBoard[i].participant.imageUrl));
            } else if (i == 1) {
                competitiveView.secondPositionName.text = gravityBoard[i].participant.displayName;
                competitiveView.secondPositionPoints.text = "\(Int(gravityBoard[i].participant.units)) pts";
                competitiveView.secondPositionRank.text = getRankSuffix(gravityBoard[i].place);
                competitiveView.secondPositionAvatar.setImageWithURL(loadImageFromUrl(gravityBoard[i].participant.imageUrl));
            } else {
                competitiveView.thirdPositionName.text = gravityBoard[i].participant.displayName
                competitiveView.thirdPositionPoints.text = "\(Int(gravityBoard[i].participant.units)) pts";
                competitiveView.thirdPositionRank.text = getRankSuffix(gravityBoard[i].place);
                competitiveView.thirdPositionAvatar.setImageWithURL(loadImageFromUrl(gravityBoard[i].participant.imageUrl));
            }
        }
        return competitiveView;
    }
    
    func populateGoalView(challenge: HigiChallenge, winConditions: [ChallengeWinCondition]) -> UIView{
        let goalView = GoalChallengeView.instanceFromNib();
        if (challenge.participant != nil) {
            goalView.avatar.setImageWithURL(loadImageFromUrl(challenge.participant.imageUrl));
        }
        
        drawGoals();
        
        drawParticipantProgress();
        
        drawParticipantPoints();
        
        let participantPoints = challenge.participant != nil ? Int(challenge.participant.units) : 0;
        
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
        
        return goalView;
    }
    
    func drawGoals() {
        
    }
    
    func drawParticipantProgress() {
        
    }
    
    func drawParticipantPoints() {
        
    }
    
    func addGoalNode(goalView: UIView, winCondition: ChallengeWinCondition, participantPoints: Int!, maxGoalValue: Int!, isBottom: Bool) {
        let circleRadius:CGFloat = 5;
        let barHeight:CGFloat = 5;
        let labelMargin:CGFloat = 15;
        let goalBarOffset:CGFloat = 100;
        
        let frameWidth = goalView.frame.width - goalBarOffset;
        let frameHeight = goalView.frame.height/2 - circleRadius;
        let thisGoalValue = winCondition.goal.minThreshold;
        let proportion = CGFloat(thisGoalValue) / CGFloat(maxGoalValue);
        
        let marginLeft = goalView.frame.origin.x;
        let marginBottom = goalView.frame.origin.y;
        
        goalView.subviews
        let posX = proportion * frameWidth + goalBarOffset;
        let posY = frameHeight;
        
        let goalCircle = UIView(frame: CGRect(x: posX, y: posY, width: circleRadius * 2, height: circleRadius * 2));
        let circleColor:UIColor = (participantPoints > thisGoalValue) ? Utility.colorFromHexString("#76C043") : UIColor.lightGrayColor();
        goalCircle.backgroundColor = circleColor;
        goalCircle.layer.cornerRadius = circleRadius;
        
        var labelHeight:CGFloat = isBottom ? -1.0 * labelMargin - circleRadius: labelMargin;
        var text = String(Int(thisGoalValue));
        var length = countElements(text);
        
        let labelPosX = posX - (CGFloat(countElements(text) + 1) * 2);
        let labelPosY = posY + (labelHeight);
        let goalLabel = UILabel(frame: CGRectMake(labelPosX, labelPosY, goalView.frame.width, 15));
        
        goalLabel.text = text;
        
        goalView.addSubview(goalLabel);
        goalView.addSubview(goalCircle);
    }
    
    
    func findClosestPointIndex(participantPoints: Int, goalWinConditions: [ChallengeWinCondition]) -> Int {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //@todo fix the scrolling issue maybe an autolayout issue
        var cell = tableView.dequeueReusableCellWithIdentifier("ChallengeRowCell") as ChallengeRowCell!;
        
        if (cell == nil) {
            cell = UINib(nibName: "ChallengeRowCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeRowCell
        }
        cell.separatorInset = UIEdgeInsetsZero;
        
        if (UIDevice.currentDevice().systemVersion >= "8.0") {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
        //remove all children before populating scrollview
        for subview in cell.scrollView.subviews {
            subview.removeFromSuperview();
        }
        
        //load the appropriate challenges for this table
        var challenges:[HigiChallenge] = [];
        if (tableView == activeChallengesTable) {
            challenges = activeChallenges;
            cell = buildChallengeCell(cell, challenge: challenges[indexPath.row]);
        } else if (tableView == upcomingChallengesTable) {
            challenges = upcomingChallenges;
            cell = buildInvitationCell(cell, challenge: challenges[indexPath.row]);
        } else if (tableView == availableChallengesTable) {
            challenges = availableChallenges;
            cell = buildInvitationCell(cell, challenge: challenges[indexPath.row]);
        } else {
            challenges = invitations;
            cell = buildInvitationCell(cell, challenge: challenges[indexPath.row]);
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    func buildChallengeCell(cell: ChallengeRowCell, challenge: HigiChallenge) -> ChallengeRowCell {
        var nibOriginX:CGFloat = 0.0;
        
        var previousWinCondition:ChallengeWinCondition!;
        var winConditions:[ChallengeWinCondition] = [];

        let screenSize: CGRect = UIScreen.mainScreen().bounds;
        let screenWidth = screenSize.width;
//        cell.scrollView.frame.size.width = screenWidth;

        var pages = 0;
        for currentWinCondition in challenge.winConditions {
            var goalType = currentWinCondition.goal.type;
            var winnerType = currentWinCondition.winnerType;
            
            if (previousWinCondition != nil && (goalType != previousWinCondition.goal.type || winnerType != previousWinCondition.winnerType)) {
                var nib = populateView(challenge,winConditions: winConditions);
                nib.frame.origin.x = nibOriginX;

                cell.scrollView.addSubview(nib);
                nibOriginX += nib.frame.width;
                
                winConditions = [];
                
                pages++;
            }
            
            winConditions.append(currentWinCondition);
            previousWinCondition = currentWinCondition;
        }
        
        if winConditions.count > 0 {
            var nib = populateView(challenge,winConditions: winConditions);
            nib.frame.origin.x = nibOriginX;
            
            cell.scrollView.addSubview(nib);
            
            pages++;
        }
        
        //populate cell contents
        cell.pager.numberOfPages = pages;
        cell.pager.currentPage = 0;
        cell.title.text = challenge.name
        
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width * CGFloat(pages), height: cell.frame.size.height - 45);
        
        var daysLeft:Int = 0
        var endDate:NSDate? = challenge.endDate?
        if (endDate != nil) {
            var compare:NSTimeInterval = endDate!.timeIntervalSinceNow
            
            if ( Int(compare) > 0) {
                daysLeft = Int(compare) / 60 / 60 / 24
            }
        }
        
        cell.daysLeft.text = "\(daysLeft)d left";
        
        cell.avatar.setImageWithURL(self.loadImageFromUrl(challenge.imageUrl));
        
        return cell;
    }
    
    func buildInvitationCell(cell: ChallengeRowCell, challenge: HigiChallenge) -> ChallengeRowCell {
        var invitationView = UINib(nibName: "ChallengeInvitation", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ChallengeInvitationView;
        
        //we can just grab the first one bcuz win conditions prioritized by API and have already been consolidated so type is same for all of them
        var winCondition = challenge.winConditions[0];
        
        invitationView.title.text = challenge.name;
        invitationView.avatar.setImageWithURL(loadImageFromUrl(challenge.imageUrl))
        invitationView.goal.text = winCondition.goal.type == "most_points" ? "Most points" : "Threshold reached";
        invitationView.type.text = goalTypeDisplayHelper(winCondition.goal.type, winnerType: winCondition.winnerType);
        invitationView.prize.text = winCondition.prizeName != nil ? winCondition.prizeName : "Coming soon!";
        invitationView.participantCount.text = String(challenge.participantsCount)
        
        var days:Int = 0
        var message:String!
        var startDate:NSDate? = challenge.startDate?
        var endDate:NSDate? = challenge.endDate?
        if ( startDate != nil ) {
            var compare:NSTimeInterval = startDate!.timeIntervalSinceNow
            
            if ( Int(compare) > 0) {
                days = Int(compare) / 60 / 60 / 24
                message = "Starts in \(days) days!"
            } else if ( Int(compare) < 0 ) {
                days = abs(Int(compare)) / 60 / 60 / 24
                message = "Started \(days) days ago!"
            } else {
                message = "Starting today!"
            }
        }
        invitationView.starting.text = message;
        
        let formatter = NSDateFormatter();
        formatter.dateStyle = .MediumStyle;
        var startDateShort = formatter.stringFromDate(startDate!);
        var endDateShort = formatter.stringFromDate(endDate!);
        
        invitationView.dateRange.text = "\(startDateShort) - \(endDateShort)";
        
        cell.scrollView.contentSize = CGSize(width: cell.frame.size.width, height: cell.frame.size.height);

        cell.title.hidden = true;
        cell.avatar.hidden = true;
        cell.daysLeft.hidden = true;
        
        return cell;
    }
    
    func goalTypeDisplayHelper(goalType: String, winnerType: String) -> String {
        //either individual or team, only
        var firstPart = goalType == "individual" ? "Individual" : "Team";
        var secondPart = winnerType == "most_points" ? "Points Challenge" : "Goal Challenge";
        return firstPart + " " + secondPart;
        
    }
    
    func getRankSuffix(rank: NSString) -> String {
        if ( rank == "11" || rank == "12" || rank == "13") {
            return rank + "th"
        }
        
        let last = rank.substringFromIndex(rank.length - 1)
        switch(last) {
        case "1":
            return rank + "st"
        case "2":
            return rank + "nd"
        case "3":
            return rank + "rd"
        default:
            return rank + "th"
        }
    }
    
    func loadImageFromUrl(imageUrlString: String) -> NSURL {
        if (!imageUrlString.isEmpty) {
            let imageUrl = NSURL(string: imageUrlString)?;
            if let imageError = imageUrl?.checkResourceIsReachableAndReturnError(NSErrorPointer()) {
                if( !imageError ) {
                    return imageUrl!;
                }
            }
        }
        return NSURL()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        pager.currentPage = page;
        changePage(pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var page = pager.currentPage;
        title = pageTitles[page];
        currentPage = page
        
        var frame = self.scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.setContentOffset(frame.origin, animated: true);
    }
    
}