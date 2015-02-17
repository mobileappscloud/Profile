import Foundation

class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var buttonSeparator: UIView!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageSubTitle: UILabel!

    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var phoneScrollView: UIScrollView!
    
    var mapView:UIImageView!;
    var dashboardView:UIView!;
    var activityView:UIImageView!;
    var challengeView:UIImageView!;
    var bodyStatsView:UIImageView!;
    var pulseView:UIImageView!;
    
    var firstScreen: WelcomeFirstView!;
    var secondScreen, thirdScreen, fourthScreen, fifthScreen: WelcomeView!;
    
    var didAnimate = false;
    let animDuration = 0.5;
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        
        self.automaticallyAdjustsScrollViewInsets = false;
        firstScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[1] as WelcomeFirstView;
        secondScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
        thirdScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
        fourthScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
        fifthScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;

        var frame = UIScreen.mainScreen().bounds;
        scrollView.frame = frame;
        scrollView.contentSize = CGSize(width: 5 * frame.size.width, height: frame.size.height);
        firstScreen.frame = frame;
        frame.origin.x += frame.size.width;
        secondScreen.frame = frame;
        frame.origin.x += frame.size.width;
        thirdScreen.frame = frame;
        frame.origin.x += frame.size.width;
        fourthScreen.frame = frame;
        frame.origin.x += frame.size.width;
        fifthScreen.frame = frame;

        scrollView.addSubview(firstScreen);
        scrollView.addSubview(secondScreen);
        scrollView.addSubview(thirdScreen);
        scrollView.addSubview(fourthScreen);
        scrollView.addSubview(fifthScreen);
        
        pageTitle.text = "";
        pageSubTitle.text = "";
        
        if (!didAnimate) {
            loginButton.alpha = 0;
            signupButton.alpha = 0;
            welcomeText.alpha = 0;
            buttonSeparator.alpha = 0;
            UIView.animateWithDuration(animDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.loginButton.alpha = 1.0;
                self.signupButton.alpha = 1.0;
                self.welcomeText.alpha = 1.0;
                self.buttonSeparator.alpha = 1.0;
                }, completion: nil);
            didAnimate = true;
        }
        let phoneWidth = phoneScrollView.frame.size.width;
        let phoneHeight = phoneScrollView.frame.size.height;

        mapView = UIImageView(frame: CGRect(x: 0, y: 2, width: phoneScrollView.frame.size.width, height: phoneScrollView.frame.size.height));
        let map = UIImage(named: "iphonemap");
        mapView.image = map;
        
        dashboardView = UIView(frame: CGRect(x: 0, y: 7, width: phoneScrollView.frame.size.width, height: phoneScrollView.frame.size.height - 5));
        var yPos:CGFloat = 2;
        let imageMargin:CGFloat = 10;
        let imageWidth = dashboardView.frame.size.width - imageMargin * 2;
        
        var imageHeight:CGFloat = 150;
        activityView = UIImageView(frame: CGRect(x: imageMargin, y: yPos, width: imageWidth, height: 150));
        let activityCard = UIImage(named: "todayactivity");
        activityView.image = activityCard;
        dashboardView.addSubview(activityView);
        yPos += imageHeight + imageMargin;

        imageHeight = 142;
        challengeView = UIImageView(frame: CGRect(x: imageMargin, y: yPos, width: imageWidth, height: imageHeight));
        let challengeCard = UIImage(named: "activechallenges");
        challengeView.image = challengeCard;
        dashboardView.addSubview(challengeView);
        yPos += imageHeight + imageMargin;
        
        imageHeight = 172;
        bodyStatsView = UIImageView(frame: CGRect(x: imageMargin, y: yPos, width: imageWidth, height: imageHeight));
        let bodyStatsCard = UIImage(named: "bodystats");
        bodyStatsView.image = bodyStatsCard;
        dashboardView.addSubview(bodyStatsView);
        yPos += imageHeight + imageMargin;
        
        pulseView = UIImageView(frame: CGRect(x: imageMargin, y: yPos, width: imageWidth, height: imageHeight));
        let pulseCard = UIImage(named: "pulse_article");
        pulseView.image = pulseCard;
        dashboardView.addSubview(pulseView);
        
        phoneContainer.alpha = 0;
        dashboardView.alpha = 0;
        
        phoneScrollView.addSubview(mapView);
        phoneScrollView.addSubview(dashboardView);
        
        let leftPhoneSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:");
        leftPhoneSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left;
        let rightPhoneSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:");
        rightPhoneSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right;

        phoneContainer.addGestureRecognizer(leftPhoneSwipeRecognizer);
        phoneContainer.addGestureRecognizer(rightPhoneSwipeRecognizer);
        
        let leftScrollViewSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:");
        leftScrollViewSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left;
        let rightScrollViewSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:");
        rightScrollViewSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right;

        scrollView.addGestureRecognizer(leftScrollViewSwipeRecognizer);
        scrollView.addGestureRecognizer(rightScrollViewSwipeRecognizer);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        self.navigationController!.navigationBar.hidden = true;
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        buttonSeparator.frame.origin.y = signupButton.frame.origin.y - 1;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController!.navigationBar.hidden = true;
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
    }

    func swipeLeft(sender: AnyObject) {
        let a = pageControl.currentPage;
        if (pageControl.currentPage < 4) {
            pageControl.currentPage = pageControl.currentPage + 1;
            changePage(pageControl);
        }
    }
    
    func swipeRight(sender: AnyObject) {
        let a = pageControl.currentPage;
        if (pageControl.currentPage > 0) {
            pageControl.currentPage = pageControl.currentPage - 1;
            changePage(pageControl);
        }
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var page = pager.currentPage;
        var frame = scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        
        var phoneAlpha:CGFloat = 1.0;
        var mapAlpha:CGFloat = 0;
        var dashboardAlpha:CGFloat = 0;
        var activityAlpha:CGFloat = 0.3;
        var challengesAlpha:CGFloat = 0.3;
        var bodyStatsAlpha:CGFloat = 0.3;
        let pulseAlpha:CGFloat = 0.3;
        switch page {
            case 0:
                (self.scrollView.subviews[0] as WelcomeFirstView).alpha = 0;
                if (page == 0) {
                    UIView.animateWithDuration(0.5, animations: {
                        (self.scrollView.subviews[0] as WelcomeFirstView).alpha = 1.0;
                    });
                }
                phoneAlpha = 0;
                UIView.animateWithDuration(0.5, animations: {
                    self.phoneContainer.alpha = 0;
                });
                pageTitle.text = "";
                pageSubTitle.text = "";
            case 1:
                mapAlpha = 1;
                dashboardAlpha = 0;
                pageTitle.text = "Find a higi Station";
                pageSubTitle.text = "Track your body stats and earn points";
            case 2:
                dashboardAlpha = 1;
                activityAlpha = 1;
                phoneScrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true);
                pageTitle.text = "Sync your fitness device";
                pageSubTitle.text = "Add a device and earn daily points";
            case 3:
                dashboardAlpha = 1;
                challengesAlpha = 1;
                phoneScrollView.setContentOffset(CGPoint(x: 0, y: challengeView.frame.origin.y - 20), animated: true);
                pageTitle.text = "Join challenges";
                pageSubTitle.text = "Push yourself with challenges or compete with friends for sweet prizes";
            case 4:
                dashboardAlpha = 1;
                bodyStatsAlpha = 1;
                phoneScrollView.setContentOffset(CGPoint(x: 0, y: bodyStatsView.frame.origin.y - 20), animated: true);
                pageTitle.text = "Track your body stats";
                pageSubTitle.text = "Keep track of your body stats like blood pressure and weight to see progress";
            default:
                let i = 0;
        }

        pageTitle.alpha = 0;
        pageSubTitle.alpha = 0;
        UIView.animateWithDuration(animDuration, animations: {
            self.pageTitle.alpha = 1.0;
        });
        UIView.animateWithDuration(animDuration, animations: {
            self.pageSubTitle.alpha = 1.0;
        });

        UIView.animateWithDuration(animDuration, animations: {
            self.phoneContainer.alpha = phoneAlpha;
        });
        UIView.animateWithDuration(animDuration, animations: {
            self.mapView.alpha = mapAlpha;
        });
        UIView.animateWithDuration(animDuration, animations: {
            self.dashboardView.alpha = dashboardAlpha;
        });
        activityView.alpha = activityAlpha;
        challengeView.alpha = challengesAlpha;
        bodyStatsView.alpha = bodyStatsAlpha;
        pulseView.alpha = pulseAlpha;
        
        scrollView.setContentOffset(frame.origin, animated: false);
    }
    
    @IBAction func gotoLogin(sender: AnyObject) {
        Flurry.logEvent("Login_Pressed");
        self.navigationController!.pushViewController(LoginViewController(nibName: "LoginView", bundle: nil), animated: true);
    }
    
    @IBAction func gotoSignup(sender: AnyObject) {
        Flurry.logEvent("Signup_Pressed");
        self.navigationController!.pushViewController(SignupEmailViewController(nibName: "SignupEmailView", bundle: nil), animated: true);
    }
    
}