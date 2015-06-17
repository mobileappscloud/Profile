import Foundation

class MetricsViewController: BaseViewController {
    
    var selectedType = MetricsType.BloodPressure;
    
    let cardMargin = 46;
    
    let animationDuration = 0.5;
    
    var detailsCard: MetricDetailCard!;
    
    var detailsOpen = false;

    let detailsCardPosY:CGFloat = 267, cardHeaderViewHeight:CGFloat = 54, cardDragThreshold:CGFloat = 300;
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.navigationController!.navigationBarHidden = true;
        revealController.panGestureRecognizer().enabled = false;
        revealController.supportedOrientations = UIInterfaceOrientationMask.LandscapeRight.rawValue;
        revealController.shouldRotate = true;
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation");
        for subView in self.view.subviews {
            subView.removeFromSuperview();
        }
        var selectedCardPosition = 0;
        var pos = MetricsType.allValues.count - 1;
        var card: MetricCard?;
        for type in MetricsType.allValues.reverse() {
            var cardFrame = UIScreen.mainScreen().bounds;
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
            detailsCard = initDetailCard(card!.getSelectedPoint(), delegate: card!.delegate);
            detailsCard.frame.origin.y = UIScreen.mainScreen().bounds.height;
            self.view.addSubview(detailsCard);
        }
        if (selectedCardPosition != 0) {
            cardClickedAtIndex(selectedCardPosition);
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (detailsCard != nil) {
            detailsCard.animateBounce(detailsCardPosY);
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
            let subViews = self.view.subviews;
            let count = MetricsType.allValues.count;
            let distance = count - index;
            var viewsToSend:[UIView] = [];
            for index in distance...count - 1 {
                viewsToSend.append(subViews[index] as! UIView);
            }
            UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                for card in viewsToSend {
                    card.frame.origin.x = -UIScreen.mainScreen().bounds.size.width;
                }
                }, completion:  { complete in
                    
                    for card in viewsToSend.reverse() {
                        card.frame.origin.x = 0;
                        card.frame.size.width = UIScreen.mainScreen().bounds.width;
                        self.view.insertSubview(card, atIndex: 0);
                    }
                    
                    for index in 0...count - 1 {
                        let card = subViews[index] as! MetricCard;
                        let newWidth = UIScreen.mainScreen().bounds.size.width - CGFloat((index + 1) * self.cardMargin);
                        UIView.animateWithDuration(self.animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                            card.frame.size.width = newWidth;
                            card.resizeFrameWithWidth(newWidth);
                            }, completion:  { complete in
                                
                        });
                        
                    }
                    self.updateDetailCard();
            });
        }

    }
    
    func cardDragged(index: Int, translation: CGPoint) {
        if (index == 0) {
            var topCard = self.view.subviews[self.view.subviews.count - 2] as! UIView;
            if (topCard.frame.origin.x + translation.x < -cardDragThreshold) {
                cardClickedAtIndex(index + 1);
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
                    cardClickedAtIndex(index + 1);
                    break;
                } else if (card.frame.origin.x + translation.x < 0) {
                    card.frame.origin.x += translation.x;
                } else {
                    card.frame.origin.x = 0;
                }
            }
        }
    }

    func doneDragging(index: Int) {
        if (index == 0) {
            var topCard = self.view.subviews[self.view.subviews.count - 2] as! UIView;
            if (topCard.frame.origin.x >= -cardDragThreshold) {
                topCard.frame.origin.x = 0;
            }
        }
    }
    
    func updateDetailCard() {
        detailsCard.removeFromSuperview();
        let currentCard = self.view.subviews[self.view.subviews.count - 1] as! MetricCard;
        detailsCard = initDetailCard(currentCard.getSelectedPoint(), delegate: currentCard.delegate);
        self.view.addSubview(detailsCard);
    }
    
    func initDetailCard(selection: MetricCard.SelectedPoint, delegate: MetricDelegate) -> MetricDetailCard {
        let card = MetricDetailCard.instanceFromNib(selection, delegate: delegate);
        card.frame.origin.y = detailsOpen ? cardHeaderViewHeight : detailsCardPosY;
        let selectedTapRecognizer = UITapGestureRecognizer(target: self, action: "detailsTapped:");
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "detailsSwiped:");
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down;
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "detailsSwiped:");
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up;
        card.headerContainer.addGestureRecognizer(selectedTapRecognizer);
        card.headerContainer.addGestureRecognizer(swipeDownRecognizer);
        card.headerContainer.addGestureRecognizer(swipeUpRecognizer);
        return card;
    }
    
    func sendViewsToBack(views: [UIView]) {
        for view in views {
            self.view.sendSubviewToBack(view);
        }
    }
    
    func pointSelected(selection: MetricCard.SelectedPoint) {
        if (detailsCard != nil) {
            detailsCard.setData(selection);
        }
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
        UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
            self.detailsCard.frame.origin.y = self.cardHeaderViewHeight - 1;
            }, completion: nil);
        detailsOpen = true;
        detailsCard.setPanelHeaders(detailsOpen);
    }
    
    func closeDetails() {
        UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
            self.detailsCard.frame.origin.y = self.detailsCardPosY;
            }, completion: nil);
        detailsOpen = false;
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
            let newWidth = UIScreen.mainScreen().bounds.size.width - CGFloat((index) * self.cardMargin);
            card.frame.size.width = newWidth;
            card.resizeFrameWithWidth(newWidth);
            card.position = count - 1 - index;
        }
    }
}