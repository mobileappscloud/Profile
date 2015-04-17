import Foundation

class BodyStatsViewController: BaseViewController {
    
    var selectedType = BodyStatsType.BloodPressure;
    
    let cardMargin = 20;
    
    var firstCard, secondCard, thirdCard: UIView!;
    
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
        
        for type in BodyStatsType.allValues {
            //            let card = UINib(nibName: "BodyStatCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BodyStatCard;
            //            card.setupGraph(type);
            
            var cardFrame = UIScreen.mainScreen().bounds;
            cardFrame.size.width = cardFrame.size.width - CGFloat((BodyStatsType.allValues.count - 1 - pos) * cardMargin);
            //            card.frame = cardFrame;
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
            
            //case where last card selected
            //send middle cards to back in order, then send first.  leave last card as is
            let subViews = self.view.subviews;
            let count = subViews.count;
            
            for i in 1...count - 2 {
                let index = count - 1 - i;
                let card = subViews[index] as! UIView;
                var cardFrame = UIScreen.mainScreen().bounds;
                cardFrame.size.width = cardFrame.size.width - CGFloat((index) * cardMargin);
                card.frame = cardFrame;
                card.tag = index;
                if (index < count - 1) {
                    self.view.sendSubviewToBack(card);
                }
            }
            let firstCard = subViews[0] as! UIView;
            firstCard.tag = count - 1;
            firstCard.frame = UIScreen.mainScreen().bounds;
            firstCard.backgroundColor = UIColor.greenColor();
            self.view.sendSubviewToBack(firstCard);
        } else {
            let subViews = self.view.subviews;
            let count = BodyStatsType.allValues.count;
            for index in 1...count - 1 {
                let card = subViews[index] as! UIView;
                var cardFrame = UIScreen.mainScreen().bounds;
                cardFrame.size.width = cardFrame.size.width - CGFloat((index + 1) * cardMargin);
                card.frame = cardFrame;
                card.tag = (index + 1) % count - 1;
            }
            let firstCard = subViews[0] as! UIView;
            var firstCardFrame = UIScreen.mainScreen().bounds;
            firstCardFrame.size.width = firstCardFrame.size.width - 1;
            firstCard.frame = firstCardFrame;
            firstCard.tag = count - 1;
//            let firstCard = subViews[0] as! UIView;
//            firstCard.tag = count - 1;
//            firstCard.frame = UIScreen.mainScreen().bounds;
            self.view.sendSubviewToBack(firstCard);
        }
//        viewDidLayoutSubviews();
    }
    
    func sendViewsToBack(views: [UIView]) {
        for view in views {
            self.view.sendSubviewToBack(view);
        }
    }
}