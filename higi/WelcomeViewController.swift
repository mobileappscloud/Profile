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

    var firstScreen: WelcomeFirstView!;
    
    var secondScreen, thirdScreen, fourthScreen, fifthScreen: WelcomeView!;
    
    var didAnimate = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        
        firstScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[1] as WelcomeFirstView;
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {
            
//            self.firstScreen.bottomImage.alpha = 1.0;
            
            }, completion: nil);
        self.automaticallyAdjustsScrollViewInsets = false;
//        firstScreen.bottomImage.image = Utility.iphone5Image("welcome_01_bg");
        secondScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
//        secondScreen.bottomImage.image = Utility.iphone5Image("welcome_01_bg");
        secondScreen.topImage.image = Utility.iphone5Image("welcome_02_text");
        thirdScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
//        thirdScreen.bottomImage.image = Utility.iphone5Image("welcome_01_bg");
        thirdScreen.topImage.image = Utility.iphone5Image("welcome_03_text");
        fourthScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
//        fourthScreen.bottomImage.image = Utility.iphone5Image("welcome_01_bg");
        fourthScreen.topImage.image = Utility.iphone5Image("welcome_04_text");
        fifthScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[1] as WelcomeFirstView;
//        fifthScreen.bottomImage.image = Utility.iphone5Image("welcome_01_bg");
        fifthScreen.topImage.image = Utility.iphone5Image("welcome_05_text");
        
        scrollView.addSubview(firstScreen);
        scrollView.addSubview(secondScreen);
        scrollView.addSubview(thirdScreen);
        scrollView.addSubview(fourthScreen);
        scrollView.addSubview(fifthScreen);
        
        pageTitle.text = "";
        pageSubTitle.text = "";
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        self.navigationController!.navigationBar.hidden = true;
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        var frame = self.view.frame;
        scrollView.frame = frame;
        scrollView.contentSize = CGSize(width: 5 * frame.size.width, height: frame.size.height);
        firstScreen.frame = frame;
        frame.origin.x += self.view.frame.size.width;
        secondScreen.frame = frame;
        frame.origin.x += self.view.frame.size.width;
        thirdScreen.frame = frame;
        frame.origin.x += self.view.frame.size.width;
        fourthScreen.frame = frame;
        frame.origin.x += self.view.frame.size.width;
        fifthScreen.frame = frame;
        scrollView.layoutSubviews();
        loginButton.layer.borderColor = Utility.colorFromHexString("#BEBEBE").CGColor;
        signupButton.layer.borderColor = Utility.colorFromHexString("#4C8823").CGColor;
        
        pageControl.frame.origin.y = frame.origin.y + 20;
        buttonSeparator.frame.origin.y = signupButton.frame.origin.y - 1;
        
        if (!didAnimate) {
        
//            firstScreen.bottomImage.alpha = 0;
            loginButton.alpha = 0;
            signupButton.alpha = 0;
            welcomeText.alpha = 0;
            UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                
//                self.firstScreen.bottomImage.alpha = 1.0;
                self.loginButton.alpha = 1.0;
                self.signupButton.alpha = 1.0;
                self.welcomeText.alpha = 1.0;
                
                }, completion: nil);
            didAnimate = true;
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController!.navigationBar.hidden = true;
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        if (page != pageControl.currentPage) {
            pageControl.currentPage = page;
            changePage(pageControl);
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        var page = pageControl.currentPage;
        var offset = scrollView.contentOffset.x - scrollView.frame.size.width * CGFloat(page);
        offset *= 0.5;
        if (page == 0) {
//            (scrollView.subviews[page] as WelcomeFirstView).swipeText.frame.origin.x = -offset;
        } else if (page < 5) {
            (scrollView.subviews[page] as WelcomeView).topImage.frame.origin.x = -offset;
        }
        if (offset < 0 && page > 0) {
            if (page == 1) {
//                (scrollView.subviews[page - 1] as WelcomeFirstView).swipeText.frame.origin.x = -scrollView.frame.size.width / 2 - offset;
            } else {
                (scrollView.subviews[page - 1] as WelcomeView).topImage.frame.origin.x = -scrollView.frame.size.width / 2 - offset;
            }
        } else if (offset > 0 && page < 4){
            (scrollView.subviews[page + 1] as WelcomeView).topImage.frame.origin.x = scrollView.frame.size.width / 2 - offset;
        }
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as UIPageControl;
        var page = pager.currentPage;
        var frame = scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        
        switch page {
            case 0:
                pageTitle.text = "";
                pageSubTitle.text = "";
            case 1:
                pageTitle.text = "Find a higi Station";
                pageSubTitle.text = "Track your body stats and earn points";
            case 2:
                pageTitle.text = "Sync your fitness device";
                pageSubTitle.text = "Add a device and earn daily points";
            case 3:
                pageTitle.text = "Join challenges";
                pageSubTitle.text = "Push yourself with challenges or compete with friends for sweet prizes";
            case 4:
                pageTitle.text = "Track your body stats";
                pageSubTitle.text = "Keep track of your body stats like blood pressure and weight to see progress";
            default:
                let i = 0;
        }
        
        let duration = 0.5;
        pageTitle.alpha = 0;
        pageSubTitle.alpha = 0;
        UIView.animateWithDuration(duration, animations: {
            self.pageTitle.alpha = 1.0
        });
        UIView.animateWithDuration(0.5, animations: {
            self.pageSubTitle.alpha = 1.0
        });

        scrollView.setContentOffset(frame.origin, animated: true);
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