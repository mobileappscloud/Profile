import Foundation

class Utility {
    
    class func colorFromHexString(hexString: NSString) -> UIColor {
        var rgbValue: CUnsignedInt;
        rgbValue = 0;
        var scanner = NSScanner(string: hexString);
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
        (UIApplication.sharedApplication().delegate as AppDelegate).window?.rootViewController = revealController;
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
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as NSString) as String
    }
    
    class func getChallengeViews(challenge: HigiChallenge) -> [UIView] {
        var nib:UIView!;
        var nibs:[UIView] = [];
        var winConditions:[ChallengeWinCondition] = [];

        for index in 0...challenge.winConditions.count - 1 {
            let currentWinCondition = challenge.winConditions[index];
            let previousWinCondition:ChallengeWinCondition = index == 0 ? challenge.winConditions[index] : challenge.winConditions[index-1];
            
            let goalType = currentWinCondition.goal.type;
            let winnerType = currentWinCondition.winnerType;
            
            if (previousWinCondition !== currentWinCondition && (goalType != previousWinCondition.goal.type || winnerType != previousWinCondition.winnerType)) {
                let winConditionGoalType = winConditions[0].goal.type;
                if (winConditionGoalType == "most_points" || winConditionGoalType == "unit_goal_reached") {
                    nib = CompetitiveChallengeView.instanceFromNib(challenge, winConditions: winConditions);
                }
                else if (winConditionGoalType == "threshold_reached") {
                    nib = GoalChallengeView.instanceFromNib(challenge, winConditions: winConditions);
                }
                nibs.append(nib);
                winConditions = [];
            }
            winConditions.append(currentWinCondition);
        }
        
        if winConditions.count > 0 {
            let remainingGoalType = winConditions[0].goal.type;
            if (remainingGoalType == "most_points" || remainingGoalType == "unit_goal_reached") {
                nib = CompetitiveChallengeView.instanceFromNib(challenge, winConditions: winConditions);
            }
            else if (remainingGoalType == "threshold_reached") {
                nib = GoalChallengeView.instanceFromNib(challenge, winConditions: winConditions);
            }
            nibs.append(nib);
        }
        return nibs;
    }
    
    class func loadImageFromUrl(imageUrlString: String) -> NSURL {
        let imageUrl = NSURL(string: imageUrlString)?;
        if let imageError = imageUrl?.checkResourceIsReachableAndReturnError(NSErrorPointer()) {
            return imageUrl!;
        }
        return NSURL()
    }
    
}