import Foundation

class MetricsViewController: UIViewController {
    
    var selectedType = MetricsType.allValues[0];
    
    let cardMargin = 46;
    
    let animationDuration = 0.5, detailsOpenAnimationDuration = 0.25;
    
    var detailsCard: MetricDetailCard!;
    
    var cardsTransitioning = false, detailsOpen = false, detailsGone = false, previousShouldRotate: Bool!;

    let detailsCardPosY:CGFloat = 267, cardHeaderViewHeight:CGFloat = 54, cardDragThreshold:CGFloat = 300, detailDragThreshold:CGFloat = 50;
    
    var screenWidth:CGFloat!, screenHeight: CGFloat!;
    
    var previousSupportedOrientations: UInt!;
    
    var previousActualOrientation: Int!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let revealController = (self.navigationController as! MainNavigationController).revealController;
        previousSupportedOrientations = revealController.supportedOrientations;
        previousShouldRotate = revealController.shouldRotate;
        previousActualOrientation = self.interfaceOrientation.rawValue;
        
        screenWidth = max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        screenHeight = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.navigationController!.navigationBarHidden = true;
        let revealController = (self.navigationController as! MainNavigationController).revealController;
        revealController.panGestureRecognizer().enabled = false;
        revealController.shouldRotate = true;
        revealController.supportedOrientations = UIInterfaceOrientationMask.LandscapeRight.rawValue;
        revealController.preferredOrientation = UIInterfaceOrientation.LandscapeRight;
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation");
        UIViewController.attemptRotationToDeviceOrientation();
        initCards();
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (detailsCard != nil && !detailsCard.blankState) {
            detailsCard.animateBounceIn(detailsCardPosY);
        }
    }

    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBarHidden = false;
        super.viewWillDisappear(animated);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func shouldAutorotate() -> Bool {
        return true;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.LandscapeRight.rawValue | UIInterfaceOrientation.LandscapeLeft.rawValue;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeRight;
    }
    
    func initCards() {
        for subView in self.view.subviews {
            subView.removeFromSuperview();
        }
        var selectedCardPosition = 0;
        var pos = MetricsType.allValues.count - 1;
        var card: MetricCard?;
        for type in MetricsType.allValues.reverse() {
            var cardFrame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight);
            cardFrame.size.width = cardFrame.size.width - CGFloat((MetricsType.allValues.count - 1 - pos) * cardMargin);
            switch(type) {
            case MetricsType.DailySummary:
                card = MetricCard.instanceFromNib(ActivityMetricDelegate(), frame: cardFrame);
            case MetricsType.BloodPressure:
                card = MetricCard.instanceFromNib(BpMetricDelegate(), frame: cardFrame);
            case MetricsType.Pulse:
                card = MetricCard.instanceFromNib(PulseMetricDelegate(), frame: cardFrame);
            case MetricsType.Weight:
                let delegate = WeightMetricDelegate();
                card = MetricCard.instanceFromNib(delegate, frame: cardFrame);
                if let secondaryGraph = delegate.getSecondaryGraph(card!.graphContainer.frame) {
                    card!.secondaryGraph = secondaryGraph;
                    card!.secondaryGraph.hidden = true;
                    card!.toggleButton.hidden = false;
                    card!.triangleView.hidden = false;
                    card!.graphContainer.addSubview(secondaryGraph);
                }
            default:
                var i = 0;
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
            self.view.addSubview(detailsCard);
        }
        if (selectedCardPosition != 0) {
            cardClickedAtIndex(selectedCardPosition);
        }
    }
    
    func backButtonClicked(sender: AnyObject) {
        let revealController = (self.navigationController as! MainNavigationController).revealController;
        revealController.supportedOrientations = previousSupportedOrientations;
        revealController.shouldRotate = true;
        UIDevice.currentDevice().setValue(previousActualOrientation, forKey: "orientation");
        UIViewController.attemptRotationToDeviceOrientation();
        revealController.shouldRotate = previousShouldRotate;
        
        self.navigationController!.popViewControllerAnimated(true);
    }

    func cardClickedAtIndex(index: Int) {
        if (index == 0) {
            return;
        } else {
            if (detailsOpen) {
                closeDetails();
            }
            let subViews = self.view.subviews;
            let count = MetricsType.allValues.count;
            let distance = count - index;
            var viewsToSend:[UIView] = [];
            for index in distance...count - 1 {
                viewsToSend.append(subViews[index] as! UIView);
            }
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                for card in viewsToSend {
                    card.frame.origin.x = -self.screenWidth;
                }
                }, completion:  { complete in
                    
                    for card in viewsToSend.reverse() {
                        card.frame.origin.x = 0;
                        card.frame.size.width = self.screenWidth;
                        self.view.insertSubview(card, atIndex: 0);
                    }
                    
                    for index in 0...count - 1 {
                        let card = subViews[index] as! MetricCard;
                        let newWidth = self.screenWidth - CGFloat((index + 1) * self.cardMargin);
                        UIView.animateWithDuration(self.animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                            card.frame.size.width = newWidth;
                            }, completion:  { complete in
                                
                        });
                        
                    }
                    self.updateDetailCard();
            });
        }
        detailsCard.headerContainer.alpha = 1;
    }
    
    func cardDragged(index: Int, translation: CGPoint) {
        if (index == 0) {
            var topCard = self.view.subviews[self.view.subviews.count - 2] as! UIView;
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
        } else if (index != MetricsType.allValues.count - 1) {
            for i in 0...index {
                var card = self.view.subviews[self.view.subviews.count - (2 + i)] as! UIView;
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
            var topCard = self.view.subviews[self.view.subviews.count - 2] as! UIView;
            if (topCard.frame.origin.x >= -cardDragThreshold) {
                topCard.frame.origin.x = 0;
            }
        } else {
            var draggedCard = self.view.subviews[self.view.subviews.count - (2 + index)] as! UIView;
            if (draggedCard.frame.origin.x >= -cardDragThreshold) {
                for i in 0...index {
                    var card = self.view.subviews[self.view.subviews.count - (2 + i)] as! UIView;
                    card.frame.origin.x = 0;
                }
            }
        }
        detailsCard.headerContainer.alpha = 1;
        cardsTransitioning = false;
    }

    func updateDetailCard() {
        let currentCard = getCurrentCard();
        detailsCard.removeFromSuperview();
        detailsCard = initDetailCard(currentCard);
        self.view.addSubview(detailsCard);
        if (detailsGone) {
            if detailsCard.blankState {
                detailsCard.frame.origin.y = screenHeight;
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
        detailsCard.setData(getCurrentCard().delegate.getSelectedPoint()!);
    }
    
    func getCurrentCard() -> MetricCard {
        return self.view.subviews[self.view.subviews.count - 2] as! MetricCard;
    }

    func initDetailCard(card: MetricCard) -> MetricDetailCard {
        let detailCard = MetricDetailCard.instanceFromNib(card);
        detailCard.frame.origin.y = detailsOpen ? cardHeaderViewHeight : detailsCardPosY;
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
    
    func pointSelected(selection: SelectedPoint) {
        if (detailsCard != nil) {
            detailsCard.setData(selection);
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        let subViews = self.view.subviews;
        let count = MetricsType.allValues.count;
        for index in 0...count - 1 {
            let card = subViews[index] as! MetricCard;
            let newWidth = screenWidth - CGFloat((index) * self.cardMargin);
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                card.frame.size.width = newWidth;
                }, completion: nil);
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