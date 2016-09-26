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
    
    @IBOutlet weak var errorCardRefreshButton: UIButton! {
        didSet {
            errorCardRefreshButton.setTitle(NSLocalizedString("DASHBOARD_VIEW_CARD_ERROR_REFRESH_ACTION_TITLE", comment: "Title for refresh action on error card displayed on Dashboard view."), forState: .Normal)
        }
    }
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet var challengesCard: ChallengesCard!
    @IBOutlet var metricsCard: UIView!
    @IBOutlet var errorCard: UIView!
    @IBOutlet var qrCheckinCard: QrCheckinCard!
    
    var currentOrigin: CGFloat = 0, gap: CGFloat = 10
    
    var arc: CAShapeLayer!, circle: CAShapeLayer!, refreshArc: CAShapeLayer!;
    
    var refreshControl: UIRefreshControl!;
    
    var pullRefreshView: PullRefresh!;
    
    var displayedChallenge: HigiChallenge!;
    
    var doneRefreshing = true, activitiesRefreshed = true, checkinsRefreshed = true, devicesRefreshed = true, metricsRefreshed = false, activitiesLoaded = false,  metricsLoaded = false, metricsCardPlaced = false, pulseCardPlaced = false;
    
    var activityCard: MetricsGraphCard!;
    
    let maxPointsToShow = 30;
    
    var metricsSpinner: CustomLoadingSpinner!;
    
    var dashboardItems:[UIView] = [];
    
    /// Blank view which will cover dashboard while app is transitioned from Dashboard to Home feed.
    let blankViewController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = NSLocalizedString("DASHBOARD_VIEW_TITLE", comment: "Title for Dashboard view.");
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DashboardViewController.receiveQrCheckinNotification(_:)), name: ApiUtility.QR_CHECKIN, object: nil);
        let notificationNames = [ApiUtility.ACTIVITIES, ApiUtility.CHECKINS, ApiUtility.DEVICES]
        for name in notificationNames {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DashboardViewController.receiveApiNotification(_:)), name: name, object: nil)
        }
        NSNotificationCenter.defaultCenter().addObserverForName("RefreshDashboard", object: nil, queue: nil, usingBlock: { [unowned self] (notification) in
            self.refresh()
        })
        
        createPullToRefresh();
        
        initCards();
        
        blankViewController.view.backgroundColor = Theme.Color.Primary.whiteGray
        self.view.addSubview(blankViewController.view, pinToEdges: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);

        ensureCardWidthIntegrity();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        if SessionController.Instance.showQrCheckinCard ?? false && qrCheckinCard.superview == nil {
            addQrCheckinView();
            layoutDashboardItems(false);
        }
        
        self.askToConnectActivityTracker()
        
        self.view.bringSubviewToFront(blankViewController.view)
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
        qrCheckinCard.loadingImage.image = UIImage(named: "checkin-error-icon");
    }
    
    func showQrCheckinSuccess() {
        qrCheckinCard.titleText.text = NSLocalizedString("DASHBOARD_VIEW_CARD_QR_CHECKIN_UPLOAD_SUCCESS_TITLE", comment: "Title to display on QR check-in card when upload succeeds.");
        qrCheckinCard.messageText.text = NSLocalizedString("DASHBOARD_VIEW_CARD_QR_CHECKIN_UPLOAD_SUCCESS_MESSAGE_TEXT", comment: "Message text to display on QR check-in card when upload succeeds.");
        qrCheckinCard.loadingImage.image = UIImage(named: "checkin-success-icon");
        qrCheckinCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.gotoDailySummary(_:))));
    }
    
    func receiveApiNotification(notification: NSNotification) {
        switch (notification.name) {
        case ApiUtility.ACTIVITIES:
            activitiesLoaded = true;
            if (activitiesLoaded && metricsLoaded && !metricsRefreshed) {
                initMetricsCard();
                metricsRefreshed = true;
//                Utility.mainTabBarController()?.metricsNavController.tabBarItem.enabled = true
            }
            activitiesRefreshed = true;
        
        case ApiUtility.CHECKINS:
            metricsLoaded = true;
            if (activitiesLoaded && metricsLoaded && !metricsRefreshed) {
                initMetricsCard();
                metricsRefreshed = true;
//                Utility.mainTabBarController()?.metricsNavController.tabBarItem.enabled = true
            }
            checkinsRefreshed = true;
        
        case ApiUtility.DEVICES:
            devicesRefreshed = true;
        default:
            break;
        }
    }
    
    func initCards() {
        dashboardItems = [qrCheckinCard, errorCard, challengesCard, metricsCard];
        if SessionController.Instance.showQrCheckinCard ?? false {
            addQrCheckinView();
        }
        if (metricsCard.superview != nil) {
            metricsCard.removeFromSuperview();
        }
        initMetricsCard();
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
            let checkinDate = NSDateFormatter.checkinDisplayDateFormatter.stringFromDate(checkin.dateTime);
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
        let activityTouched = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.gotoActivityGraph(_:)));
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
        let bpTouched = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.gotoBloodPressureGraph(_:)));
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
        let pulseTouched = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.gotoPulseGraph(_:)));
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
        let weightTouched = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.gotoWeightGraph(_:)));
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
                let dateString = NSDateFormatter.activityDateFormatter.stringFromDate(NSDate());
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
//            if !mainTabBarController.metricsViewController.tabBarItem.enabled { return }
//            mainTabBarController.metricsViewController.navigate(metricsType: metricsType)
        }
    }
    
    @IBAction func gotoChallenges(sender: AnyObject) {
//        if (SessionController.Instance.challenges != nil && SessionController.Instance.loadedChallenges) {
            Flurry.logEvent("Challenges_Pressed");
            
//            guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
//            mainTabBarController.challengesViewController.navigateToChallengesDashboard()
//        }
    }
    
    @IBAction func gotoChallengeDetails(sender: AnyObject) {
//        if (SessionController.Instance.challenges != nil && SessionController.Instance.loadedChallenges) {
            Flurry.logEvent("ActiveChallenge_Pressed");
            
//            guard let mainTabBarController = Utility.mainTabBarController() else { return }
//            
//            mainTabBarController.challengesViewController.navigateToChallengeDetail(displayedChallenge)
//        }
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
        refreshControl.addTarget(self, action: #selector(DashboardViewController.refresh), forControlEvents: UIControlEvents.ValueChanged);
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
            
            while (!self.activitiesRefreshed || !self.checkinsRefreshed || !self.devicesRefreshed) {
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
                ApiUtility.retrieveCheckins(nil);
                ApiUtility.retrieveDevices(nil);
            });
            
            }, failure: { operation, error in
                self.activitiesRefreshed = true;
                self.checkinsRefreshed = true;
                self.devicesRefreshed = true;
        });
    }
    
    func layoutDashboardItems(animated: Bool) {
        currentOrigin = 0.0
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
