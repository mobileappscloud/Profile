import Foundation

class SplashViewController: UIViewController {
    
    @IBOutlet private var spinnerContainer: UIView!
    @IBOutlet private var spinnerContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var spinnerContainerWidthContainer: NSLayoutConstraint!
    
    private lazy var spinner: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(0, 0, self.spinnerContainerWidthContainer.constant, self.spinnerContainerHeightConstraint.constant))
        return spinner
    }()
    
    lazy var mainTabBarController = UIStoryboard(name: "TabBar", bundle: nil).instantiateInitialViewController() as! TabBarController
    
    // MARK: - View Lifecycle
    
    var sessionRetryCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad();
        spinnerContainer.addSubview(spinner)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.spinner.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        checkVersion()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        spinner.stopAnimating()
    }
    
    // MARK: -
    
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
        let navigationController = UINavigationController(rootViewController: WelcomeViewController(nibName: "Welcome", bundle: nil));
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
            
            }, failure: { [weak self] operation, error in
                
                if error.domain == NSURLErrorDomain && (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorTimedOut) {
                    
                    if self?.sessionRetryCount < 2 {
                        self?.sessionRetryCount += 1
                        self?.fetchSessionUser()
                    } else {
                        let alert = UIAlertController(title: "Connectivity Issue", message: error.localizedDescription, preferredStyle: .Alert)
                        let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { [weak self] (action) in
                            self?.fetchSessionUser()
                            })
                        alert.addAction(retryAction)
                        dispatch_async(dispatch_get_main_queue(), {
                            self?.presentViewController(alert, animated: true, completion: nil)
                        });
                    }
                    
                } else {
                    self?.errorToWelcome()
                }

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
            let termsNav = UINavigationController(rootViewController: termsController)
            self.presentViewController(termsNav, animated: true, completion: nil);
        } else if (user.firstName == nil || user.firstName == "" || user.lastName == nil || user.lastName == "") {
            let nameViewController = SignupNameViewController(nibName: "SignupNameView", bundle: nil);
            nameViewController.dismissOnSuccess = nameViewController
            let nameNav = UINavigationController(rootViewController: nameViewController)
            self.presentViewController(nameNav, animated: true, completion: nil);
        } else if user.dateOfBirthString == nil {
            let birthDateViewController = BirthdateViewController(nibName: "BirthdateView", bundle: nil)
            birthDateViewController.dismissOnSuccess = birthDateViewController
            let nav = UINavigationController(rootViewController: birthDateViewController)
            self.presentViewController(nav, animated: true, completion: nil)
        } else {
            ApiUtility.initializeApiData();
            AppDelegate.instance().startLocationManager();
            
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                guard let tabBarController = self?.mainTabBarController else { return }
                
                self?.presentViewController(tabBarController, animated: true, completion: {
                    dispatch_async(dispatch_get_main_queue(), {
                        if (SessionData.Instance.pin != "") {
                            tabBarController.presentViewController(PinCodeViewController(nibName: "PinCodeView", bundle: nil), animated: false, completion: nil);
                        }
                    })
                })
            })
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.SplashViewController.DidPresentMainTabBar, object: nil)
        }
    }
    
    func errorToWelcome() {
        spinner.stopAnimating();
        spinner.hidden = true;
        SessionData.Instance.reset();
        SessionData.Instance.save();
        let navigationController = UINavigationController(rootViewController: WelcomeViewController(nibName: "Welcome", bundle: nil));
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

            guard let minVersion = responseObject as? String else {
                self.moveToNextScreen()
                return
            }
            
            let isUpToDate = Utility.appMeetsMinimumVersionRequirement(minVersion)
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

extension Notifications {
    
    struct SplashViewController {
        static let DidPresentMainTabBar = "SplashViewControllerDidPresentMainTabBarNotificationKey"
    }
}
