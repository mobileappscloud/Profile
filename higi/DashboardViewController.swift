//
//  NewDashboardViewController.swift
//  higi
//
//  Created by Dan Harms on 1/20/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class DashboardViewController: BaseViewController, UIScrollViewDelegate {
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet var challengesCard: ChallengesCard!
    @IBOutlet var metricsCard: UIView!
    @IBOutlet weak var pulseCard: PulseCard!
    @IBOutlet var errorCard: UIView!
    
    var currentOrigin: CGFloat = 0, gap: CGFloat = 10, contentOriginY: CGFloat = 83;
    
    var arc: CAShapeLayer!, circle: CAShapeLayer!, refreshArc: CAShapeLayer!;
    
    var refreshControl: UIRefreshControl!;
    
    var pullRefreshView: PullRefresh!;
    
    var displayedChallenge: HigiChallenge!;
    
    var doneRefreshing = true, activitiesRefreshed = true, challengesRefreshed = true, checkinsRefreshed = true, devicesRefreshed = true, metricsRefreshed = false, activitiesLoaded = false, challengesLoaded = false, metricsLoaded = false;
    
    var activityCard: MetricsGraphCard!;
    
    let maxPointsToShow = 30;
    
    var metricsSpinner: CustomLoadingSpinner!;
    
    var dashboardItems:[UIView] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Dashboard";
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveApiNotification:", name: ApiUtility.ACTIVITIES, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveApiNotification:", name: ApiUtility.CHALLENGES, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveApiNotification:", name: ApiUtility.CHECKINS, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveApiNotification:", name: ApiUtility.PULSE, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveApiNotification:", name: ApiUtility.DEVICES, object: nil);
        createPullToRefresh();
        initCards();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        updateNavbar();
    }
    
    override func receiveApiNotification(notification: NSNotification) {
        super.receiveApiNotification(notification);
        switch (notification.name) {
        case ApiUtility.ACTIVITIES:
            activitiesLoaded = true;
            if (activitiesLoaded && metricsLoaded && !metricsRefreshed) {
                initMetricsCard();
                metricsRefreshed = true;
            }
            activitiesRefreshed = true;
        case ApiUtility.CHALLENGES:
            challengesLoaded = true;
            if (doneRefreshing) {
                initChallengesCard();
            }
            challengesRefreshed = true;
        case ApiUtility.CHECKINS:
            metricsLoaded = true;
            if (activitiesLoaded && metricsLoaded && !metricsRefreshed) {
                initMetricsCard();
                metricsRefreshed = true;
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
        if (SessionController.Instance.earnditError) {
            dashboardItems = [errorCard, pulseCard];
            if (challengesCard.superview != nil) {
                challengesCard.spinner.stopAnimating();
                challengesCard.removeFromSuperview();
            }
            if (errorCard.superview == nil) {
                errorCard.frame.origin.y = contentOriginY;
                mainScrollView.addSubview(errorCard);
            }
        } else {
            if (errorCard.superview != nil) {
                errorCard.removeFromSuperview();
            }
            dashboardItems = [challengesCard, metricsCard, pulseCard];
            challengesCard.challengeBox.layer.borderColor = Utility.colorFromHexString("#CCCCCC").CGColor;
            if (challengesCard.spinner == nil) {
                challengesCard.spinner = CustomLoadingSpinner(frame: CGRectMake(challengesCard.loadingContainer.frame.size.width / 2 - 16, challengesCard.loadingContainer.frame.size.height / 2 - 16, 32, 32));
                challengesCard.loadingContainer.addSubview(challengesCard.spinner);
            }
            if (challengesCard.superview == nil) {
                mainScrollView.addSubview(challengesCard);
                challengesCard.spinner.startAnimating();
            }
            displayedChallenge = nil;
            if (SessionController.Instance.challenges != nil) {
                for challenge in SessionController.Instance.challenges {
                    if (challenge.userStatus == "current" && challenge.status == "running") {
                        if (displayedChallenge == nil) {
                            displayedChallenge = challenge;
                        } else {
                            if (displayedChallenge.endDate == nil) {
                                if (challenge.endDate != nil) {
                                    displayedChallenge = challenge;
                                }
                            } else if (challenge.endDate != nil && displayedChallenge.endDate.compare(challenge.endDate) == NSComparisonResult.OrderedDescending) {
                                displayedChallenge = challenge;
                            }
                        }
                    }
                }
            }
            if (displayedChallenge != nil) {
                challengesCard.loadingContainer.hidden = true;
                challengesCard.spinner.stopAnimating();
                challengesCard.challengeBox.hidden = false;
                challengesCard.blankStateImage.hidden = true;
                challengesCard.challengeAvatar.setImageWithURL(NSURL(string: displayedChallenge.imageUrl as String));
                challengesCard.challengeTitle.text = displayedChallenge.name as String;
                let previousHeight = challengesCard.challengeBox.frame.size.height
                if (challengesCard.challengeBox.subviews.count > 3) {
                    (challengesCard.challengeBox.subviews[challengesCard.challengeBox.subviews.count - 1] as! UIView).removeFromSuperview();
                }
                let challengeViewHeader = CGFloat(56);
                var challengeView = ChallengeUtility.getChallengeViews(displayedChallenge, frame: CGRect(x: 0, y: challengeViewHeader, width: challengesCard.challengeBox.frame.size.width, height: 180), isComplex: false)[0];
                challengeView.backgroundColor = UIColor.whiteColor();
                if (challengeView.frame.size.height + challengeViewHeader > challengesCard.challengeBox.frame.size.height) {
                    Utility.growAnimation(challengesCard.challengeBox, startHeight: challengesCard.challengeBox.frame.size.height, endHeight: challengeView.frame.size.height + challengeViewHeader + challengeViewHeader);
                    Utility.growAnimation(challengesCard, startHeight: challengesCard.frame.size.height, endHeight: challengesCard.challengeBox.frame.origin.y + challengeView.frame.size.height + challengeViewHeader);
                }
                challengesCard.challengeBox.addSubview(challengeView);
                challengeView.userInteractionEnabled = false;
                challengeView.updateConstraintsIfNeeded();
                challengeView.animate();
                
                challengesCard.loadingContainer.hidden = true;
                challengesCard.spinner.stopAnimating();
            } else if (challengesLoaded) {
                challengesCard.challengeBox.hidden = true;
                challengesCard.blankStateImage.hidden = false;
                Utility.growAnimation(challengesCard, startHeight: challengesCard.frame.size.height, endHeight: challengesCard.blankStateImage.frame.origin.y + challengesCard.blankStateImage.frame.size.height);
                challengesCard.loadingContainer.hidden = true;
                challengesCard.spinner.stopAnimating();
            }
        }
        layoutDashboardItems(dashboardItems);
    }
    
    func initMetricsCard() {
        if (SessionController.Instance.earnditError) {
            dashboardItems = [errorCard, pulseCard];
            if (metricsCard.superview != nil) {
                metricsSpinner.stopAnimating();
                metricsCard.removeFromSuperview();
            }
            if (errorCard.superview == nil) {
                errorCard.frame.origin.y = contentOriginY;
                mainScrollView.addSubview(errorCard);
            }
        } else {
            if (errorCard.superview != nil) {
                errorCard.removeFromSuperview();
            }
            dashboardItems = [challengesCard, metricsCard, pulseCard];
            if (metricsSpinner == nil) {
                metricsSpinner = CustomLoadingSpinner(frame: CGRectMake(metricsCard.frame.size.width / 2 - 16, 84, 32, 32));
                metricsCard.addSubview(metricsSpinner)
            }
            if (metricsCard.superview == nil) {
                mainScrollView.addSubview(metricsCard);
                metricsSpinner.startAnimating();
            }
            if (SessionController.Instance.checkins != nil) {
                var bloodPressureCheckin: HigiCheckin, weightCheckin: HigiCheckin;
                var bps: [HigiCheckin] = [], weights: [HigiCheckin] = [];
                let dateFormatter = NSDateFormatter();
                dateFormatter.dateFormat = "MM/dd/yyyy";
                var lastBpDate = "", lastBmiDate = "";
                for checkin in SessionController.Instance.checkins {
                    var bpDate = dateFormatter.stringFromDate(checkin.dateTime);
                    if (checkin.systolic != nil && checkin.systolic > 0) {
                        if (bpDate != lastBpDate) {
                            bps.append(checkin);
                            lastBpDate = bpDate;
                        } else {
                            bps[bps.count - 1] = checkin;
                        }
                    }
                    var bmiDate = dateFormatter.stringFromDate(checkin.dateTime);
                    if (checkin.weightKG != nil && checkin.weightKG > 0) {
                        if (bmiDate != lastBmiDate) {
                            weights.append(checkin);
                            lastBmiDate = bmiDate;
                        } else {
                            weights[weights.count - 1] = checkin;
                        }
                    }
                }
                let cardMarginX:CGFloat = 8, cardMarginY:CGFloat = 16;
                var cardPositionY:CGFloat = 60;
                
                let activityColor = Utility.colorFromMetricType(MetricsType.DailySummary);
                let bloodPressureColor = Utility.colorFromMetricType(MetricsType.BloodPressure);
                let pulseColor = Utility.colorFromMetricType(MetricsType.Pulse);
                let weightColor = Utility.colorFromMetricType(MetricsType.Weight);
                
                activityCard = MetricsGraphCard.instanceFromNib("Activity", activity: (bps.last!.dateTime, 0), type: MetricsType.DailySummary);
                activityCard.frame.origin.y = cardPositionY;
                activityCard.frame.origin.x = cardMarginX;
                let activityTouched = UITapGestureRecognizer(target: self, action: "gotoActivityGraph:");
                activityCard.addGestureRecognizer(activityTouched);
                cardPositionY += activityCard.frame.size.height + cardMarginY;
                
                var firstDivider = UIView(frame: CGRect(x: 0, y: cardPositionY - cardMarginY / 2, width: self.view.frame.size.width, height: 1));
                firstDivider.backgroundColor = Utility.colorFromHexString("#EEEEEE");
                
                let bloodPressureCard = MetricsGraphCard.instanceFromNib("Blood Pressure", lastCheckin: bps.last!, type: MetricsType.BloodPressure);
                bloodPressureCard.frame.origin.y = cardPositionY;
                bloodPressureCard.frame.origin.x = cardMarginX;
                let bpTouched = UITapGestureRecognizer(target: self, action: "gotoBloodPressureGraph:");
                bloodPressureCard.addGestureRecognizer(bpTouched);
                cardPositionY += bloodPressureCard.frame.size.height + cardMarginY;
                
                var secondDivider = UIView(frame: CGRect(x: 0, y: cardPositionY - cardMarginY / 2, width: self.view.frame.size.width, height: 1));
                secondDivider.backgroundColor = Utility.colorFromHexString("#EEEEEE");
                
                let pulseCard = MetricsGraphCard.instanceFromNib("Pulse", lastCheckin: bps.last!, type: MetricsType.Pulse);
                pulseCard.frame.origin.y = cardPositionY;
                pulseCard.frame.origin.x = cardMarginX;
                let pulseTouched = UITapGestureRecognizer(target: self, action: "gotoPulseGraph:");
                pulseCard.addGestureRecognizer(pulseTouched);
                cardPositionY += pulseCard.frame.size.height + cardMarginY;
                
                var thirdDivider = UIView(frame: CGRect(x: 0, y: cardPositionY - cardMarginY / 2, width: self.view.frame.size.width, height: 1));
                thirdDivider.backgroundColor = Utility.colorFromHexString("#EEEEEE");
                
                let weightCard = MetricsGraphCard.instanceFromNib("Weight", lastCheckin: weights.last!, type: MetricsType.Weight);
                weightCard.frame.origin.y = cardPositionY;
                weightCard.frame.origin.x = cardMarginX;
                let weightTouched = UITapGestureRecognizer(target: self, action: "gotoWeightGraph:");
                weightCard.addGestureRecognizer(weightTouched);
                cardPositionY += weightCard.frame.size.height + cardMarginY;
                
                var checkins = SessionController.Instance.checkins;
                if (checkins != nil && checkins.count > 0) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var mapPoints:[GraphPoint] = [], bpmPoints:[GraphPoint] = [], weightPoints:[GraphPoint] = [];
                        for checkin in checkins {
                            if (checkin.map != nil) {
                                mapPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: checkin.map));
                            }
                            if (checkin.pulseBpm != nil) {
                                bpmPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.pulseBpm!)));
                            }
                            if (checkin.weightLbs != nil) {
                                weightPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: checkin.weightLbs));
                            }
                        }
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            var activityPoints:[GraphPoint] = [];
                            let dateString = Constants.dateFormatter.stringFromDate(NSDate());
                            var totalPoints = 0;
                            for (date, (total, activityList)) in SessionController.Instance.activities {
                                if (date == dateString) {
                                    totalPoints = total;
                                }
                                if (activityList.count > 0) {
                                    activityPoints.append(GraphPoint(x: Double(activityList[0].startTime.timeIntervalSince1970), y: Double(total)));
                                }
                            }
                            activityPoints.sort({$0.x > $1.x});
                            if (activityPoints.count > self.maxPointsToShow) {
                                activityPoints = Array(activityPoints[0..<self.maxPointsToShow]);
                            }
                            activityPoints = activityPoints.reverse();
                            dispatch_async(dispatch_get_main_queue(), {
                                self.activityCard.singleValue.text = "\(totalPoints)";
                                self.activityCard.graph(activityPoints, type: MetricsType.DailySummary);
                            });
                        });
                        dispatch_async(dispatch_get_main_queue(), {
                            if (mapPoints.count > self.maxPointsToShow) {
                                mapPoints = Array(mapPoints.reverse()[0..<self.maxPointsToShow]);
                            }
                            if (bpmPoints.count > self.maxPointsToShow) {
                                bpmPoints = Array(bpmPoints.reverse()[0..<self.maxPointsToShow]);
                            }
                            if (weightPoints.count > self.maxPointsToShow) {
                                weightPoints = Array(weightPoints.reverse()[0..<self.maxPointsToShow]);
                            }
                            bloodPressureCard.graph(mapPoints, type: MetricsType.BloodPressure);
                            pulseCard.graph(bpmPoints, type: MetricsType.Pulse);
                            weightCard.graph(weightPoints, type: MetricsType.Weight);
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
        }
        layoutDashboardItems(dashboardItems);
    }
    
    func initPulseCard() {
        var articles = SessionController.Instance.pulseArticles;
        if (articles.count > 2) {
            pulseCard.spinner.stopAnimating();
            pulseCard.loadingContainer.hidden = true;
            var topArticle = articles[0], middleArticle = articles[1], bottomArticle = articles[2];
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
        layoutDashboardItems(dashboardItems);
    }

    func gotoActivityGraph(sender: AnyObject) {
        Flurry.logEvent("ActivityMetric_Pressed");
        let viewController = MetricsViewController(nibName: "MetricsView", bundle: nil);
        viewController.selectedType = MetricsType.DailySummary;
        self.navigationController!.pushViewController(viewController, animated: true);
    }
    
    func gotoBloodPressureGraph(sender: AnyObject) {
        Flurry.logEvent("BpMetric_Pressed");
        let viewController = MetricsViewController(nibName: "MetricsView", bundle: nil);
        viewController.selectedType = MetricsType.BloodPressure;
        self.navigationController!.pushViewController(viewController, animated: true);
    }

    func gotoPulseGraph(sender: AnyObject) {
        Flurry.logEvent("PulseMetric_Pressed");
        let viewController = MetricsViewController(nibName: "MetricsView", bundle: nil);
        viewController.selectedType = MetricsType.Pulse;
        self.navigationController!.pushViewController(viewController, animated: true);
    }
    
    func gotoWeightGraph(sender: AnyObject) {
        Flurry.logEvent("WeightMetric_Pressed");
        let viewController = MetricsViewController(nibName: "MetricsView", bundle: nil);
        viewController.selectedType = MetricsType.Weight;
        self.navigationController!.pushViewController(viewController, animated: true);
    }
    
    @IBAction func gotoConnectDevices(sender: AnyObject) {
        Flurry.logEvent("ConnectDevice_Pressed");
        self.navigationController!.pushViewController(ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil), animated: true);
    }
    
    @IBAction func gotoChallenges(sender: AnyObject) {
        if (SessionController.Instance.challenges != nil) {
            Flurry.logEvent("Challenges_Pressed");
            self.navigationController!.pushViewController(ChallengesViewController(nibName: "ChallengesView", bundle: nil), animated: true);
            (self.navigationController as! MainNavigationController).drawerController?.tableView.reloadData();
            (self.navigationController as! MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
        }
    }
    
    @IBAction func gotoChallengeDetails(sender: AnyObject) {
        Flurry.logEvent("ActiveChallenge_Pressed");
        var detailsViewController = ChallengeDetailsViewController(nibName: "ChallengeDetailsView", bundle: nil);
        detailsViewController.challenge = displayedChallenge;
        self.navigationController!.pushViewController(detailsViewController, animated: true);
        (self.navigationController as! MainNavigationController).drawerController?.tableView.reloadData();
        (self.navigationController as! MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    @IBAction func gotoPulseHome(sender: AnyObject) {
        Flurry.logEvent("higiPulse_Pressed");
        self.navigationController!.pushViewController(PulseHomeViewController(nibName: "PulseHomeView", bundle: nil), animated: true);
        (self.navigationController as! MainNavigationController).drawerController?.tableView.reloadData();
        (self.navigationController as! MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 5, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    @IBAction func gotoPulseArticle(sender: AnyObject) {
        if (sender.tag! == 0) {
            Flurry.logEvent("FeaturedPulseArticle_Pressed");
        } else {
            Flurry.logEvent("NonFeaturedPulseArticle_Pressed");
        }
        var webView = WebViewController(nibName: "WebView", bundle: nil);
        var article: PulseArticle!;
        webView.url = SessionController.Instance.pulseArticles[sender.tag!].permalink;
        self.navigationController?.pushViewController(webView, animated: true);
        (self.navigationController as! MainNavigationController).drawerController?.tableView.reloadData();
        (self.navigationController as! MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 5, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavbar();
    }
    
    func updateNavbar() {
        var scrollY = mainScrollView.contentOffset.y;
        if (scrollY >= 0) {
            headerImage.frame.origin.y = -scrollY / 2;
            var alpha = min(scrollY / 100, 1);
            self.fakeNavBar.alpha = alpha;
            CATransaction.setDisableActions(true);
            refreshArc.strokeStart = 0.0;
            refreshArc.strokeEnd = 0.0;
            CATransaction.setDisableActions(false);
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
            if (alpha < 0.5) {
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
                self.navigationItem.rightBarButtonItem!.customView!.alpha = 1 - alpha;
                toggleButton!.alpha = 1 - alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
            } else {
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
                self.navigationItem.rightBarButtonItem!.customView!.alpha = alpha;
                toggleButton!.alpha = alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
            }
        } else {    // Pull refresh
            headerImage.frame.origin.y = 0;
            self.fakeNavBar.alpha = 0;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0)];
            var alpha = max(1.0 + scrollY / (mainScrollView.frame.size.height * 0.195), 0.0);
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
        
        var toPath = UIBezierPath();
        var radius = pullRefreshView.circleContainer.frame.size.width / 2.0;
        var center = CGPoint(x: radius, y: radius);
        var startingPoint = CGPoint(x: center.x, y: 0);
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
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.0)];
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
                var user = SessionData.Instance.user;
                self.initCards();
                self.doneRefreshing = true;
                self.refreshControl.endRefreshing();
            });
            
        });
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/qdata/\(SessionData.Instance.user.userId)?newSession=true", success: { operation, responseObject in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var login = HigiLogin(dictionary: responseObject as! NSDictionary);
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
    
    func layoutDashboardItems(items:[UIView]) {
        currentOrigin = contentOriginY;
        for item in dashboardItems {
            item.frame.origin.y = currentOrigin;
            currentOrigin += item.frame.size.height + gap;
        }
        mainScrollView.contentSize.height = currentOrigin;
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        mainScrollView.setContentOffset(CGPoint(x: 0, y: -mainScrollView.frame.size.height * 0.195), animated: true);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
}
