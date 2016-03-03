//
//  DashboardViewController.swift
//  higi
//
//  Created by Dan Harms on 1/20/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation
import SafariServices

final class DashboardViewController: UIViewController {
    
    @IBOutlet weak var challengesCardTitleLabel: UILabel! {
        didSet {
            challengesCardTitleLabel.text = NSLocalizedString("DASHBOARD_VIEW_CARD_CHALLENGES_TITLE", comment: "Title for challenges card displayed on Dashboard view.")
        }
    }
    @IBOutlet weak var metricsCardTitleLabel: UILabel! {
        didSet {
            metricsCardTitleLabel.text = NSLocalizedString("DASHBOARD_VIEW_CARD_METRICS_TITLE", comment: "Title for metrics card displayed on Dashboard view.")
        }
    }
    @IBOutlet weak var pulseCardButton: UIButton! {
        didSet {
            pulseCardButton.setTitle(NSLocalizedString("DASHBOARD_VIEW_CARD_PULSE_ACTION_TITLE", comment: "Title for pulse card displayed on Dashboard view."), forState: .Normal)
        }
    }
    @IBOutlet weak var errorCardRefreshButton: UIButton! {
        didSet {
            errorCardRefreshButton.setTitle(NSLocalizedString("DASHBOARD_VIEW_CARD_ERROR_REFRESH_ACTION_TITLE", comment: "Title for refresh action on error card displayed on Dashboard view."), forState: .Normal)
        }
    }
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet var challengesCard: ChallengesCard!
    @IBOutlet var metricsCard: UIView!
    @IBOutlet weak var pulseCard: PulseCard!
    @IBOutlet var errorCard: UIView!
    @IBOutlet var qrCheckinCard: QrCheckinCard!
    
    var currentOrigin: CGFloat = 0, gap: CGFloat = 10, contentOriginY: CGFloat = 83;
    
    var arc: CAShapeLayer!, circle: CAShapeLayer!, refreshArc: CAShapeLayer!;
    
    var refreshControl: UIRefreshControl!;
    
    var pullRefreshView: PullRefresh!;
    
    var displayedChallenge: HigiChallenge!;
    
    var doneRefreshing = true, activitiesRefreshed = true, challengesRefreshed = true, checkinsRefreshed = true, devicesRefreshed = true, metricsRefreshed = false, activitiesLoaded = false, challengesLoaded = false, metricsLoaded = false, challengeCardPlaced = false, metricsCardPlaced = false, pulseCardPlaced = false;
    
    var activityCard: MetricsGraphCard!;
    
    let maxPointsToShow = 30;
    
    var metricsSpinner: CustomLoadingSpinner!;
    
    var dashboardItems:[UIView] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = NSLocalizedString("DASHBOARD_VIEW_TITLE", comment: "Title for Dashboard view.");
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveQrCheckinNotification:", name: ApiUtility.QR_CHECKIN, object: nil);
        let notificationNames = [ApiUtility.ACTIVITIES, ApiUtility.CHALLENGES, ApiUtility.CHECKINS, ApiUtility.PULSE, ApiUtility.DEVICES]
        for name in notificationNames {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveApiNotification:", name: name, object: nil)
        }
        NSNotificationCenter.defaultCenter().addObserverForName("RefreshDashboard", object: nil, queue: nil, usingBlock: { [unowned self] (notification) in
            self.refresh()
        })
        
        createPullToRefresh();
        
        initCards();
        
        self.mainScrollView.contentInset = UIEdgeInsets(top: -82.0, left: 0.0, bottom: 35.0, right: 0.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);

        ensureCardWidthIntegrity();
        
        updateNavbar();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        if SessionController.Instance.showQrCheckinCard ?? false && qrCheckinCard.superview == nil {
            addQrCheckinView();
            layoutDashboardItems(false);
        }
        
