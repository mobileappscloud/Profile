import Foundation

class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var firstScreen: WelcomeFirstView!;
    
    var secondScreen, thirdScreen, fourthScreen, fifthScreen: WelcomeView!;
    
    var didAnimate = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        firstScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[1] as WelcomeFirstView;
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {
            
            self.firstScreen.bottomImage.alpha = 1.0;
            
            }, completion: nil);
        self.automaticallyAdjustsScrollViewInsets = false;
        firstScreen.bottomImage.image = Utility.iphone5Image("welcome_01_bg");
        secondScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
        secondScreen.bottomImage.image = Utility.iphone5Image("welcome_02_bg");
        secondScreen.topImage.image = Utility.iphone5Image("welcome_02_text");
        thirdScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
        thirdScreen.bottomImage.image = Utility.iphone5Image("welcome_03_bg");
        thirdScreen.topImage.image = Utility.iphone5Image("welcome_03_text");
        fourthScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[2] as WelcomeView;
        fourthScreen.bottomImage.image = Utility.iphone5Image("welcome_04_bg");
        fourthScreen.topImage.image = Utility.iphone5Image("welcome_04_text");
        fifthScreen = UINib(nibName: "Welcome", bundle: nil).instantiateWithOwner(self, options: nil)[1] as WelcomeFirstView;
        fifthScreen.bottomImage.image = Utility.iphone5Image("welcome_05_bg");
        fifthScreen.topImage.image = Utility.iphone5Image("welcome_05_text");
        
        scrollView.addSubview(firstScreen);
        scrollView.addSubview(secondScreen);
        scrollView.addSubview(thirdScreen);
        scrollView.addSubview(fourthScreen);
        scrollView.addSubview(fifthScreen);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        self.navigationController!.navigationBar.hidden = true;
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        var frame = self.view.frame
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
        
        
        if (!didAnimate) {
        
            firstScreen.bottomImage.alpha = 0;
            loginButton.alpha = 0;
            signupButton.alpha = 0;
            
            UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                self.firstScreen.bottomImage.alpha = 1.0;
                self.loginButton.alpha = 1.0;
                self.signupButton.alpha = 1.0;
                
                }, completion: nil);
            didAnimate = true;
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController!.navigationBar.hidden = true;
        firstScreen.swipeArrow.layer.removeAllAnimations();
        firstScreen.swipeText.alpha = 0.0;
        firstScreen.swipeArrow.alpha = 0.0;
        UIView.animateWithDuration(1.0, delay: 2.0, options: .CurveEaseInOut, animations: {
            
            self.firstScreen.swipeText.alpha = 1.0;
            self.firstScreen.swipeArrow.alpha = 1.0;
            
            }, completion: {(arg: Bool) in
                
                UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut | .Repeat, animations: {
                    
                    self.firstScreen.swipeArrow.frame.origin.x = -20;
                    self.firstScreen.swipeArrow.alpha = 0.0;
                    
                    }, completion: nil);
                
        });
        if (pageControl.currentPage == 1) {
            self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        } else {
            self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        pageControl.currentPage = page;
        changePage(pageControl);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        var page = pageControl.currentPage;
        var offset = scrollView.contentOffset.x - scrollView.frame.size.width * CGFloat(page);
        offset *= 0.5;
        if (page == 0) {
            (scrollView.subviews[page] as WelcomeFirstView).swipeText.frame.origin.x = -offset;
        } else if (page < 5) {
            (scrollView.subviews[page] as WelcomeView).topImage.frame.origin.x = -offset;
        }
        if (offset < 0 && page > 0) {
            if (page == 1) {
                (scrollView.subviews[page - 1] as WelcomeFirstView).swipeText.frame.origin.x = -scrollView.frame.size.width / 2 - offset;
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
        
        scrollView.setContentOffset(frame.origin, animated: true);
        if (page == 1) {
            self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        } else {
            self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        }
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