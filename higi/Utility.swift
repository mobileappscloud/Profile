import Foundation

class Utility {
    
    class func colorFromHexString(hexString: NSString) -> UIColor {
        var rgbValue: CUnsignedInt;
        rgbValue = 0;
        var scanner = NSScanner(string: hexString as String);
        scanner.scanLocation = 1;
        scanner.scanHexInt(&rgbValue);
        return UIColor(red: (CGFloat)((rgbValue & 0xFF0000) >> 16) / 255.0, green:(CGFloat)((rgbValue & 0xFF00) >> 8) / 255.0, blue:(CGFloat)(rgbValue & 0xFF) / 255.0, alpha:1.0);
    }
    
    class func getViewController(view: UIView) -> UIViewController? {
        var responder: UIResponder? = view.nextResponder();
        while (responder != nil) {
            if (responder!.isKindOfClass(UIViewController)) {
                return responder as? UIViewController;
            }
            responder = responder!.nextResponder();
        }
        return nil;
    }
    
    class func gotoDashboard(viewController: UIViewController) {
        var dashboardController = DashboardViewController(nibName: "DashboardView", bundle: nil);
        var navController = MainNavigationController(rootViewController: dashboardController);
        var drawerController = DrawerViewController(nibName: "DrawerView", bundle: nil);
        var revealController = RevealViewController(rearViewController: drawerController, frontViewController: navController);
        drawerController.navController = navController;
        drawerController.revealController = revealController;
        navController.revealController = revealController;
        navController.drawerController = drawerController;
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = revealController;
        if (SessionData.Instance.pin != "") {
            revealController.presentViewController(PinCodeViewController(nibName: "PinCodeView", bundle: nil), animated: false, completion: nil);
        }
    }
    
    class func scaleImage(image: UIImage, newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale);
        image.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
        
    }
    
    class func iphone5Image(named: String) -> UIImage {
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone && UIScreen.mainScreen().bounds.size.height == 568) {
            return UIImage(named: "\(named)-568h")!;
        } else {
            return UIImage(named: named)!;
        }
    }
    
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as NSString as String) as! String
    }
    
    class func consolodateWinConditions(winConditions: [ChallengeWinCondition]) -> [[ChallengeWinCondition]] {
        var conditionsListHolder:[ChallengeWinCondition] = [];
        var consolodatedList:[[ChallengeWinCondition]] = [];
        
        for index in 0...winConditions.count - 1 {
            let currentWinCondition = winConditions[index];
            let previousWinCondition:ChallengeWinCondition = index == 0 ? winConditions[index] : winConditions[index-1];
            
            let goalType = currentWinCondition.goal.type;
            let winnerType = currentWinCondition.winnerType;
            
            if (previousWinCondition !== currentWinCondition && (goalType != previousWinCondition.goal.type || winnerType != previousWinCondition.winnerType)) {
                consolodatedList.append(conditionsListHolder);
                conditionsListHolder = [];
            }
            conditionsListHolder.append(currentWinCondition);
        }
        if conditionsListHolder.count > 0 {
            consolodatedList.append(conditionsListHolder);
            conditionsListHolder = [];
        }
        return consolodatedList;
    }
    
    class func getChallengeViews(challenge: HigiChallenge, frame: CGRect, isComplex: Bool) -> [ChallengeView] {
        var nib:ChallengeView!;
        var nibs:[ChallengeView] = [];
        var winConditions:[ChallengeWinCondition] = [];
        
        let consolodatedList = consolodateWinConditions(challenge.winConditions);
        
        for index in 0...consolodatedList.count - 1 {
            let firstWinCondition = consolodatedList[index][0];
            let goalType = firstWinCondition.goal.type;
            let winnerType = firstWinCondition.winnerType;

            if (goalType == "most_points" || goalType == "unit_goal_reached") {
                nib = CompetitiveChallengeView.instanceFromNib(frame, challenge: challenge, winConditions: consolodatedList[index]);
            } else if (goalType == "threshold_reached") {
                var createNib = false;
                for winCondition in consolodatedList[index] {
                    if (winCondition.goal.minThreshold > 1) {
                        createNib = true;
                        break;
                    }
                }
                if (createNib) {
                    nib = GoalChallengeView.instanceFromNib(frame, challenge: challenge, winConditions: consolodatedList[index], isComplex: isComplex);
                }
            }
            if (nib != nil) {
                nibs.append(nib);
            }
        }
        return nibs;
    }
    
    class func loadImageFromUrl(imageUrlString: String) -> NSURL {
        let imageUrl = NSURL(string: imageUrlString);
        if let imageError = imageUrl?.checkResourceIsReachableAndReturnError(NSErrorPointer()) {
            return imageUrl!;
        }
        return NSURL();
    }
    
    class func getRankSuffix(rank: NSString) -> String {
        if ( rank == "11" || rank == "12" || rank == "13") {
            return rank as String + "th"
        }
        let last = rank.substringFromIndex(rank.length - 1)
        switch(last) {
        case "1":
            return rank as String + "st"
        case "2":
            return rank as String + "nd"
        case "3":
            return rank as String + "rd"
        default:
            return rank as String + "th"
        }
    }
    
    class func heightForTextView(width: CGFloat, text: String, fontSize: CGFloat, margin: CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max));
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        label.font = UIFont.systemFontOfSize(fontSize);
        label.text = text;
        
        label.sizeToFit();
        return label.frame.height + margin;
    }
    
    class func htmlDecodeString(encodedString: String) -> String {
        let encodedData = encodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)!;
        
        return attributedString.string;
    }
    
    class func getTeamGravityBoard(challenge: HigiChallenge) -> ([ChallengeTeam], [Int]){
        let teams = challenge.teams;
        if (teams != nil) {
            var userTeamIndex = getUserIndex(teams, userTeam: challenge.participant.team);
            if (userTeamIndex != -1) {
                //calculate offsets, e.g. grab 1,2,3 or 4,5,6 from gravity board
                var startIndex:Int, endIndex:Int;
                //user's team in first
                if (userTeamIndex == 0) {
                    startIndex = userTeamIndex;
                    endIndex = userTeamIndex + 2;
                }
                    //user's team in last
                else if (userTeamIndex == teams.count - 1) {
                    startIndex = userTeamIndex - 2;
                    endIndex = userTeamIndex;
                }
                    //somewhere in the middle
                else {
                    startIndex = userTeamIndex - 1;
                    endIndex = userTeamIndex + 1;
                }
                //account for cases where size < 3 or = 3 but user's team not second
                startIndex = max(startIndex, 0);
                endIndex = min(endIndex, teams.count - 1);
                
                var gravityBoard:[ChallengeTeam] = [];
                var ranks:[Int] = [];
                
                for index in startIndex...endIndex {
                    //index - startIndex is effectively a counter
                    gravityBoard.append(teams[index]);
                    ranks.append(index + 1);
                }
                return (gravityBoard, ranks);
            }
        }
        return ([],[]);
    }
    
    //helper to find the current team's index
    class func getUserIndex(teams: [ChallengeTeam], userTeam: ChallengeTeam) -> Int {
        for index in 0...teams.count-1 {
            let thisTeam = teams[index];
            if (thisTeam.name == userTeam.name) {
                userTeam.place = index;
                return index;
            }
        }
        return -1;
    }
}