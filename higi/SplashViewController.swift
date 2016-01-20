import Foundation

class SplashViewController: UIViewController {
    
    private var spinner: CustomLoadingSpinner!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        checkVersion()
        self.spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height / 2 + 32, 32, 32));
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating();
    }

    func moveToNextScreen() {
        guard let token = SessionData.Instance.token else {
            navigateToWelcome()
            return
        }
        
        if token == "" {
            navigateToWelcome()
        } else {
            fetchSessionUser()
        }
    }
    
    func navigateToWelcome() {
        let navigationController = MainNavigationController(rootViewController: WelcomeViewController(nibName: "Welcome", bundle: nil));
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(navigationController, animated: false, completion: nil);
        })
    }
    
    func fetchSessionUser() {
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/qdata/\(SessionData.Instance.user.userId)?newSession=true", success: { operation, responseObject in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let login = HigiLogin(dictionary: responseObject as! NSDictionary);
                SessionData.Instance.user = login.user;
                ApiUtility.checkTermsAndPrivacy(self, success: self.successfullyCheckTermsAndPrivacy, failure: self.errorToWelcome);
            });
            
            }, failure: {operation, error in
                self.errorToWelcome();
        });
    }
    
    func successfullyCheckTermsAndPrivacy(termsFile: NSString, privacyFile: NSString) -> Void {
        let user = SessionData.Instance.user;
        let newTerms = termsFile != user.termsFile;
        let newPrivacy = privacyFile != user.privacyFile;
        if (newTerms || newPrivacy) {
            let termsController = TermsViewController(nibName: "TermsView", bundle: nil);
            termsController.newTerms = newTerms;
            termsController.newPrivacy = newPrivacy;
            termsController.termsFile = termsFile as String;
            termsController.privacyFile = privacyFile as String;
            self.presentViewController(termsController, animated: true, completion: nil);
        } else if (user.firstName == nil || user.firstName == "" || user.lastName == nil || user.lastName == "") {
            let nameViewController = SignupNameViewController(nibName: "SignupNameView", bundle: nil);
            nameViewController.dashboardNext = true;
            self.presentViewController(nameViewController, animated: true, completion: nil);
        } else {
            ApiUtility.initializeApiData();
            (UIApplication.sharedApplication().delegate as! AppDelegate).startLocationManager();
            Utility.gotoDashboard();
            NSNotificationCenter.defaultCenter().postNotificationName("SplashViewControllerDidGoToDashboard", object: nil)
        }
    }
    
    func errorToWelcome() {
        spinner.stopAnimating();
        spinner.hidden = true;
        SessionData.Instance.reset();
        SessionData.Instance.save();
        let navigationController = MainNavigationController(rootViewController: WelcomeViewController(nibName: "Welcome", bundle: nil));
        self.presentViewController(navigationController, animated: false, completion: nil);
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    func checkVersion() {
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/app/mobile/minVersion?p=ios", success: { operation, responseObject in
            
            var minVersionParts = (responseObject as! NSString).componentsSeparatedByString(".") ;
            for _ in minVersionParts.count...3 {
                minVersionParts.append("0");
            }
            var myVersionParts = Utility.appVersion().componentsSeparatedByString(".") as [String];
            
            var isUpToDate = true;
            
            for i in 0..<3 {
                let myPart = Int(myVersionParts[i])!;
                let minPart = Int(minVersionParts[i])!;
                if (myPart > minPart) {
                    break;
                } else if (myPart < minPart) {
                    isUpToDate = false;
                    break;
                }
            }
            
            if (isUpToDate) {
                self.moveToNextScreen();
            } else {
                self.pushAppUpdateViewController();
            }
            
            }, failure: {operation, error in
                self.moveToNextScreen();
        });
    }
    
    private func pushAppUpdateViewController() {
        let appUpdateViewController = UIStoryboard(name: "RequiredAppUpdate", bundle: nil).instantiateInitialViewController() as! RequiredAppUpdateViewController;
        self.presentViewController(appUpdateViewController, animated: false, completion: nil);
    }
}
