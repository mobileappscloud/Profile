import Foundation

class MetricsViewController: UIViewController {
    
    var selectedType = MetricsType.allOldValues[0];
    
    let cardMargin = 46;
    
    let animationDuration = 0.5, detailsOpenAnimationDuration = 0.25;
    
    var detailsCard: MetricDetailCard!;
    
    var cardsTransitioning = false, detailsOpen = false, detailsGone = false, previousShouldRotate: Bool!;

    let cardHeaderViewHeight:CGFloat = 51.0, cardDragThreshold:CGFloat = 300, detailDragThreshold:CGFloat = 50;
    var detailsCardPosY:CGFloat = 0.0;
    
    var screenWidth:CGFloat!, screenHeight: CGFloat!;
    
    var previousSupportedOrientations: UIInterfaceOrientationMask!;
    
    var previousActualOrientation: UIInterfaceOrientation!, selectedCardPosition = 0;
    
    var universalLinkCheckinsObserver: NSObjectProtocol? = nil
    var universalLinkActivitiesObserver: NSObjectProtocol? = nil
    
    var revealController:RevealViewController!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        revealController = (self.navigationController as? MainNavigationController)?.revealController;
        previousSupportedOrientations = revealController?.supportedOrientations;
        previousShouldRotate = revealController?.shouldRotate;
        previousActualOrientation = UIApplication.sharedApplication().statusBarOrientation;
        