        self.askToConnectActivityTracker()
    }
    
    private func askToConnectActivityTracker() {
        if !HealthKitManager.deviceHasMotionProcessor() || !HealthKitManager.isHealthDataAvailable() {
            return
        }

        if !HealthKitManager.didAskToConnectActivityTracker() {
            let alert = self.activityTrackerAuthorizationAlert()
            self.presentViewController(alert, animated: true, completion: {
                HealthKitManager.didAskToConnectActivityTracker(true)
            })
        }
    }
    
    private func addQrCheckinView() {
        mainScrollView.addSubview(qrCheckinCard);
        qrCheckinCard.titleText.text = NSLocalizedString("DASHBOARD_VIEW_CARD_QR_CHECKIN_UPLOAD_PENDING_TITLE", comment: "Title to display on QR check-in card when upload is in-progress.");
        qrCheckinCard.messageText.text = NSLocalizedString("DASHBOARD_VIEW_CARD_QR_CHECKIN_UPLOAD_PENDING_MESSAGE_TEXT", comment: "Message text to display on QR check-in card when upload is in-progress.");
        qrCheckinCard.loadingImage.image = UIImage.animatedImageNamed("icon-vitals-animation-", duration: 2);
    }
    
    /**
     @abstract This is a workaround to ensure the width of cards displayed on the dashboard fill
     the device width. This approach was chosen to minimize changes necessary to support multiple
     screen sizes.
     
     @note This view is not in true compliance with adaptive layout.
     */
    private func ensureCardWidthIntegrity() {
        let width = min(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        for subview in dashboardItems {
            manuallyAutoresizeSubview(subview, width: width);
        }
    }
    
    private func manuallyAutoresizeSubview(subview: UIView!, width: CGFloat) {
        var frame = subview.frame;
        frame.size.width = width;
        subview.frame = frame;
    }
    
    func receiveQrCheckinNotification(notification: NSNotification) {
        if let success = (notification.userInfo as! Dictionary<String, Bool>)["success"] {
            if success {
                showQrCheckinSuccess();
            } else {
                showQrCheckinFailure();
            }
        }
    }
    
    func showQrCheckinFailure() {
        qrCheckinCard.titleText.text = NSLocalizedString("DASHBOARD_VIEW_CARD_QR_CHECKIN_UPLOAD_FAILURE_TITLE", comment: "Title to display on QR check-in card when upload fails.");
        qrCheckinCard.messageText.text = NSLocalizedString("DASHBOARD_VIEW_CARD_QR_CHECKIN_UPLOAD_FAILURE_MESSAGE_TEXT", comment: "Message text to display on QR check-in card when upload fails.");
        qrCheckinCard.loadingImage.image = UIImage(named: "checkinerroricon");
    }
    
    func showQrCheckinSuccess() {
        qrCheckinCard.titleText.text = NSLocalizedString("DASHBOARD_VIEW_CARD_QR_CHECKIN_UPLOAD_SUCCESS_TITLE", comment: "Title to display on QR check-in card when upload succeeds.");
        qrCheckinCard.messageText.text = NSLocalizedString("DASHBOARD_VIEW_CARD_QR_CHECKIN_UPLOAD_SUCCESS_MESSAGE_TEXT", comment: "Message text to display on QR check-in card when upload succeeds.");
        qrCheckinCard.loadingImage.image = UIImage(named: "checkinsuccessicon");
        qrCheckinCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "gotoDailySummary:"));
    }
    
    func receiveApiNotification(notification: NSNotification) {
        switch (notification.name) {
        case ApiUtility.ACTIVITIES:
            activitiesLoaded = true;
            if (activitiesLoaded && metricsLoaded && !metricsRefreshed) {
                initMetricsCard();
                metricsRefreshed = true;
                Utility.mainTabBarController()?.metricsNavController.tabBarItem.enabled = true
            }
            activitiesRefreshed = true;
        case ApiUtility.CHALLENGES:
            challengesLoaded = true;
            if (doneRefreshing) {
                initChallengesCard();
                Utility.mainTabBarController()?.challengesNavController.tabBarItem.enabled = true
            }
            challengesRefreshed = true;
        case ApiUtility.CHECKINS:
            metricsLoaded = true;
            if (activitiesLoaded && metricsLoaded && !metricsRefreshed) {
                initMetricsCard();
                metricsRefreshed = true;
                Utility.mainTabBarController()?.metricsNavController.tabBarItem.enabled = true
            }
            checkinsRefreshed = true;
        case ApiUtility.PULSE:
            initPulseCard();
        case ApiUtility.DEVICES:
            devicesRefreshed = true;
        default:
            break;
        }
    }
    
    func initCards() {
        dashboardItems = [qrCheckinCard, errorCard, challengesCard, metricsCard, pulseCard];
        if SessionController.Instance.showQrCheckinCard ?? false {
            addQrCheckinView();
        }
        if (challengesCard.superview != nil) {
            challengesCard.removeFromSuperview();
        }
        if (metricsCard.superview != nil) {
            metricsCard.removeFromSuperview();
        }
        if (pulseCard.superview != nil) {
            pulseCard.removeFromSuperview();
        }
        initChallengesCard();
        initMetricsCard();
        initPulseCard();
    }
    
    func initChallengesCard() {
        if SessionController.Instance.earnditError && (SessionController.Instance.checkins == nil || SessionController.Instance.challenges.count == 0) {
            removeChallengeCard()
            showErrorCard()
        } else {
            if !SessionController.Instance.earnditError {
                removeErrorCard()
            }
            
            addChallengeCardWithSpinner()
            displayedChallenge = getDisplayedChallenge()
            if (displayedChallenge != nil) {
                setChallengeCardWithDisplayChallenge()
            } else if (challengesLoaded) {
                challengesCard.challengeBox.hidden = true;
                challengesCard.blankStateImage.hidden = false;
                Utility.growAnimation(challengesCard, startHeight: challengesCard.frame.size.height, endHeight: challengesCard.blankStateImage.frame.origin.y + challengesCard.blankStateImage.frame.size.height);
                challengesCard.loadingContainer.hidden = true;
                challengesCard.spinner.stopAnimating();
            }
        }
        layoutDashboardItems(challengeCardPlaced);
        challengeCardPlaced = true;
    }
    
    private func removeChallengeCard() {
        if (challengesCard.superview != nil) {
            challengesCard.spinner.stopAnimating();
            challengesCard.removeFromSuperview();
        }
    }
    
    private func showErrorCard() {
        if (errorCard.superview == nil) {
            mainScrollView.addSubview(errorCard);
            Utility.growAnimation(errorCard, startHeight: challengesCard.frame.size.height, endHeight: errorCard.frame.size.height);
        }
    }
    
    private func removeErrorCard() {
        if (errorCard.superview != nil) {
            errorCard.removeFromSuperview();
        }
    }
    
    private func addChallengeCardWithSpinner() {
        challengesCard.challengeBox.layer.borderColor = Utility.colorFromHexString("#CCCCCC").CGColor;
        if (challengesCard.spinner == nil) {
            challengesCard.spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 16 - challengesCard.loadingContainer.frame.origin.x, challengesCard.loadingContainer.frame.size.height / 2 - 16, 32, 32));
            challengesCard.loadingContainer.addSubview(challengesCard.spinner);
        }
        if (challengesCard.superview == nil) {
            mainScrollView.addSubview(challengesCard);
            challengesCard.spinner.startAnimating();
        }
    }
    
    private func getDisplayedChallenge() -> HigiChallenge? {
        var displayedChallenge:HigiChallenge? = nil
        if (SessionController.Instance.challenges != nil) {
            for challenge in SessionController.Instance.challenges {
                if (challenge.userStatus == "current" && challenge.status == "running") {
                    if (displayedChallenge == nil) {
                        displayedChallenge = challenge;
                    } else {
                        if (displayedChallenge!.endDate == nil) {
                            if (challenge.endDate != nil) {
                                displayedChallenge = challenge;
                            }
                        } else if (challenge.endDate != nil && displayedChallenge!.endDate.compare(challenge.endDate) == NSComparisonResult.OrderedDescending) {
                            displayedChallenge = challenge;
                        }
                    }
                }
            }
        }
        return displayedChallenge
    }
    
    private func setChallengeCardWithDisplayChallenge() {
        challengesCard.loadingContainer.hidden = true;
        challengesCard.spinner.stopAnimating();
        challengesCard.challengeBox.hidden = false;
        challengesCard.blankStateImage.hidden = true;
        challengesCard.challengeAvatar.setImageWithURL(NSURL(string: displayedChallenge.imageUrl as String));
        challengesCard.challengeTitle.text = displayedChallenge.name as String;
        if (challengesCard.challengeBox.subviews.count > 3) {
            (challengesCard.challengeBox.subviews[challengesCard.challengeBox.subviews.count - 1] ).removeFromSuperview();
        }
        let challengeViewHeader = CGFloat(56);
        let challengeView = ChallengeUtility.getChallengeViews(displayedChallenge, frame: CGRect(x: 0, y: challengeViewHeader, width: challengesCard.challengeBox.frame.size.width, height: 180), isComplex: false)[0];
        challengeView.backgroundColor = UIColor.whiteColor();
        if (challengeView.frame.size.height + challengeViewHeader > challengesCard.challengeBox.frame.size.height) {
            Utility.growAnimation(challengesCard.challengeBox, startHeight: challengesCard.challengeBox.frame.size.height, endHeight: challengeView.frame.size.height + challengeViewHeader + challengeViewHeader);
            Utility.growAnimation(challengesCard, startHeight: challengesCard.frame.size.height, endHeight: challengesCard.challengeBox.frame.origin.y + challengeView.frame.size.height + challengeViewHeader);
        }
        challengesCard.challengeBox.frame.size.height = challengeView.frame.size.height;
        challengesCard.challengeBox.addSubview(challengeView);
        challengeView.userInteractionEnabled = false;
        challengeView.updateConstraintsIfNeeded();
        challengeView.animate();
        
        challengesCard.spinner.stopAnimating();
    }
    
    func initMetricsCard() {
        if SessionController.Instance.earnditError {
            if SessionController.Instance.activities.count == 0 {
                showErrorCard()
            }
        } else {
            removeErrorCard()
        }
        
        addMetricsCardWithSpinner()
        
        if (SessionController.Instance.checkins != nil) {
            populateMetricsCardWithCheckins()
        }
        
        layoutDashboardItems(metricsCardPlaced);
        metricsCardPlaced = true;
    }
    
    func addMetricsCardWithSpinner() {
        if (metricsSpinner == nil) {
            metricsSpinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 16, 84, 32, 32));
            metricsCard.addSubview(metricsSpinner)
        }
        if (metricsCard.superview == nil) {
            mainScrollView.addSubview(metricsCard);
            metricsSpinner.startAnimating();
        }
    }
    
    func populateMetricsCardWithCheckins() {
        var bps: [HigiCheckin] = [], weights: [HigiCheckin] = [], pulses: [HigiCheckin] = [];
        var lastBpDate = "", lastBmiDate = "", lastPulseDate = "";
        for checkin in SessionController.Instance.checkins {
            let checkinDate = Constants.displayDateFormatter.stringFromDate(checkin.dateTime);
            if (checkin.systolic != nil && checkin.systolic > 0) {
                if (checkinDate != lastBpDate) {
                    bps.append(checkin);
                    lastBpDate = checkinDate;
                } else {
                    bps[bps.count - 1] = checkin;
                }
            }
            if (checkin.weightKG != nil && checkin.weightKG > 0) {
                if (checkinDate != lastBmiDate) {
                    weights.append(checkin);
                    lastBmiDate = checkinDate;
                } else {
                    weights[weights.count - 1] = checkin;
                }
            }
            if (checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                if (checkinDate != lastPulseDate) {
                    pulses.append(checkin);
                    lastPulseDate = checkinDate;
                } else {
                    pulses[pulses.count - 1] = checkin;
                }
            }
        }
        let cardMarginX:CGFloat = 8, cardMarginY:CGFloat = 16;
        var cardPositionY:CGFloat = 60;
        
        activityCard = MetricsGraphCard.instanceFromNib(0, type: MetricsType.DailySummary);
        activityCard.frame.origin.y = cardPositionY;
        activityCard.frame.origin.x = cardMarginX;
        let activityTouched = UITapGestureRecognizer(target: self, action: "gotoActivityGraph:");
        activityCard.addGestureRecognizer(activityTouched);
        cardPositionY += activityCard.frame.size.height + cardMarginY;
        
        let firstDivider = UIView(frame: CGRect(x: 0, y: cardPositionY - cardMarginY / 2, width: self.view.frame.size.width, height: 1));
        firstDivider.backgroundColor = Utility.colorFromHexString("#EEEEEE");
        
        var bloodPressureCard:MetricsGraphCard!
        if (bps.count > 0) {
            bloodPressureCard = MetricsGraphCard.instanceFromNib(bps.last!, type: MetricsType.BloodPressure);
        } else {
            bloodPressureCard = MetricsGraphCard.instanceFromNib(nil, type: MetricsType.BloodPressure);
        }
        bloodPressureCard.frame.origin.y = cardPositionY;
        bloodPressureCard.frame.origin.x = cardMarginX;
        let bpTouched = UITapGestureRecognizer(target: self, action: "gotoBloodPressureGraph:");
        bloodPressureCard.addGestureRecognizer(bpTouched);
        cardPositionY += bloodPressureCard.frame.size.height + cardMarginY;
        
        let secondDivider = UIView(frame: CGRect(x: 0, y: cardPositionY - cardMarginY / 2, width: self.view.frame.size.width, height: 1));
        secondDivider.backgroundColor = Utility.colorFromHexString("#EEEEEE");
        
        var pulseCard:MetricsGraphCard!
        if (pulses.count > 0) {
            pulseCard = MetricsGraphCard.instanceFromNib(pulses.last!, type: MetricsType.Pulse);
        } else {
            pulseCard = MetricsGraphCard.instanceFromNib(nil, type: MetricsType.Pulse);
        }
        pulseCard.frame.origin.y = cardPositionY;
        pulseCard.frame.origin.x = cardMarginX;
        let pulseTouched = UITapGestureRecognizer(target: self, action: "gotoPulseGraph:");
        pulseCard.addGestureRecognizer(pulseTouched);
        cardPositionY += pulseCard.frame.size.height + cardMarginY;
        
        let thirdDivider = UIView(frame: CGRect(x: 0, y: cardPositionY - cardMarginY / 2, width: self.view.frame.size.width, height: 1));
        thirdDivider.backgroundColor = Utility.colorFromHexString("#EEEEEE");
        
        var weightCard:MetricsGraphCard!;
        if (weights.count > 0) {
            weightCard = MetricsGraphCard.instanceFromNib(weights.last!, type: MetricsType.Weight);
        } else {
            weightCard = MetricsGraphCard.instanceFromNib(nil, type: MetricsType.Weight);
        }
        weightCard.frame.origin.y = cardPositionY;
        weightCard.frame.origin.x = cardMarginX;
        let weightTouched = UITapGestureRecognizer(target: self, action: "gotoWeightGraph:");
        weightCard.addGestureRecognizer(weightTouched);
        cardPositionY += weightCard.frame.size.height + cardMarginY / 2;
        
        let checkins = SessionController.Instance.checkins;
        if (checkins != nil && checkins.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var mapPoints:[GraphPoint] = [], bpmPoints:[GraphPoint] = [], weightPoints:[GraphPoint] = [];
                for checkin in checkins {
                    if (checkin.map != nil) {
                        mapPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: checkin.map!));
                    }
                    if (checkin.pulseBpm != nil) {
                        bpmPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.pulseBpm!)));
                    }
                    if (checkin.weightLbs != nil) {
                        weightPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: checkin.weightLbs!));
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    if (mapPoints.count > self.maxPointsToShow) {
                        mapPoints = Array(Array(mapPoints.reverse())[0..<self.maxPointsToShow]);
                    }
                    if (bpmPoints.count > self.maxPointsToShow) {
                        bpmPoints = Array(Array(bpmPoints.reverse())[0..<self.maxPointsToShow]);
                    }
                    if (weightPoints.count > self.maxPointsToShow) {
                        weightPoints = Array(Array(weightPoints.reverse())[0..<self.maxPointsToShow]);
                    }
                    bloodPressureCard.graph(mapPoints, type: MetricsType.BloodPressure);
                    pulseCard.graph(bpmPoints, type: MetricsType.Pulse);
                    weightCard.graph(weightPoints, type: MetricsType.Weight);
                });
            });
        } else {
            bloodPressureCard.graph([], type: MetricsType.BloodPressure);
            pulseCard.graph([], type: MetricsType.Pulse);
            weightCard.graph([], type: MetricsType.Weight);
        }
        if SessionController.Instance.earnditError && SessionController.Instance.activities.count == 0 {
            self.activityCard.singleValue.text = "--";
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var activityPoints:[GraphPoint] = [];
                let dateString = Constants.dateFormatter.stringFromDate(NSDate());
                var totalPoints = 0;
                for (date, activitySummary) in SessionController.Instance.activities {
                    let total = activitySummary.totalPoints
                    let activityList = activitySummary.activities
                    if (date == dateString) {
                        totalPoints = total;
                    }
                    if (activityList.count > 0) {
                        activityPoints.append(GraphPoint(x: Double(activityList[0].startTime.timeIntervalSince1970), y: Double(total)));
                    }
                }
                activityPoints.sortInPlace({$0.x > $1.x});
                if (activityPoints.count > self.maxPointsToShow) {
                    activityPoints = Array(activityPoints[0..<self.maxPointsToShow]);
                }
                activityPoints = Array(activityPoints.reverse());
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityCard.singleValue.text = "\(totalPoints)";
                    self.activityCard.graph(activityPoints, type: MetricsType.DailySummary);
                });
            });
        }
        metricsSpinner.stopAnimating();
        metricsSpinner.removeFromSuperview();
        metricsCard.addSubview(activityCard);
        metricsCard.addSubview(firstDivider);
        metricsCard.addSubview(bloodPressureCard);
        metricsCard.addSubview(secondDivider);
        metricsCard.addSubview(pulseCard);
        metricsCard.addSubview(thirdDivider);
        metricsCard.addSubview(weightCard);
        
        Utility.growAnimation(metricsCard, startHeight: metricsCard.frame.size.height, endHeight: cardPositionY);
    }
    
    func initPulseCard() {
        var articles = SessionController.Instance.pulseArticles;
        if (articles.count > 2) {
            pulseCard.spinner.stopAnimating();
            pulseCard.loadingContainer.hidden = true;
            let topArticle = articles[0], middleArticle = articles[1], bottomArticle = articles[2];
            pulseCard.topImage.setImageWithURL(NSURL(string: topArticle.imageUrl as String));
            pulseCard.topTitle.text = topArticle.title as String;
            pulseCard.topExcerpt.text = topArticle.excerpt as String;
            pulseCard.middleImage.setImageWithURL(NSURL(string: middleArticle.imageUrl as String));
            pulseCard.middleTitle.text = middleArticle.title as String;
            pulseCard.middleExcerpt.text = middleArticle.excerpt as String;
            pulseCard.bottomImage.setImageWithURL(NSURL(string: bottomArticle.imageUrl as String));
            pulseCard.bottomTitle.text = bottomArticle.title as String;
            pulseCard.bottomExcerpt.text = bottomArticle.excerpt as String;
            pulseCard.middleTitle.sizeToFit();
            pulseCard.middleExcerpt.sizeToFit();
            pulseCard.bottomTitle.sizeToFit();
            pulseCard.bottomExcerpt.sizeToFit();
        } else {
            // TODO make error state
        }
        if (pulseCard.superview == nil) {
            pulseCard.frame.origin.y = currentOrigin;
            currentOrigin += pulseCard.frame.size.height + gap;
            mainScrollView.addSubview(pulseCard);
            pulseCard.spinner.startAnimating();
        }
        layoutDashboardItems(pulseCardPlaced);
        pulseCardPlaced = true;
    }

    func gotoActivityGraph(sender: AnyObject) {
        Flurry.logEvent("ActivityMetric_Pressed");
        navigateToMetrics(.DailySummary)
    }
    
    func gotoBloodPressureGraph(sender: AnyObject) {
        Flurry.logEvent("BpMetric_Pressed");
        navigateToMetrics(.BloodPressure)
    }

    func gotoPulseGraph(sender: AnyObject) {
        Flurry.logEvent("PulseMetric_Pressed");
        navigateToMetrics(.Pulse)
    }
    
    func gotoWeightGraph(sender: AnyObject) {
        Flurry.logEvent("WeightMetric_Pressed");
        navigateToMetrics(.Weight)
    }
    
    func gotoDailySummary(sender: AnyObject) {
        Flurry.logEvent("QrCheckinCard_Pressed");
    }
    
    @IBAction func gotoConnectDevices(sender: AnyObject) {
        Flurry.logEvent("ConnectDevice_Pressed");
        ConnectDeviceViewController.navigateToConnectDevice()
    }
    
    @IBAction func gotoMetrics(sender: AnyObject) {
        if (SessionController.Instance.checkins != nil && SessionController.Instance.loadedActivities) {
            Flurry.logEvent("Metrics_Pressed");
            navigateToMetrics()
        }
    }
    
    private func navigateToMetrics(metricsType: MetricsType = .DailySummary) {
        if (SessionController.Instance.checkins != nil && SessionController.Instance.loadedActivities) {
            guard let mainTabBarController = Utility.mainTabBarController() else { return }
            mainTabBarController.metricsViewController.navigate(metricsType: metricsType)
        }
    }
    
    @IBAction func gotoChallenges(sender: AnyObject) {
        if (SessionController.Instance.challenges != nil && SessionController.Instance.loadedChallenges) {
            Flurry.logEvent("Challenges_Pressed");
            
            guard let mainTabBarController = Utility.mainTabBarController() else { return }
            
            mainTabBarController.challengesViewController.navigateToChallengesDashboard()
        }
    }
    
    @IBAction func gotoChallengeDetails(sender: AnyObject) {
        if (SessionController.Instance.challenges != nil && SessionController.Instance.loadedChallenges) {
            Flurry.logEvent("ActiveChallenge_Pressed");
            
            guard let mainTabBarController = Utility.mainTabBarController() else { return }
            
            mainTabBarController.challengesViewController.navigateToChallengeDetail(displayedChallenge)
        }
    }
    
    @IBAction func gotoPulseHome(sender: AnyObject) {
        Flurry.logEvent("higiPulse_Pressed");
        
        guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
        let pulseHomeViewController = mainTabBarController.pulseModalViewController()
        dispatch_async(dispatch_get_main_queue(), {
            mainTabBarController.presentViewController(pulseHomeViewController, animated: true, completion: nil)
        })
    }
    
    @IBAction func gotoPulseArticle(sender: AnyObject) {
        if (sender.tag! == 0) {
            Flurry.logEvent("FeaturedPulseArticle_Pressed");
        } else {
            Flurry.logEvent("NonFeaturedPulseArticle_Pressed");
        }
        
        let pulseArticle = SessionController.Instance.pulseArticles[sender.tag!]
        let URLString = pulseArticle.permalink as String
        
        guard let URL = NSURL(string: URLString) else { return }
        guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
        let pulseNavController = mainTabBarController.pulseModalViewController() as! UINavigationController
        let pulseHomeViewController = pulseNavController.topViewController as! PulseHomeViewController
        
        dispatch_async(dispatch_get_main_queue(), {
            mainTabBarController.presentViewController(pulseNavController, animated: false, completion: nil)
            let article = PulseArticle(permalink: URL);
            pulseHomeViewController.gotoArticle(article);
        })
    }
    
    @IBAction func removeQrCheckinCard(sender: AnyObject) {
        SessionController.Instance.showQrCheckinCard = false;
        qrCheckinCard.removeFromSuperview();
        layoutDashboardItems(false);
    }
    
    func updateNavbar() {
        let scrollY = mainScrollView.contentOffset.y;
        if (scrollY >= 0) {
            CATransaction.setDisableActions(true);
            refreshArc.strokeStart = 0.0;
            refreshArc.strokeEnd = 0.0;
            CATransaction.setDisableActions(false);
        } else {
            // Pull to refresh
//            let alpha = max(1.0 + scrollY / (mainScrollView.frame.size.height * 0.195), 0.0);
            let alpha = max(1.0 + scrollY / 100.0, 0.0);
            if (!refreshControl.refreshing && doneRefreshing) {
                pullRefreshView.icon.alpha = 1.0 - alpha;
                pullRefreshView.circleContainer.alpha = 1.0 - alpha;
                CATransaction.setDisableActions(true);
                refreshArc.strokeEnd = (1 - alpha);
                CATransaction.setDisableActions(false);
                if (alpha == 0) {
                    doneRefreshing = false;
                    refreshControl.beginRefreshing();
                    refresh();
                }
            }
        }
    }
    
    func createPullToRefresh() {
        pullRefreshView = UINib(nibName: "PullRefreshView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PullRefresh;
        
        refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged);
        refreshControl.tintColor = UIColor.clearColor();
        refreshControl.backgroundColor = UIColor.clearColor();
        refreshControl.addSubview(pullRefreshView);
        mainScrollView.addSubview(refreshControl);
        
        refreshArc = CAShapeLayer();
        refreshArc.lineWidth = 3;
        refreshArc.fillColor = UIColor.clearColor().CGColor;
        refreshArc.strokeColor = UIColor.whiteColor().CGColor;
        
        let toPath = UIBezierPath();
        let radius = pullRefreshView.circleContainer.frame.size.width / 2.0;
        let center = CGPoint(x: radius, y: radius);
        let startingPoint = CGPoint(x: center.x, y: 0);
        toPath.moveToPoint(startingPoint);
        toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(3 * M_PI_2), clockwise: true);
        toPath.closePath();
        
        refreshArc.path = toPath.CGPath;
        
        refreshArc.strokeStart = 0.0;
        refreshArc.strokeEnd = 0.0;
        
        pullRefreshView.circleContainer.layer.addSublayer(refreshArc);
    }
    
    func refresh() {
        SessionController.Instance.earnditError = false;
        activitiesRefreshed = false;
        challengesRefreshed = false;
        checkinsRefreshed = false;
        devicesRefreshed = false;
        activitiesLoaded = false;
        metricsLoaded = false;
        metricsRefreshed = false;
        pullRefreshView.icon.alpha = 1.0;
        pullRefreshView.circleContainer.alpha = 1.0;
        CATransaction.begin();
        CATransaction.setDisableActions(true);
        refreshArc.strokeStart = 0.0;
        refreshArc.strokeEnd = 1.0;
        CATransaction.setDisableActions(false);
        CATransaction.commit();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while (true) {
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setAnimationDuration(0.5);
                    self.refreshArc.strokeStart = 1.0;
                    CATransaction.commit();
                });
                NSThread.sleepForTimeInterval(0.6);
                if (self.doneRefreshing) {
                    break;
                }
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setDisableActions(true);
                    self.refreshArc.strokeEnd = 0.0;
                    self.refreshArc.strokeStart = 0.0;
                    CATransaction.setDisableActions(false);
                    CATransaction.commit();
                });
                NSThread.sleepForTimeInterval(0.05);
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setAnimationDuration(0.5);
                    self.refreshArc.strokeEnd = 1.0;
                    CATransaction.commit();
                });
                NSThread.sleepForTimeInterval(0.45);
            }
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            while (!self.activitiesRefreshed || !self.challengesRefreshed || !self.checkinsRefreshed || !self.devicesRefreshed) {
                NSThread.sleepForTimeInterval(0.1);
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.pullRefreshView.circleContainer.alpha = 0;
                self.pullRefreshView.icon.alpha = 0;
                CATransaction.begin();
                CATransaction.setDisableActions(true);
                self.refreshArc.strokeStart = 0.0;
                self.refreshArc.strokeEnd = 0.0;
                CATransaction.setDisableActions(false);
                CATransaction.commit();
                self.initCards();
                self.doneRefreshing = true;
                self.refreshControl.endRefreshing();
            });
            
        });
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/qdata/\(SessionData.Instance.user.userId)?newSession=true", success: { operation, responseObject in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let login = HigiLogin(dictionary: responseObject as! NSDictionary);
                SessionData.Instance.user = login.user;
                SessionData.Instance.user.retrieveProfileImages();
                ApiUtility.retrieveActivities(nil);
                ApiUtility.retrieveChallenges(nil);
                ApiUtility.retrieveCheckins(nil);
                ApiUtility.retrieveDevices(nil);
            });
            
            }, failure: { operation, error in
                self.activitiesRefreshed = true;
                self.challengesRefreshed = true;
                self.checkinsRefreshed = true;
                self.devicesRefreshed = true;
        });
    }
    
    func layoutDashboardItems(animated: Bool) {
        currentOrigin = contentOriginY;
        for item in dashboardItems {
            if item.superview != nil {
                if animated {
                    UIView.animateWithDuration(1, animations: {
                        item.frame.origin.y = self.currentOrigin;
                    });
                } else {
                    item.frame.origin.y = currentOrigin;
                }
                currentOrigin += item.frame.size.height + gap;
            }
        }
        mainScrollView.contentSize.height = currentOrigin;
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        mainScrollView.setContentOffset(CGPoint(x: 0, y: -mainScrollView.frame.size.height * 0.2), animated: true);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
}

