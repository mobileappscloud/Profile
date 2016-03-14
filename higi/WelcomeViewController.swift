import Foundation

class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle(NSLocalizedString("WELCOME_VIEW_LOGIN_BUTTON_TITLE", comment: "Title for button to log in."), forState: .Normal)
        }
    }
    @IBOutlet weak var signupButton: UIButton! {
        didSet {
            signupButton.setTitle(NSLocalizedString("WELCOME_VIEW_SIGN_UP_BUTTON_TITLE", comment: "Title for button to sign up for an account."), forState: .Normal)
        }
    }
    
    @IBOutlet weak var buttonSeparator: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageSubTitle: UILabel!

    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var phoneScrollView: UIScrollView!
    
    @IBOutlet weak var welcomeText: UILabel! {
        didSet {
            welcomeText.text = NSLocalizedString("WELCOME_VIEW_PAGE_WELCOME_TITLE", comment: "Title for welcome page on welcome tour.");
        }
    }
    @IBOutlet weak var welcomeSubTitle: UILabel! {
        didSet {
            welcomeSubTitle.text = NSLocalizedString("WELCOME_VIEW_PAGE_WELCOME_SUBTITLE", comment: "Subtitle for welcome page on welcome tour.");
        }
    }
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var stationView: UIImageView!
    
    var dashboardView:UIView!;
    
    var challengeView:UIImageView!, activityView:UIImageView!, MetricsView:UIImageView!, pulseView:UIImageView!;
    
    var didAnimate = false;
    
    var firstLoad = false
    
    let animDuration = 0.25;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        pageTitle.text = "";
        pageSubTitle.text = "";
        
        if (!didAnimate) {
            loginButton.alpha = 0;
            signupButton.alpha = 0;
            buttonSeparator.alpha = 0;
            welcomeText.alpha = 0;
            welcomeSubTitle.alpha = 0;
            UIView.animateWithDuration(animDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.loginButton.alpha = 1.0;
                self.signupButton.alpha = 1.0;
                self.buttonSeparator.alpha = 1.0;
                self.welcomeText.alpha = 1.0;
                self.welcomeSubTitle.alpha = 1.0;
                }, completion: nil);
            didAnimate = true;
        }
        
        let leftScrollViewSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:");
        leftScrollViewSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left;
        let rightScrollViewSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:");
        rightScrollViewSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right;
        self.view.addGestureRecognizer(leftScrollViewSwipeRecognizer);
        self.view.addGestureRecognizer(rightScrollViewSwipeRecognizer);
        
        firstLoad = true
    }
    
    private func setupDashboard() {
        dashboardView = UIView(frame: CGRect(x: 0, y: 2, width: phoneScrollView.frame.size.width, height: phoneScrollView.frame.size.height - 5));
        var yPos:CGFloat = 2;
        let imageMargin:CGFloat = 10;
        let imageWidth = dashboardView.frame.size.width;
        var imageHeight: CGFloat!;
        
        let challengeCard = UIImage(named: "activechallenges");
        imageHeight = scaledHeightFromWidth(challengeCard!, viewWidth: imageWidth);
        challengeView = UIImageView(frame: CGRect(x: 0, y: yPos, width: imageWidth, height: imageHeight));
        challengeView.contentMode = UIViewContentMode.ScaleAspectFit;
        challengeView.image = challengeCard;
        dashboardView.addSubview(challengeView);
        yPos += imageHeight + imageMargin;
        
        let activityCard = UIImage(named: "activities");
        imageHeight = scaledHeightFromWidth(activityCard!, viewWidth: imageWidth);
        activityView = UIImageView(frame: CGRect(x: 0, y: yPos, width: imageWidth, height: imageHeight));
        activityView.contentMode = UIViewContentMode.ScaleAspectFit;
        activityView.image = activityCard;
        dashboardView.addSubview(activityView);
        yPos += imageHeight;
        
        let metricsCard = UIImage(named: "metrics");
        imageHeight = scaledHeightFromWidth(metricsCard!, viewWidth: imageWidth);
        MetricsView = UIImageView(frame: CGRect(x: 0, y: yPos, width: imageWidth, height: imageHeight));
        MetricsView.contentMode = UIViewContentMode.ScaleAspectFit;
        MetricsView.image = metricsCard;
        dashboardView.addSubview(MetricsView);
        yPos += imageHeight + imageMargin;
        
        let pulseCard = UIImage(named: "pulse_article");
        imageHeight = scaledHeightFromWidth(pulseCard!, viewWidth: imageWidth);
        pulseView = UIImageView(frame: CGRect(x: 0, y: yPos, width: imageWidth, height: imageHeight));
        pulseView.contentMode = UIViewContentMode.ScaleAspectFit;
        pulseView.image = pulseCard;
        dashboardView.addSubview(pulseView);
        
        phoneContainer.alpha = 0;
        dashboardView.alpha = 0;
        
        phoneScrollView.addSubview(dashboardView);
    }
    
    func scaledHeightFromWidth(image: UIImage, viewWidth: CGFloat) -> CGFloat {
        let size = image.size;
        let ratio = viewWidth / size.width;
        return size.height * ratio;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        self.navigationController?.navigationBar.hidden = true;
        buttonSeparator.frame.origin.y = signupButton.frame.origin.y - 1;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /** @internal This is a patch around layout issues. Since the dashboard view and subviews rely on manual frame manipulation, we perform this method knowing that autolayout has correctly resized and placed the superview. 
        */
        if firstLoad {
            firstLoad = false
            self.setupDashboard()
        }
        // Even worse workaround to deal with alpha being improperly updated for subviews...
        if isViewLoaded() {
            changePage(pageControl, animated: false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.hidden = true;
        
        // Ugly workaround to dismiss 'Welcome/Tour' view hierarchy after signup/login is successfully dismissed.
        if SessionData.Instance.token != nil && SessionData.Instance.token != "" {
            // This view is added before dismissal so that it appears as though the user is being redirected immediately to the loading view
            let loadingViewController = UIStoryboard(name: "Loading", bundle: nil).instantiateInitialViewController()!
            self.view.addSubview(loadingViewController.view, pinToEdges: true)
            
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func swipeLeft(sender: AnyObject) {
        if (pageControl.currentPage < 4) {
            pageControl.currentPage = pageControl.currentPage + 1;
            changePage(pageControl);
        }
    }
    
    func swipeRight(sender: AnyObject) {
        if (pageControl.currentPage > 0) {
            pageControl.currentPage = pageControl.currentPage - 1;
            changePage(pageControl);
        }
    }
    
    @IBAction func changePage(sender: AnyObject) {
        guard let pager = sender as? UIPageControl else { return }
        changePage(pager, animated: true)
    }
    
    private func changePage(pageControl: UIPageControl, animated: Bool) {
        if !animated { return }
        
        let pager = pageControl
        let page = pager.currentPage;
        var frame = self.view.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        
        var phoneAlpha:CGFloat = 1.0, stationAlpha:CGFloat = 0, dashboardAlpha:CGFloat = 0, welcomeAlpha:CGFloat = 0;
        
        var challengesAlpha:CGFloat = 0.3, activityAlpha:CGFloat = 0.3, metricsAlpha:CGFloat = 0.3, pulseAlpha:CGFloat = 0.3;
        
        var title = "", subTitle = "";
        
        let animationDuration = animated ? animDuration : 0.0
        
        switch page {
        case 0:
            //welcome
            welcomeAlpha = 1;
            phoneAlpha = 0;
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.phoneContainer.alpha = 0;
                }, completion: nil);
        case 1:
            //station
            stationAlpha = 1;
            dashboardAlpha = 0;
            phoneAlpha = 0;
            title = NSLocalizedString("WELCOME_VIEW_PAGE_STATION_TITLE", comment: "Title for station page on welcome tour.")
            subTitle = NSLocalizedString("WELCOME_VIEW_PAGE_STATION_SUBTITLE", comment: "Subtitle for station page on welcome tour.")
        case 2:
            //challenges
            dashboardAlpha = 1;
            challengesAlpha = 1;
            title = NSLocalizedString("WELCOME_VIEW_PAGE_CHALLENGES_TITLE", comment: "Title for challenges page on welcome tour.")
            subTitle = NSLocalizedString("WELCOME_VIEW_PAGE_CHALLENGES_SUBTITLE", comment: "Subtitle for challenges page on welcome tour.")
            phoneScrollView.setContentOffset(CGPoint(x: 0, y: challengeView.frame.origin.y - 20), animated: true);
        case 3:
            //activity
            dashboardAlpha = 1;
            activityAlpha = 1;
            title = NSLocalizedString("WELCOME_VIEW_PAGE_ACTIVITY_TITLE", comment: "Title for activity page on welcome tour.")
            subTitle = NSLocalizedString("WELCOME_VIEW_PAGE_ACTIVITY_SUBTITLE", comment: "Subtitle for activity page on welcome tour.")
            phoneScrollView.setContentOffset(CGPoint(x: 0,y: activityView.frame.origin.y - 20), animated: true);
        case 4:
            //body stats
            dashboardAlpha = 1;
            metricsAlpha = 1;
            title =  NSLocalizedString("WELCOME_VIEW_PAGE_BODY_STAT_TITLE", comment: "Title for body stat page on welcome tour.")
            subTitle = NSLocalizedString("WELCOME_VIEW_PAGE_BODY_STAT_SUBTITLE", comment: "Subtitle for body stat page on welcome tour.")
            phoneScrollView.setContentOffset(CGPoint(x: 0, y: MetricsView.frame.origin.y - 20), animated: true);
        default:
            let i = 0;
        }
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.pageTitle.alpha = 0.0;
            self.pageSubTitle.alpha = 0.0;
            self.dashboardView.alpha = dashboardAlpha;
            if (welcomeAlpha == 0) {
                self.welcomeView.alpha = welcomeAlpha;
            }
            if (phoneAlpha == 0) {
                self.phoneContainer.alpha = phoneAlpha;
            }
            if (stationAlpha == 0) {
                self.stationView.alpha = stationAlpha;
            }
            }, completion: {
                finished in
                self.pageTitle.text = title;
                self.pageSubTitle.text = subTitle;
                UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.pageTitle.alpha = 1.0;
                    self.pageSubTitle.alpha = 1.0;
                    self.challengeView.alpha = challengesAlpha;
                    self.activityView.alpha = activityAlpha;
                    self.MetricsView.alpha = metricsAlpha;
                    self.pulseView.alpha = pulseAlpha;
                    if (welcomeAlpha == 1.0) {
                        self.welcomeView.alpha = welcomeAlpha;
                    }
                    if (stationAlpha == 1.0) {
                        self.stationView.alpha = stationAlpha;
                    }
                    if (phoneAlpha == 1.0) {
                        self.phoneContainer.alpha = phoneAlpha;
                    }
                    }, completion: nil);
        });
    }
    
    @IBAction func gotoLogin(sender: AnyObject) {
        Flurry.logEvent("Login_Pressed");
        let loginViewController = LoginViewController(nibName: "LoginView", bundle: nil)
        loginViewController.navigationItem.rightBarButtonItem = modalCancelButton()
        let loginNav = UINavigationController(rootViewController: loginViewController)
        self.navigationController?.presentViewController(loginNav, animated: true, completion: nil)
    }
    
    @IBAction func gotoSignup(sender: AnyObject) {
        Flurry.logEvent("Signup_Pressed");
        let signupViewController = SignupEmailViewController(nibName: "SignupEmailView", bundle: nil)
        signupViewController.navigationItem.rightBarButtonItem = modalCancelButton()
        let signUpNav = UINavigationController(rootViewController: signupViewController)
        self.navigationController?.presentViewController(signUpNav, animated: true, completion: nil)
    }

    private func modalCancelButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("dismissPresentedViewController:"))
    }
    
    func dismissPresentedViewController(sender: UIBarButtonItem) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
