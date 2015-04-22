import Foundation

class BodyStatsViewController: BaseViewController {
    
    var selectedType = BodyStatsType.BloodPressure;
    
    let cardMargin = 20;
    
    var firstCard, secondCard, thirdCard: UIView!;
    
    var views: [UIView] = [];
    
    let animationDuration = 0.5;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        navigationController!.interactivePopGestureRecognizer.enabled = false;
        navigationController!.interactivePopGestureRecognizer.delegate = self;
        var shareButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton;
        shareButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        shareButton.addTarget(self, action: "shareAction:", forControlEvents: UIControlEvents.TouchUpInside);
        shareButton.setBackgroundImage(UIImage(named: "btn_share_white.png"), forState: UIControlState.Normal);
        var shareButtonItem = UIBarButtonItem(customView: shareButton);
        self.navigationItem.rightBarButtonItem = shareButtonItem;
        setupGraphs();
        self.view.addSubview(portView);
        portView.pager.currentPage = currentPage;
        changePage(portView.pager);
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
        
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: self.view.frame.size.width);
        var graphFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.size.height - 25);
        landView.frame = frame;
        landView.scrollView.frame = frame;
        landView.scrollView.contentSize = CGSize(width: 5 * frame.size.width, height: frame.size.height);
        var bpLandGraphView = GraphView.createViewFromNib(false);
        bpLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(bpLandGraphView);
        bpLandGraphView.initializeView(BpGraphDelegate(), frame: frame, checkins: bps, isPortrait: false)
        graphViews.append(bpLandGraphView);
        
        frame.origin.x += frame.size.width;
        var pulseLandGraphView = GraphView.createViewFromNib(false);
        pulseLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(pulseLandGraphView);
        pulseLandGraphView.initializeView(PulseGraphDelegate(), frame: frame, checkins: bps, isPortrait: false)
        graphViews.append(pulseLandGraphView);
        
        frame.origin.x += frame.size.width;
        var mapLandGraphView = GraphView.createViewFromNib(false);
        mapLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(mapLandGraphView);
        mapLandGraphView.initializeView(MapGraphDelegate(), frame: frame, checkins: bps, isPortrait: false)
        graphViews.append(mapLandGraphView);
        
        frame.origin.x += frame.size.width;
        var weightLandGraphView = GraphView.createViewFromNib(false);
        weightLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(weightLandGraphView);
        weightLandGraphView.initializeView(WeightGraphDelegate(), frame: frame, checkins: weights, isPortrait: false)
        graphViews.append(weightLandGraphView);
        
        frame.origin.x += frame.size.width;
        var bmiLandGraphView = GraphView.createViewFromNib(false);
        bmiLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(bmiLandGraphView);
        bmiLandGraphView.initializeView(BmiGraphDelegate(), frame: frame, checkins: weights, isPortrait: false);
        graphViews.append(bmiLandGraphView);
        
        landView.scrollView.delegate = self;
        
        frame = portView.scrollView.bounds;
        var bpPortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(bpPortGraphView);
        bpPortGraphView.initializeView(BpGraphDelegate(), frame: frame, checkins: bps, isPortrait: true);
        graphViews.append(bpPortGraphView);
        
        frame.origin.x += portView.scrollView.frame.size.width;
        var pulsePortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(pulsePortGraphView);
        pulsePortGraphView.initializeView(PulseGraphDelegate(), frame: frame, checkins: bps, isPortrait: true);
        graphViews.append(pulsePortGraphView);
        
        frame.origin.x += portView.scrollView.frame.size.width;
        var mapPortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(mapPortGraphView);
        mapPortGraphView.initializeView(MapGraphDelegate(), frame: frame, checkins: bps, isPortrait: true);
        graphViews.append(mapPortGraphView);
        
        frame.origin.x += portView.scrollView.frame.size.width;
        var weightPortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(weightPortGraphView);
        weightPortGraphView.initializeView(WeightGraphDelegate(), frame: frame, checkins: weights, isPortrait: true);
        graphViews.append(weightPortGraphView);
        
        frame.origin.x += portView.scrollView.frame.size.width;
        var bmiPortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(bmiPortGraphView);
        bmiPortGraphView.initializeView(BmiGraphDelegate(), frame: frame, checkins: weights, isPortrait: true);
        graphViews.append(bmiPortGraphView);
        
        portView.scrollView.delegate = self;
        
        if (SessionController.Instance.checkins.count == 0) {
            portView.orientationIndicator.hidden = true;
        }
        
        
    }
    
    @IBAction func rangeClick(sender: AnyObject) {
        
        if (!isPortrait) {
            landView.button1m.setBackgroundImage(nil, forState: UIControlState.Normal);
            landView.button3m.setBackgroundImage(nil, forState: UIControlState.Normal);
            landView.button6m.setBackgroundImage(nil, forState: UIControlState.Normal);
            landView.buttonAll.setBackgroundImage(nil, forState: UIControlState.Normal);
            (sender as! UIButton).setBackgroundImage(UIImage(named: "graph_timespan_bg"), forState: UIControlState.Normal);
            var range = 0;
            if (sender as! NSObject == landView.button1m) {
                range = 0;
            } else if (sender as! NSObject == landView.button3m) {
                range = 1;
            } else if (sender as! NSObject == landView.button6m) {
                range = 2;
            } else {
                range = 3;
            }
            var delegateSet = false;
            for graphView in graphViews {
                graphView.setRange(range, delegate: (delegateSet ? self : nil));
                delegateSet = true;
            }
            var cardFrame = UIScreen.mainScreen().bounds;
            cardFrame.size.width = cardFrame.size.width - CGFloat((BodyStatsType.allValues.count - 1 - pos) * cardMargin);

            let card = UIView(frame: cardFrame);
            card.backgroundColor = Utility.colorFromBodyStatType(type);
            
//            let card = BodyStatCard.instanceFromNib(cardFrame);
//            card.setupGraph(type);
            
            card.tag = pos;
            let tap = UITapGestureRecognizer(target: self, action: "cardClicked:");
            card.addGestureRecognizer(tap);
            
            let layer = card.layer;
            layer.shadowOffset = CGSize(width: 1,height: 1);
            layer.shadowColor = UIColor.blackColor().CGColor;
            layer.shadowRadius = 4;
            layer.shadowOpacity = 0.8;
            layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath;
            
            self.view.addSubview(card);
            pos--;
        }
        
        moveCards(selectedCardPosition);
    }
    
    func animationDidUpdate(operation: CPTAnimationOperation!) {
        setSelected(selected);
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        var pager = isPortrait ? portView.pager : landView.pager;
        pager.currentPage = page;
        changePage(pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as! UIPageControl;
        var page = pager.currentPage;
        self.title = titles[page];
        landView.titleLabel.text = titles[page];
        
        var frame = isPortrait ? portView.scrollView.frame : landView.scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        if (isPortrait) {
            portView.scrollView.setContentOffset(frame.origin, animated: true);
        } else {
            landView.scrollView.setContentOffset(frame.origin, animated: true);
        }
        
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
        moveCards(sender.view!!.tag);
    }

    func moveCards(selectedIndex: Int) {
        if (selectedIndex == 0) {
            return;
        } else if (selectedIndex == BodyStatsType.allValues.count - 1) {
            //case where last card selected -- swap first and last
            let subViews = self.view.subviews;
            let count = BodyStatsType.allValues.count;
            
            let firstCard = subViews[subViews.count - 1] as! UIView;
            firstCard.tag = count - 1;
            firstCard.frame = UIScreen.mainScreen().bounds;
            
            let lastCard = subViews[0] as! UIView;
            lastCard.tag = 0;
            let newWidth = UIScreen.mainScreen().bounds.size.width - CGFloat((count - 1) * self.cardMargin);
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                lastCard.frame.size.width = newWidth;
                lastCard.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
                }, completion:  { complete in
                    
            });
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false;
    }
    
    func setSelected(selected: HigiCheckin) {
        self.selected = selected;
        for graphView in graphViews {
            graphView.setSelectedCheckin(selected);
        }
    }
    
    func exportData() -> NSURL {
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyy";
        var contents = "Date,Location,Address of higi Station,Systolic Pressure (mmHg),Diastolic Pressure (mmHg),Pulse (bpm),Mean Arterial Pressure (mmHg), Weight (lbs),Body Mass Index\n";
        
        for index in reverse(0..<SessionController.Instance.checkins.count) {
            var checkin = SessionController.Instance.checkins[index];
            var address = "", systolic = "", diastolic = "", pulse = "", map = "", weight = "", bmi = "";
            var organization = checkin.sourceVendorId!;
            if (checkin.kioskInfo != nil) {
                organization = checkin.kioskInfo!.organizations[0];
                address = "\"\(checkin.kioskInfo!.fullAddress)\"";
            }
            
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
                let newWidth = UIScreen.mainScreen().bounds.size.width - CGFloat((index + 1) * self.cardMargin);
                
                if (index == count - 2) {
                    UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                        card.frame.size.width = newWidth;
                        card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
                        }, completion:  { complete in
                            
                    });
                } else {
                    card.frame.size.width = newWidth;
                    card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
                }
                card.tag = index + 1;
            }
            
            self.view.insertSubview(firstCard, atIndex: 0);
        }
    }
    
    func getShareFilePath() -> String {
        var docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String;
        return docPath.stringByAppendingPathComponent("higi_results.csv");
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        let subViews = self.view.subviews;
        let count = BodyStatsType.allValues.count;
        for index in 0...count - 1 {
            let card = subViews[index] as! UIView;
            let newWidth = UIScreen.mainScreen().bounds.size.width - CGFloat((index) * self.cardMargin);
            card.frame.size.width = newWidth;
            card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
            
//            if (index == count - 2) {
//                UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
//                    card.frame.size.width = newWidth;
//                    card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
//                    }, completion:  { complete in
//                        
//                });
//            } else {
//                card.frame.size.width = newWidth;
//                card.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: newWidth, height: UIScreen.mainScreen().bounds.size.height)).CGPath;
//            }
//            card.tag = index + 1;
        }
    }
}