        screenWidth = max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        screenHeight = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        
        detailsCardPosY = screenHeight - cardHeaderViewHeight;
        initCards();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.navigationController!.navigationBarHidden = true;
        let revealController = (self.navigationController as! MainNavigationController).revealController;
        revealController.panGestureRecognizer().enabled = false;
        revealController.shouldRotate = true;
        revealController.supportedOrientations = UIInterfaceOrientationMask.LandscapeRight;
        revealController.preferredOrientation = UIInterfaceOrientation.LandscapeRight;
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation");
        UIViewController.attemptRotationToDeviceOrientation();
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (detailsCard != nil && !detailsCard.blankState && !detailsOpen) {
            detailsCard.animateBounceIn(detailsCardPosY);
            detailsGone = false;
        }
    }

    override func viewWillDisappear(animated: Bool) {
        prepareOrientationForLeaving();
        self.navigationController?.navigationBarHidden = false;
        super.viewWillDisappear(animated);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func shouldAutorotate() -> Bool {
        return true;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeRight;
    }
    
    func initCards() {
        var heaviest = 1.0, thinnest = 100.0, fattest = 1.0;
        for checkin in SessionController.Instance.checkins {
            if (checkin.weightLbs != nil && checkin.weightLbs > heaviest) {
                heaviest = checkin.weightLbs!;
            }
            if (checkin.fatRatio != nil && checkin.fatRatio > fattest) {
                fattest = checkin.fatRatio!;
            }
            if (checkin.fatRatio != nil && checkin.fatRatio < thinnest) {
                thinnest = checkin.fatRatio!;
            }
        }
        var bpPoints:[GraphPoint] = [], bpAltPoints:[GraphPoint] = [], pulsePoints:[GraphPoint] = [], weightPoints:[GraphPoint] = [], fatPoints:[GraphPoint] = [], fatAltPoints:[GraphPoint] = [];
        var lastBpDate:NSTimeInterval = 0, lastPulseDate:NSTimeInterval = 0, lastWeightDate:NSTimeInterval = 0, lastFatDate:NSTimeInterval = 0;
        let normalizeFactor = (1 + (fattest - thinnest) / 150.0);
        for checkin in Array(SessionController.Instance.checkins.reverse()) {
            let checkinTime = checkin.dateTime.timeIntervalSince1970;
            let checkinDate = checkinTime - (checkinTime % 86400);
            if (checkin.map != nil && checkinDate != lastBpDate) {
                bpPoints.append(GraphPoint(x: checkinTime, y: checkin.map!));
                if let diastolic = checkin.diastolic {
                    bpAltPoints.append(GraphPoint(x: checkinTime, y: Double(diastolic)));
                    bpAltPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.systolic!)));
                } else {
                    bpAltPoints.append(GraphPoint(x: checkinTime, y: 0));
                    bpAltPoints.append(GraphPoint(x: checkinTime, y: 0));
                }
                lastBpDate = checkinDate;
            }
            if (checkin.pulseBpm != nil && checkinDate != lastPulseDate) {
                pulsePoints.append(GraphPoint(x: checkinTime, y: Double(checkin.pulseBpm!)));
                lastPulseDate = checkinDate;
            }
            if (checkin.weightLbs != nil && checkinDate != lastWeightDate) {
                weightPoints.append(GraphPoint(x: checkinTime, y: checkin.weightLbs!));
                fatAltPoints.append(GraphPoint(x: checkinTime, y: 10 + (checkin.weightLbs! / heaviest) * fattest * normalizeFactor));
                lastWeightDate = checkinDate;
            }
            if (checkin.fatRatio != nil && checkinDate != lastFatDate) {
                fatPoints.append(GraphPoint(x: checkinTime, y: checkin.fatRatio!));
                lastFatDate = checkinDate;
            }
        }
        var activityPoints:[GraphPoint] = [];
        for (date, activitySummary) in SessionController.Instance.activities {
            let activities = activitySummary.activities
            let total = activitySummary.totalPoints
            if (activities.count > 0) {
                let activityDate = Double(Constants.dateFormatter.dateFromString(date)!.timeIntervalSince1970);
                activityPoints.append(GraphPoint(x: activityDate, y: Double(total)));
            }
        }
        activityPoints.sortInPlace({$0.x > $1.x});
        for subView in self.view.subviews {
            subView.removeFromSuperview();
        }
        var pos = MetricsType.allOldValues.count - 1;
        var card: MetricCard?;
        for type in Array(MetricsType.allOldValues.reverse()) {
            let cardFrame = CGRect(x: 0, y: 0, width: screenWidth - CGFloat((MetricsType.allOldValues.count - 1 - pos) * cardMargin), height: detailsCardPosY - 1);
            switch(type) {
            case MetricsType.DailySummary:
                card = MetricCard.instanceFromNib(ActivityMetricDelegate(), frame: cardFrame, points: activityPoints, altPoints: []);
            case MetricsType.BloodPressure:
                card = MetricCard.instanceFromNib(BpMetricDelegate(), frame: cardFrame, points: bpPoints, altPoints: bpAltPoints);
            case MetricsType.Pulse:
                card = MetricCard.instanceFromNib(PulseMetricDelegate(), frame: cardFrame, points: pulsePoints, altPoints: []);
            case MetricsType.Weight:
                let delegate = WeightMetricDelegate();
                card = MetricCard.instanceFromNib(delegate, frame: cardFrame, points: weightPoints, altPoints: []);
                if let secondaryGraph = delegate.getSecondaryGraph(cardFrame, points: fatPoints, altPoints: fatAltPoints) {
                    card!.secondaryGraph = secondaryGraph;
                    card!.secondaryGraph.hidden = true;
                    if secondaryGraph.points.count > 0 {
                        card!.toggleButton.hidden = false;
                        card!.triangleView.hidden = false;
                    }
                    card!.graphContainer.addSubview(secondaryGraph);
                }
                
            case MetricsType.BodyMassIndex:
                fallthrough
            case MetricsType.BodyFat:
                break
            }
            if (type == selectedType) {
                selectedCardPosition = pos;
            }
            card!.backButton.addTarget(self, action: "backButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
            card!.position = pos;
            self.view.addSubview(card!);
            pos--;
        }
        if (card != nil) {
            detailsCard = initDetailCard(card!);
            detailsCard.frame.origin.y = screenHeight;
            detailsGone = true;
            self.view.addSubview(detailsCard);
        }
        cardClickedAtIndex(selectedCardPosition);
    }
    
    func backButtonClicked(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    func cardClickedAtIndex(index: Int) {
        if (index == 0) {
            return;
        } else {
            if (detailsOpen) {
                closeDetails();
            }
            detailsCard.headerContainer.alpha = 0.5;
            let subViews = self.view.subviews;
            let count = MetricsType.allOldValues.count;
            let distance = count - index;
            var viewsToSend:[MetricCard] = [];
            for index in distance...count - 1 {
                viewsToSend.append(subViews[index] as! MetricCard);
            }
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                for card in viewsToSend {
                    card.frame.origin.x = -self.screenWidth;
                }
                }, completion:  { complete in
                    
                    for card in Array(viewsToSend.reverse()) {
                        card.frame.origin.x = 0;
                        card.headerView.frame.size.width = self.screenWidth;
                        card.frame.size.width = self.screenWidth;
                        self.view.insertSubview(card, atIndex: 0);
                        card.headerView.layoutIfNeeded();
                    }
                    
                    for index in 0...count - 1 {
                        let card = subViews[index] as! MetricCard;
                        card.position = index;
                        let newWidth = self.screenWidth - CGFloat((index + 1) * self.cardMargin);
                        UIView.animateWithDuration(self.animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                            card.headerView.frame.size.width = newWidth;
                            card.frame.size.width = newWidth;
                            card.icon.frame.origin.x = newWidth - 8 - card.icon.frame.size.width;
                            }, completion:  nil );
                    }
                    self.updateDetailCard();
                    self.detailsCard.headerContainer.alpha = 1;
            });
        }
    }
    
    func cardDragged(index: Int, translation: CGPoint) {
        if (index == 0) {
            let topCard = self.view.subviews[self.view.subviews.count - 2] ;
            if (topCard.frame.origin.x + translation.x < -cardDragThreshold) {
                if (!cardsTransitioning) {
                    cardClickedAtIndex(index + 1);
                    cardsTransitioning = true;
                }
            }
            if (topCard.frame.origin.x + translation.x < 0) {
                topCard.frame.origin.x += translation.x;
            } else {
                topCard.frame.origin.x = 0;
            }
        } else if (index != MetricsType.allOldValues.count - 1) {
            for i in 0...index {
                let card = self.view.subviews[self.view.subviews.count - (2 + i)] ;
                card.center.x += translation.x;
                if (card.frame.origin.x + translation.x < -cardDragThreshold) {
                    if (!cardsTransitioning) {
                        cardClickedAtIndex(index + 1);
                        cardsTransitioning = true;
                    }
                    break;
                } else if (card.frame.origin.x + translation.x < 0) {
                    card.frame.origin.x += CGFloat(translation.x) + (CGFloat(index - i) * CGFloat(translation.x));
                } else {
                    card.frame.origin.x = 0;
                }
            }
        }
        detailsCard.headerContainer.alpha = (screenWidth + translation.x) / screenWidth * 0.5;
    }

    func doneDragging(index: Int) {
        if (index == 0) {
            let topCard = self.view.subviews[self.view.subviews.count - 2] ;
            if (topCard.frame.origin.x >= -cardDragThreshold) {
                topCard.frame.origin.x = 0;
            }
        } else {
            let draggedCard = self.view.subviews[self.view.subviews.count - (2 + index)] ;
            if (draggedCard.frame.origin.x >= -cardDragThreshold) {
                for i in 0...index {
                    let card = self.view.subviews[self.view.subviews.count - (2 + i)] ;
                    card.frame.origin.x = 0;
                }
            }
        }
        detailsCard.headerContainer.alpha = 1;
        cardsTransitioning = false;
    }

    func updateDetailCard() {
        detailsCard.setMetricType(getCurrentCard().delegate);

        if (detailsGone) {
            if detailsCard.blankState {
                detailsCard.frame.origin.y = screenHeight;
                detailsGone = true;
            } else {
                detailsCard.animateBounceIn(detailsCardPosY);
                detailsGone = false;
            }
        } else if detailsCard.blankState {
            detailsCard.animateBounceOut();
            detailsGone = true;
        }
    }

    func setDetailsCardPoint() {
        if (detailsCard != nil) {
            detailsCard.updateCard(getCurrentCard());
        }
    }
    
    func getCurrentCard() -> MetricCard {
        return self.view.subviews[self.view.subviews.count - 2] as! MetricCard;
    }

    func initDetailCard(card: MetricCard) -> MetricDetailCard {
        let detailCard = MetricDetailCard.instanceFromNib(card);
        detailCard.frame.origin.y = detailsOpen ? cardHeaderViewHeight : detailsCardPosY;
        detailCard.frame.size.height = screenHeight - cardHeaderViewHeight;
        let tap = UITapGestureRecognizer(target: self, action: "detailsTapped:");
        let drag = UIPanGestureRecognizer(target: self, action: "detailDragged:");
        
        detailCard.headerContainer.addGestureRecognizer(drag);
        detailCard.headerContainer.addGestureRecognizer(tap);
        return detailCard;
    }

    func sendViewsToBack(views: [UIView]) {
        for view in views {
            self.view.sendSubviewToBack(view);
        }
    }
    
    func detailDragged(sender: AnyObject) {
        let translation = (sender as! UIPanGestureRecognizer).translationInView(self.view).y;
        if (detailsCard.frame.origin.y + translation <= cardHeaderViewHeight) {
            openDetails();
        } else if (detailsCard.frame.origin.y + translation >= self.detailsCardPosY) {
            closeDetails();
        } else if (sender.state == UIGestureRecognizerState.Ended) {
            if ((detailsOpen && detailsCard.frame.origin.y >= cardHeaderViewHeight + detailDragThreshold) ) {
                closeDetails();
            } else if (!detailsOpen && detailsCard.frame.origin.y <= self.detailsCardPosY - detailDragThreshold) {
                openDetails();
            } else if detailsOpen {
                openDetails();
            } else {
                closeDetails();
            }
        } else if (sender.state != UIGestureRecognizerState.Began) {
            let translation = (sender as! UIPanGestureRecognizer).translationInView(self.view).y;
            detailsCard.frame.origin.y += translation;
            if (detailsCard.frame.origin.y + translation <= cardHeaderViewHeight) {
                openDetails();
            } else if (detailsCard.frame.origin.y + translation >= self.detailsCardPosY) {
                closeDetails();
            }
        }
        sender.setTranslation(CGPointZero, inView: self.view);
    }
    
    func detailsTapped(sender: AnyObject) {
        if (!detailsOpen) {
            openDetails();
        } else {
            closeDetails();
        }
    }
    
    func detailsSwiped(sender: AnyObject) {
        let swipe = (sender as! UISwipeGestureRecognizer).direction;
        if (detailsOpen && swipe == UISwipeGestureRecognizerDirection.Down) {
            closeDetails();
        } else if (!detailsOpen && swipe == UISwipeGestureRecognizerDirection.Up) {
            openDetails();
        }
    }
    
    func openDetailsIfClosed() {
        if (!detailsOpen) {
            openDetails();
        }
    }
    
    func openDetails() {
        UIView.animateWithDuration(detailsOpenAnimationDuration, delay: 0, options: .CurveEaseInOut, animations: {
            self.detailsCard.frame.origin.y = self.cardHeaderViewHeight - 1;
            }, completion: nil);
        detailsOpen = true;
        detailsCard.setPanelHeaders(detailsOpen);
        detailsCard.updateCopyImageIfNeeded();
    }
    
    func closeDetails() {
        UIView.animateWithDuration(detailsOpenAnimationDuration, delay: 0, options: .CurveEaseInOut, animations: {
            self.detailsCard.frame.origin.y = self.detailsCardPosY;
            }, completion: nil);
        detailsOpen = false;
        detailsCard.setPanelHeaders(detailsOpen);
    }
    
    func setDetailsHeader() {
        detailsCard.setPanelHeaders(detailsOpen);
    }
    
    func showDetailsCard() {
        UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseInOut, animations: {
            self.detailsCard.frame.origin.y = self.detailsCardPosY;
            }, completion: nil);
        detailsCard.frame.origin.y = self.detailsCardPosY;
    }
    
    func prepareForPortraitOrientation() {
        let revealController = (self.navigationController as! MainNavigationController).revealController;
        revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait;
        revealController.shouldRotate = true;
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation");
        UIViewController.attemptRotationToDeviceOrientation();
        revealController.shouldRotate = false;
    }

    func prepareOrientationForLeaving() {
        revealController.supportedOrientations = previousSupportedOrientations;
        revealController.shouldRotate = true;
        UIDevice.currentDevice().setValue(previousActualOrientation.rawValue, forKey: "orientation");
        UIViewController.attemptRotationToDeviceOrientation();
        revealController.shouldRotate = previousShouldRotate;
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        let subViews = self.view.subviews;
        let count = MetricsType.allOldValues.count;
        for index in 0...count - 1 {
            if index < subViews.count - 1 {
                let card = subViews[index] as! MetricCard;
                let newWidth = screenWidth - CGFloat((index) * self.cardMargin);
                card.frame.size.width = newWidth;
                card.headerView.frame.size.width = newWidth;
                card.position = count - 1 - index;
                card.graphContainer.frame.size.width = screenWidth;
                if card.graph != nil {
                    card.graph.frame.size.width = screenWidth;
                }
                if card.secondaryGraph != nil {
                    card.secondaryGraph.frame.size.width = screenWidth;
                }
            }
        }
    }
}

