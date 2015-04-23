import Foundation

class BodyStatsViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    var selectedType = BodyStatsType.BloodPressure;
    
    let cardMargin = 20;
    
    var firstCard, secondCard, thirdCard: UIView!;
    
    var views: [UIView] = [];
    
    let animationDuration = 0.5;
    
    var recognizer:UISwipeGestureRecognizer!;
    
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
        
        for subView in self.view.subviews {
            subView.removeFromSuperview();
        }
        
        var selectedCardPosition = 0;
        var pos = BodyStatsType.allValues.count - 1;
        
        for type in BodyStatsType.allValues.reverse() {
            if (type == selectedType) {
                selectedCardPosition = pos;
            }
            var cardFrame = UIScreen.mainScreen().bounds;
            cardFrame.size.width = cardFrame.size.width - CGFloat((BodyStatsType.allValues.count - 1 - pos) * cardMargin);
            
            let card = BodyStatCard.instanceFromNib(cardFrame, type: type);
            card.backgroundColor = Utility.colorFromBodyStatType(type);
//            card.setupGraph(type);
            card.index = pos;
            
            let drag = UIPanGestureRecognizer(target: self, action: "cardDragged:");
            drag.delegate = self;
            card.addGestureRecognizer(drag);
            
            let layer = card.layer;
            layer.shadowOffset = CGSize(width: 1,height: 1);
            layer.shadowColor = UIColor.blackColor().CGColor;
            layer.shadowRadius = 4;
            layer.shadowOpacity = 0.8;
            layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath;
            
            self.view.addSubview(card);
            pos--;
        }
        
        cardClicked(selectedCardPosition);
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
    
    func cardClicked(selectedIndex: Int) {
        if (selectedIndex == 0) {
            return;
        } else {
            let subViews = self.view.subviews;
            let count = BodyStatsType.allValues.count;
            let distance = count - selectedIndex;
            var viewsToSend:[UIView] = [];
            
            for index in distance...count - 1 {
                viewsToSend.append(subViews[index] as! UIView);
            }
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                for card in viewsToSend {
                    card.frame.origin.x = -UIScreen.mainScreen().bounds.size.width;
                    card.layer.shadowPath = UIBezierPath(rect: CGRect(x: -UIScreen.mainScreen().bounds.size.width, y: 0, width: card.frame.size.width, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
                }
                }, completion:  { complete in
                    
                    for card in viewsToSend.reverse() {
                        card.frame.origin.x = 0;
                        card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: card.frame.size.width, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
                        self.view.insertSubview(card, atIndex: 0);
                    }
//
//                    for index in 0...count - 1 {
//                        let card = subViews[index] as! BodyStatCard;
//                        let newWidth = UIScreen.mainScreen().bounds.size.width - CGFloat((index + 1) * self.cardMargin);
//                        UIView.animateWithDuration(self.animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
//                            card.frame.size.width = newWidth;
//                            card.resizeFrameWithWidth(newWidth);
//                            card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
//                            }, completion:  { complete in
//                                
//                        });
//                    }
            });
        }
    }

    func cardDragged(index: Int) {
//        let translation = (self as! UIPanGestureRecognizer).translationInView(<#view: UIView#>)
//        let i = 9;
    }
    
    func translationInView(view: UIView) -> CGPoint {
        let i = 9;
        return CGPoint(x: 0,y: 0);
    }

    func sendViewsToBack(views: [UIView]) {
        for view in views {
            self.view.sendSubviewToBack(view);
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        let subViews = self.view.subviews;
        let count = BodyStatsType.allValues.count;
//        for index in 0...count - 1 {
//            let card = subViews[index] as! BodyStatCard;
//            let newWidth = UIScreen.mainScreen().bounds.size.width - CGFloat((index) * self.cardMargin);
//            card.frame.size.width = newWidth;
//            card.resizeFrameWithWidth(newWidth);
//            card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
//            card.index = count - 1 - index;
//        }
        for index in 0...count - 1 {
            let card = subViews[index] as! BodyStatCard;
            let newWidth = UIScreen.mainScreen().bounds.size.width - CGFloat((index) * self.cardMargin);
            UIView.animateWithDuration(self.animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                card.frame.size.width = newWidth;
                card.resizeFrameWithWidth(newWidth);
                card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
                }, completion:  { complete in
                    
            });
            card.index = count - 1 - index;
        }
    }
}