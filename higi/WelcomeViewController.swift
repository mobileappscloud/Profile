import Foundation

class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var buttonSeparator: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageSubTitle: UILabel!

    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var phoneScrollView: UIScrollView!
    
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var welcomeSubTitle: UILabel!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var stationView: UIImageView!
    var dashboardView:UIView!;
    var activityView:UIImageView!;
    var challengeView:UIImageView!;
    var bodyStatsView:UIImageView!;
    var pulseView:UIImageView!;
    
    var didAnimate = false;
    let animDuration = 0.25;
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
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
        let phoneWidth = phoneScrollView.frame.size.width;
        let phoneHeight = phoneScrollView.frame.size.height;
        
        dashboardView = UIView(frame: CGRect(x: 0, y: 2, width: phoneScrollView.frame.size.width, height: phoneScrollView.frame.size.height - 5));
        var yPos:CGFloat = 2;
        let imageMargin:CGFloat = 10;
        let imageWidth = dashboardView.frame.size.width;
        
        var imageHeight:CGFloat = 150;
        activityView = UIImageView(frame: CGRect(x: 0, y: yPos, width: imageWidth, height: 150));
        let activityCard = UIImage(named: "todayactivity");
        activityView.image = activityCard;
        dashboardView.addSubview(activityView);
        yPos += imageHeight + imageMargin;

        imageHeight = 142;
        challengeView = UIImageView(frame: CGRect(x: 0, y: yPos, width: imageWidth, height: imageHeight));
        let challengeCard = UIImage(named: "activechallenges");
        challengeView.image = challengeCard;
        dashboardView.addSubview(challengeView);
        yPos += imageHeight + imageMargin;
        
        imageHeight = 172;
        bodyStatsView = UIImageView(frame: CGRect(x: 0, y: yPos, width: imageWidth, height: imageHeight));
        let bodyStatsCard = UIImage(named: "bodystats");
        bodyStatsView.image = bodyStatsCard;
        dashboardView.addSubview(bodyStatsView);
        yPos += imageHeight + imageMargin;
        
        pulseView = UIImageView(frame: CGRect(x: 0, y: yPos, width: imageWidth, height: imageHeight));
        let pulseCard = UIImage(named: "pulse_article");
        pulseView.image = pulseCard;
        dashboardView.addSubview(pulseView);
        
        phoneContainer.alpha = 0;
        dashboardView.alpha = 0;
        
        phoneScrollView.addSubview(dashboardView);
        
        let leftScrollViewSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:");
        leftScrollViewSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left;
        let rightScrollViewSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:");
        rightScrollViewSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right;
        self.view.addGestureRecognizer(leftScrollViewSwipeRecognizer);
        self.view.addGestureRecognizer(rightScrollViewSwipeRecognizer);
        
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
        var pager = sender as UIPageControl;
        var page = pager.currentPage;
        var frame = self.view.frame;
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        
        var phoneAlpha:CGFloat = 1.0;
        var stationAlpha:CGFloat = 0;
        var dashboardAlpha:CGFloat = 0;
        var welcomeAlpha:CGFloat = 0;
        
        var activityAlpha:CGFloat = 0.3;
        var challengesAlpha:CGFloat = 0.3;
        var bodyStatsAlpha:CGFloat = 0.3;
        let pulseAlpha:CGFloat = 0.3;
        
        var title = "";
        var subTitle = "";
        
        switch page {
            case 0:
                //welcome
                welcomeAlpha = 1;
                phoneAlpha = 0;
                UIView.animateWithDuration(animDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.phoneContainer.alpha = 0;
                    }, completion: nil);
            case 1:
                //station
                stationAlpha = 1;
                activityAlpha = 1;
                dashboardAlpha = 0;
                phoneAlpha = 0;
                title = "Get Started";
                subTitle = "Visit a higi Station at your local pharmacy or connect a fitness tracker here in the app.";
            case 2:
                //activity
                dashboardAlpha = 1;
                activityAlpha = 1;
                title = "Earn Points";
                subTitle = "Rack up the points with each check of your vitals and for your steps and workouts.";
                phoneScrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true);
            case 3:
                //challenges
                dashboardAlpha = 1;
                challengesAlpha = 1;
                title = "Chart Your Progress";
                subTitle = "Easily track trends and changes in your body stats you receive from a higi Station.";
                phoneScrollView.setContentOffset(CGPoint(x: 0, y: challengeView.frame.origin.y - 20), animated: true);
            case 4:
                //body stats
                dashboardAlpha = 1;
                bodyStatsAlpha = 1;
                title = "Track your body stats";
                subTitle = "Keep track of your body stats like blood pressure and weight to see progress";
                phoneScrollView.setContentOffset(CGPoint(x: 0, y: bodyStatsView.frame.origin.y - 20), animated: true);
            default:
                let i = 0;
        }

        UIView.animateWithDuration(animDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
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
                UIView.animateWithDuration(self.animDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.pageTitle.alpha = 1.0;
                    self.pageSubTitle.alpha = 1.0;
                    self.activityView.alpha = activityAlpha;
                    self.challengeView.alpha = challengesAlpha;
                    self.bodyStatsView.alpha = bodyStatsAlpha;
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
        self.navigationController!.pushViewController(LoginViewController(nibName: "LoginView", bundle: nil), animated: true);
    }
    
    @IBAction func gotoSignup(sender: AnyObject) {
        Flurry.logEvent("Signup_Pressed");
        self.navigationController!.pushViewController(SignupEmailViewController(nibName: "SignupEmailView", bundle: nil), animated: true);
    }
    
}