extension MetricsViewController: UniversalLinkHandler {
    
    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?) {
        
        var loadedActivities = false
        var loadedCheckins = false
        let application = UIApplication.sharedApplication().delegate as! AppDelegate
        if application.didRecentlyLaunchToContinueUserActivity() {
            let loadingViewController = self.presentLoadingViewController()
            
            self.universalLinkActivitiesObserver = NSNotificationCenter.defaultCenter().addObserverForName(ApiUtility.ACTIVITIES, object: nil, queue: nil, usingBlock: { (notification) in
                loadedActivities = true
                self.pushMetricsView(pathType, loadedActivites: loadedActivities, loadedCheckins: loadedCheckins, presentedViewController: loadingViewController)
                if let observer = self.universalLinkActivitiesObserver {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
            })
            self.universalLinkCheckinsObserver = NSNotificationCenter.defaultCenter().addObserverForName(ApiUtility.CHECKINS, object: nil, queue: nil, usingBlock: { (notification) in
                loadedCheckins = true
                self.pushMetricsView(pathType, loadedActivites: loadedActivities, loadedCheckins: loadedCheckins, presentedViewController: loadingViewController)
                if let observer = self.universalLinkCheckinsObserver {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
            })
        } else {
            self.pushMetricsView(pathType, loadedActivites: true, loadedCheckins: true, presentedViewController: nil)
        }
    }
    
    private func pushMetricsView(pathType: PathType, loadedActivites: Bool, loadedCheckins: Bool, presentedViewController: UIViewController?) {
        if !loadedActivites || !loadedCheckins {
            return
        }
        
        let metricsViewController = MetricsViewController(nibName: "MetricsView", bundle: nil);
        
        let targetMetricsType: MetricsType
        switch pathType {
        case .MetricsBloodPressure:
            targetMetricsType = .BloodPressure;
        case .MetricsPulse:
            targetMetricsType = .Pulse;
        case .MetricsWeight:
            targetMetricsType = .Weight;
        default:
            targetMetricsType = .DailySummary;
        }
        
        metricsViewController.selectedType = targetMetricsType

        dispatch_async(dispatch_get_main_queue(), {
            Utility.mainNavigationController()?.revealController.setFrontViewPosition(.Left, animated: false)
            
            presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            Utility.mainNavigationController()?.drawerController.navController?.popToRootViewControllerAnimated(true)
            Utility.mainNavigationController()?.drawerController.navController?.pushViewController(metricsViewController, animated: false)
        })
    }
}