extension DashboardViewController {

    private func activityTrackerAuthorizationAlert() -> UIAlertController {
        let alertTitle = NSLocalizedString("DASHBOARD_VIEW_BRANDED_ACTIVITY_TRACKER_CONNECT_DEVICE_ALERT_TITLE", comment: "Title for alert displayed when asking user to connect the branded activity tracker which leverages data from current device.")
        let alertMessage = NSLocalizedString("DASHBOARD_VIEW_BRANDED_ACTIVITY_TRACKER_CONNECT_DEVICE_ALERT_MESSAGE", comment: "Message for alert displayed when asking user to connect the branded activity tracker which leverages data from current device.")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let connectActionTitle = NSLocalizedString("DASHBOARD_VIEW_BRANDED_ACTIVITY_TRACKER_CONNECT_DEVICE_ALERT_ACTION_CONNECT_TITLE", comment: "Title for alert action to connect a branded activity tracker which leverages data from current device.")
        let connectAction = UIAlertAction(title: connectActionTitle, style: .Default, handler: { action in
            HealthKitManager.requestReadAccessToStepData( { (didRespond, error) in
                if didRespond {
                    HealthKitManager.checkReadAuthorizationForStepData({ (isAuthorized) in
                        if isAuthorized {
                            HealthKitManager.enableBackgroundUpdates()
                        } else {
                            HealthKitManager.disableBackgroundUpdates()
                        }
                    })
                }
            })
        })
        alert.addAction(connectAction)
        let dismissActionTitle = NSLocalizedString("DASHBOARD_VIEW_BRANDED_ACTIVITY_TRACKER_CONNECT_DEVICE_ALERT_ACTION_DISMISS_TITLE", comment: "Title for action to dismiss alert displayed when asking user to connect the branded activity tracker which leverages data from current device.")
        let dismissAction = UIAlertAction(title: dismissActionTitle, style: .Cancel, handler: { [weak self] action in
            if let alert = self?.activityTrackerAuthorizationDismissAlert() {
                self?.presentViewController(alert, animated: true, completion: nil)
            }
            })
        alert.addAction(dismissAction)
        return alert
    }
    
    private func activityTrackerAuthorizationDismissAlert() -> UIAlertController {
        let alertTitle = NSLocalizedString("DASHBOARD_VIEW_BRANDED_ACTIVITY_TRACKER_CONNECT_DEVICE_DISMISSED_ALERT_TITLE", comment: "Title for alert displayed when a user dismisses the alert to connect a branded activity tracker.")
        let alertMessage = NSLocalizedString("DASHBOARD_VIEW_BRANDED_ACTIVITY_TRACKER_CONNECT_DEVICE_DISMISSED_ALERT_MESSAGE", comment: "Message for alert displayed when a user dismisses the alert to connect a branded activity tracker.")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let acknowledgeActionTitle = NSLocalizedString("DASHBOARD_VIEW_BRANDED_ACTIVITY_TRACKER_CONNECT_DEVICE_DISMISSED_ALERT_ACTION_OK_TITLE", comment: "Title for action to acknowledge/dismiss the alert.")
        let connectAction = UIAlertAction(title: acknowledgeActionTitle, style: .Default, handler: nil)
        alert.addAction(connectAction)
        return alert
    }
}

// MARK: - Scroll View Delegate

extension DashboardViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavbar()
    }
}

// MARK: - Interface Orientation

extension DashboardViewController {

    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}
