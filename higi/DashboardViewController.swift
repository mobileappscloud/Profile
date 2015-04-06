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
    
    @IBOutlet var activityCard: ActivityCard!
    
    @IBOutlet var challengesCard: ChallengesCard!
    
    @IBOutlet weak var bodyStatsCard: BodyStatsCard!
    
    @IBOutlet weak var pulseCard: PulseCard!
    
    @IBOutlet var errorCard: UIView!
    
    var pointsMeter: PointsMeter!;
    
    var currentOrigin: CGFloat = 0, gap: CGFloat = 10;
    
    var arc: CAShapeLayer!, circle: CAShapeLayer!, refreshArc: CAShapeLayer!;
    
    var refreshControl: UIRefreshControl!;
    
    var pullRefreshView: PullRefresh!;
    
    var displayedChallenge: HigiChallenge!;
    
    var doneRefreshing = true, activitiesRefreshed = true, challengesRefreshed = true, checkinsRefreshed = true, devicesRefreshed = true;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Dashboard";
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        var reminderButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30));
        reminderButton.setBackgroundImage(UIImage(named: "createreminder.png"), forState: UIControlState.Normal);
        reminderButton.addTarget(self, action: "setReminder:", forControlEvents: UIControlEvents.TouchUpInside);
        var reminderBarItem = UIBarButtonItem();
        reminderBarItem.customView = reminderButton;
        self.navigationItem.rightBarButtonItem = reminderBarItem;
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
    
    func receiveApiNotification(notification: NSNotification) {
        switch (notification.name) {
        case ApiUtility.ACTIVITIES:
            if (doneRefreshing) {
                initActivityCard();
                pointsMeter.drawArc();
            }
            activitiesRefreshed = true;
        case ApiUtility.CHALLENGES:
            if (doneRefreshing) {
                initChallengesCard();
            }
            challengesRefreshed = true;
        case ApiUtility.CHECKINS:
            if (doneRefreshing) {
                initBodyStatsCard();
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
        if (activityCard.superview != nil) {
            activityCard.removeFromSuperview();
        }
        if (challengesCard.superview != nil) {
            challengesCard.removeFromSuperview();
        }
        bodyStatsCard.removeFromSuperview();
        pulseCard.removeFromSuperview();
        currentOrigin = 83;
        initActivityCard();
        initChallengesCard();
        initBodyStatsCard();
        initPulseCard();
        mainScrollView.contentSize.height = currentOrigin;
    }
    
    func initActivityCard() {
        if (pointsMeter == nil) {
            pointsMeter = UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as PointsMeter;
            activityCard.meterContainer.addSubview(pointsMeter);
        }
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyyy";
        var todaysActivity: [HigiActivity] = [];
        var today = dateFormatter.stringFromDate(NSDate());
        var todaysPoints = 0;
        if (SessionController.Instance.activities != nil) {
            for activity in SessionController.Instance.activities {
                var dateString = dateFormatter.stringFromDate(activity.startTime);
                if (today != dateString) {
                    break;
                }
                if (activity.errorDescription == nil) {
                    todaysActivity.append(activity);
                    todaysPoints += activity.points;
                }
            }
        }

        activityCard.spinner = CustomLoadingSpinner(frame: CGRectMake(activityCard.loadingContainer.frame.size.width / 2 - 16, activityCard.loadingContainer.frame.size.height / 2 - 16, 32, 32));
        activityCard.loadingContainer.addSubview(activityCard.spinner);
        
        if (todaysPoints > 0) {
            pointsMeter.hidden = false;
            activityCard.blankStateImage.hidden = true;
            pointsMeter.activities = todaysActivity;
            pointsMeter.points.text = "\(todaysPoints)";
            pointsMeter.drawArc();
        } else {
            pointsMeter.hidden = true;
            activityCard.blankStateImage.hidden = false;
        }

        if (todaysPoints > 0 || !SessionController.Instance.earnditError) {
            if (activityCard.superview == nil) {
                activityCard.frame.origin.y = currentOrigin;
                currentOrigin += activityCard.frame.size.height + gap;
                mainScrollView.addSubview(activityCard);
                activityCard.spinner.startAnimating();
            } else {
                activityCard.spinner.stopAnimating();
                activityCard.loadingContainer.hidden = true;
            }
        } else {
            if (errorCard.superview == nil) {
                errorCard.frame.origin.y = currentOrigin;
                currentOrigin += errorCard.frame.size.height + gap;
                mainScrollView.addSubview(errorCard);
                activityCard.loadingContainer.hidden = true;
                activityCard.spinner.stopAnimating();
            }
        }
    }
    
    func initChallengesCard() {
        
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
        
        challengesCard.challengeBox.layer.borderColor = Utility.colorFromHexString("#CCCCCC").CGColor;
        challengesCard.spinner = CustomLoadingSpinner(frame: CGRectMake(activityCard.loadingContainer.frame.size.width / 2 - 16, activityCard.loadingContainer.frame.size.height / 2 - 16, 32, 32));
        challengesCard.loadingContainer.addSubview(challengesCard.spinner);
        
        if (displayedChallenge != nil) {
            challengesCard.loadingContainer.hidden = true;
            challengesCard.spinner.stopAnimating();
            challengesCard.challengeBox.hidden = false;
            challengesCard.blankStateImage.hidden = true;
            challengesCard.challengeAvatar.setImageWithURL(NSURL(string: displayedChallenge.imageUrl));
            challengesCard.challengeTitle.text = displayedChallenge.name;
            if (challengesCard.challengeBox.subviews.count > 3) {
                (challengesCard.challengeBox.subviews[challengesCard.challengeBox.subviews.count - 1] as UIView).removeFromSuperview();
            }
            var challengeView = Utility.getChallengeViews(displayedChallenge, frame: CGRect(x: 0, y: 56, width: challengesCard.challengeBox.frame.size.width, height: 180), isComplex: false)[0];
            challengesCard.challengeBox.addSubview(challengeView);
            challengeView.userInteractionEnabled = false;
            challengeView.animate();
        } else {
            challengesCard.challengeBox.hidden = true;
            challengesCard.blankStateImage.hidden = false;
        }
        
        if ((displayedChallenge != nil || !SessionController.Instance.earnditError) && challengesCard.superview == nil) {
            challengesCard.frame.origin.y = currentOrigin;
            currentOrigin += challengesCard.frame.size.height + gap;
            mainScrollView.addSubview(challengesCard);
            challengesCard.spinner.startAnimating();
        }
    }
    
    func initBodyStatsCard() {
        
        bodyStatsCard.lastCheckinBox.layer.borderColor = Utility.colorFromHexString("#CCCCCC").CGColor;
        
        var checkins = SessionController.Instance.checkins;
        
        if (checkins != nil && checkins.count > 0) {
            var dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "MMM d, yyyy";
            bodyStatsCard.lastCheckin.text = "\(dateFormatter.stringFromDate(checkins[checkins.count - 1].dateTime))";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var lastBpCheckin, lastWeightCheckin: HigiCheckin?;
                for index in lazy(0...checkins.count - 1).reverse() {
                    if (lastBpCheckin == nil && checkins[index].systolic != nil) {
                        lastBpCheckin = checkins[index];
                    }
                    if (lastWeightCheckin == nil && checkins[index].weightKG != nil) {
                        lastWeightCheckin = checkins[index];
                    }
                    
                    if (lastBpCheckin != nil && lastWeightCheckin != nil) {
                        break;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    if (lastBpCheckin != nil) {
                        self.bodyStatsCard.bpButton.setTitle("\(lastBpCheckin!.systolic!)/\(lastBpCheckin!.diastolic!)", forState: UIControlState.Normal);
                        self.bodyStatsCard.pulseButton.setTitle("\(lastBpCheckin!.pulseBpm!)", forState: UIControlState.Normal);
                        self.bodyStatsCard.mapButton.setTitle(String(format: "%.1f", lastBpCheckin!.map!), forState: UIControlState.Normal);
                    }
                    
                    if (lastWeightCheckin != nil) {
                        self.bodyStatsCard.weightButton.setTitle("\(Int(lastWeightCheckin!.weightLbs!))", forState: UIControlState.Normal);
                        self.bodyStatsCard.bmiButton.setTitle(String(format: "%.2f", lastWeightCheckin!.bmi!), forState: UIControlState.Normal);
                    }
                });
            });
            
        }
        
        if (bodyStatsCard.superview == nil) {
            bodyStatsCard.frame.origin.y = currentOrigin;
            currentOrigin += bodyStatsCard.frame.size.height + gap;
            mainScrollView.addSubview(bodyStatsCard);
        }
    }
    
    func initPulseCard() {
        var articles = SessionController.Instance.pulseArticles;
        if (articles.count > 2) {
            pulseCard.spinner.stopAnimating();
            pulseCard.loadingContainer.hidden = true;
            var topArticle = articles[0], middleArticle = articles[1], bottomArticle = articles[2];
            pulseCard.topImage.setImageWithURL(NSURL(string: topArticle.imageUrl));
            pulseCard.topTitle.text = topArticle.title;
            pulseCard.topExcerpt.text = topArticle.excerpt;
            pulseCard.middleImage.setImageWithURL(NSURL(string: middleArticle.imageUrl));
            pulseCard.middleTitle.text = middleArticle.title;
            pulseCard.middleExcerpt.text = middleArticle.excerpt;
            pulseCard.bottomImage.setImageWithURL(NSURL(string: bottomArticle.imageUrl));
            pulseCard.bottomTitle.text = bottomArticle.title;
            pulseCard.bottomExcerpt.text = bottomArticle.excerpt;
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
    }
    
    @IBAction func gotoActivities(sender: AnyObject) {
        if (SessionController.Instance.activities != nil) {
            Flurry.logEvent("Activity_Pressed");
            self.navigationController!.pushViewController(ActivityViewController(nibName: "ActivityView", bundle: nil), animated: true);
            (self.navigationController as MainNavigationController).drawerController?.tableView.reloadData();
            (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
        }
    }
    
    @IBAction func gotoConnectDevices(sender: AnyObject) {
        Flurry.logEvent("ConnectDevice_Pressed");
        self.navigationController!.pushViewController(ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil), animated: true);
    }
    
    @IBAction func gotoChallenges(sender: AnyObject) {
        if (SessionController.Instance.challenges != nil) {
            Flurry.logEvent("Challenges_Pressed");
            self.navigationController!.pushViewController(ChallengesViewController(nibName: "ChallengesView", bundle: nil), animated: true);
            (self.navigationController as MainNavigationController).drawerController?.tableView.reloadData();
            (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
        }
    }
    
    @IBAction func gotoChallengeDetails(sender: AnyObject) {
        Flurry.logEvent("ActiveChallenge_Pressed");
        var detailsViewController = ChallengeDetailsViewController(nibName: "ChallengeDetailsView", bundle: nil);
        detailsViewController.challenge = displayedChallenge;
        self.navigationController!.pushViewController(detailsViewController, animated: true);
        (self.navigationController as MainNavigationController).drawerController?.tableView.reloadData();
        (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    @IBAction func gotoPulseHome(sender: AnyObject) {
        Flurry.logEvent("higiPulse_Pressed");
        self.navigationController!.pushViewController(PulseHomeViewController(nibName: "PulseHomeView", bundle: nil), animated: true);
        (self.navigationController as MainNavigationController).drawerController?.tableView.reloadData();
        (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 5, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
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
        (self.navigationController as MainNavigationController).drawerController?.tableView.reloadData();
        (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 5, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
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
            pullRefreshView.icon.alpha = 0.0;
            pullRefreshView.circleContainer.alpha = 0.0;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
            if (alpha < 0.5) {
                (self.navigationItem.rightBarButtonItem!.customView as UIButton).setBackgroundImage(UIImage(named: "createreminder.png"), forState: UIControlState.Normal);
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
                self.navigationItem.rightBarButtonItem!.customView!.alpha = 1 - alpha;
                toggleButton!.alpha = 1 - alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
            } else {
                (self.navigationItem.rightBarButtonItem!.customView as UIButton).setBackgroundImage(UIImage(named: "createreminder_inverted.png"), forState: UIControlState.Normal);
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
                    //tableView.scrollEnabled = false;
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents();
                    refresh();
                }
            }
        }
    }
    
    
    func createPullToRefresh() {
        pullRefreshView = UINib(nibName: "PullRefreshView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as PullRefresh;
        
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
                UIApplication.sharedApplication().endIgnoringInteractionEvents();
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
                self.pointsMeter.drawArc();
                self.doneRefreshing = true;
                self.refreshControl.endRefreshing();
            });
            
        });
        
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/qdata/\(SessionData.Instance.user.userId)?newSession=true", success: { operation, responseObject in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var login = HigiLogin(dictionary: responseObject as NSDictionary);
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
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        mainScrollView.setContentOffset(CGPoint(x: 0, y: -mainScrollView.frame.size.height * 0.195), animated: true);
    }
    
    func setReminder(sender: AnyObject) {
        Flurry.logEvent("Reminder_Pressed");
        var reminderController = FindStationViewController(nibName: "FindStationView", bundle: nil);
        reminderController.reminderMode = true;
        self.navigationController!.pushViewController(reminderController, animated: true);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
}
