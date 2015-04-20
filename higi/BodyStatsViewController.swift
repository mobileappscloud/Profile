import Foundation

class BodyStatsViewController: BaseViewController {
    
    var selectedType = BodyStatsType.BloodPressure;
    
    let cardMargin = 20;
    
    var firstCard, secondCard, thirdCard: UIView!;
    
    var views: [UIView] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.navigationController!.navigationBarHidden = true;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        revealController.panGestureRecognizer().enabled = false;
        revealController.supportedOrientations = UIInterfaceOrientationMask.LandscapeRight.rawValue;
        revealController.shouldRotate = true;
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation");
        
        var pos = BodyStatsType.allValues.count - 1;
        
        for subView in self.view.subviews {
            subView.removeFromSuperview();
        }
        
        for type in BodyStatsType.allValues {
            //            let card = UINib(nibName: "BodyStatCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BodyStatCard;
            //            card.setupGraph(type);
            
            var cardFrame = UIScreen.mainScreen().bounds;
            cardFrame.size.width = cardFrame.size.width - CGFloat((BodyStatsType.allValues.count - 1 - pos) * cardMargin);
            let card = UIView(frame: cardFrame);
            card.backgroundColor = Utility.colorFromBodyStatType(type);
            card.tag = pos;
            let tap = UITapGestureRecognizer(target: self, action: "cardClicked:");
            card.addGestureRecognizer(tap);
            self.view.addSubview(card);
            pos--;
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue;
        self.navigationController!.navigationBarHidden = false;
        self.view.setNeedsDisplay();
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation");
        super.viewWillDisappear(animated);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false;
    }
    
    func backButtonClick() {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    func cardClicked(sender: AnyObject) {
        let position = sender.view!!.tag;
        if (position == 0) {
            return;
        } else if (position == BodyStatsType.allValues.count - 1) {
            //case where last card selected -- swap first and last
            let subViews = self.view.subviews;
            let count = BodyStatsType.allValues.count;
            
            let firstCard = subViews[subViews.count - 1] as! UIView;
            firstCard.tag = count - 1;
            firstCard.frame = UIScreen.mainScreen().bounds;
        
            let lastCard = subViews[0] as! UIView;
            lastCard.tag = 0;
            lastCard.frame.size.width = UIScreen.mainScreen().bounds.size.width - CGFloat((count - 1) * cardMargin);
            
            self.view.insertSubview(firstCard, atIndex: 0);
            self.view.insertSubview(lastCard, atIndex: count - 1);
        } else {
            let subViews = self.view.subviews;
            let count = BodyStatsType.allValues.count;

            //send first card to back and update card widths according to position
            let firstCard = subViews[subViews.count - 1] as! UIView;
            firstCard.tag = subViews.count - 1;
            firstCard.frame = UIScreen.mainScreen().bounds;
            
            for index in 0...count - 2 {
                let card = subViews[index] as! UIView;
                card.frame.size.width = UIScreen.mainScreen().bounds.size.width - CGFloat((index + 1) * cardMargin);
                card.tag = index + 1;
            }
            
            self.view.insertSubview(firstCard, atIndex: 0);
        }
    }

    func sendViewsToBack(views: [UIView]) {
        for view in views {
            self.view.sendSubviewToBack(view);
        }
    }
}