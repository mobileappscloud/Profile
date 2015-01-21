//
//  DashboardViewController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

import QuartzCore

class DashboardViewControllerOld: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var headerView: UIView!;
    @IBOutlet var tableView: UITableView!;
    
    @IBOutlet var blurredImage: UIImageView!;
    @IBOutlet var scoreRing: UIView!;
    @IBOutlet var scoreRingMask: UIView!;
    @IBOutlet var profileImage: UIImageView!;
    @IBOutlet var higiScore: UILabel!;
    @IBOutlet var name: UILabel!;
    
    @IBOutlet var lastCheckinDate: UILabel!;
    
    @IBOutlet var bpButton: UIButton!;
    @IBOutlet var pulseButton: UIButton!;
    @IBOutlet var mapButton: UIButton!;
    @IBOutlet var weightButton: UIButton!;
    @IBOutlet var bmiButton: UIButton!;
    @IBOutlet var higiPulseButton: UIButton!;
    
    @IBOutlet var noData: UIView!;
    @IBOutlet var findStationButton: UIButton!;
    @IBOutlet var checkPulseButton: UIButton!;
    
    @IBOutlet weak var checkinContainer: UIView!
    @IBOutlet weak var checkinBlur: UIView!
    @IBOutlet weak var checkinCardContainer: UIView!
    
    var arc: CAShapeLayer!, circle: CAShapeLayer!, refreshArc: CAShapeLayer!;
    
    var refreshControl: UIRefreshControl!;
    
    var pullRefreshView: PullRefresh!;
    
    var doneRefreshing = true, refreshing = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        var user = SessionData.Instance.user;
        name.text = "\(user.firstName) \(user.lastName)";
        self.title = "Dashboard";
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        var reminderButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30));
        reminderButton.setBackgroundImage(UIImage(named: "createreminder.png"), forState: UIControlState.Normal);
        reminderButton.addTarget(self, action: "setReminder:", forControlEvents: UIControlEvents.TouchUpInside);
        var reminderBarItem = UIBarButtonItem();
        reminderBarItem.customView = reminderButton;
        self.navigationItem.rightBarButtonItem = reminderBarItem;
        
        tableView.separatorInset = UIEdgeInsetsZero;
        
        createPullToRefresh();
        
        findStationButton.layer.borderWidth = 1.0;
        findStationButton.layer.borderColor = Utility.colorFromHexString("#76C044").CGColor;
        
        checkPulseButton.layer.borderWidth = 1.0;
        checkPulseButton.layer.borderColor = Utility.colorFromHexString("#76C044").CGColor;
        
        updateTiles();
        
        if (UIDevice.currentDevice().systemVersion >= "8.0") {
            var effect = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark));
            effect.frame = checkinBlur.frame;
            checkinBlur.addSubview(effect);
            tableView.layoutMargins = UIEdgeInsetsZero;
        } else {
            checkinBlur.backgroundColor = UIColor.blackColor();
            checkinBlur.alpha = 0.7;
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        updateNavbar();
        var user = SessionData.Instance.user;
        profileImage.image = user.profileImage;
        blurredImage.image = user.blurredImage;
        createScoreArc(SessionData.Instance.user.currentHigiScore);
        if (SessionController.Instance.pulseArticles.count > 0) {
            higiPulseButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFill;
            higiPulseButton.imageView!.clipsToBounds = true;
            var article = SessionController.Instance.pulseArticles.first!;
            higiPulseButton.setImage(UIImage(data: NSData(contentsOfURL: NSURL(string: article.imageUrl)!)!), forState: UIControlState.Normal);
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (!SessionData.Instance.seenDashboard) {
            SessionData.Instance.seenDashboard = true;
            SessionData.Instance.save();
            var tourController = TourViewController(nibName: "TourView", bundle: nil);
            tourController.mode = "dashboard";
            self.presentViewController(tourController, animated: false, completion: nil);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    @IBAction func bodyStatClicked(sender: AnyObject) {
        Flurry.logEvent("Bodystat_Pressed");
        var bodyStatsViewController = BodyStatsViewController();
        var tag = sender.tag;
        bodyStatsViewController.currentPage = sender.tag;
        self.navigationController!.pushViewController(bodyStatsViewController, animated: true);
        (self.navigationController as MainNavigationController).drawerController?.tableView.reloadData();
        (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 3, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    @IBAction func higiPulseClicked(sender: AnyObject) {
        Flurry.logEvent("HigiPulse_Pressed");
        (self.navigationController as MainNavigationController).drawerController?.tableView.reloadData();
        self.navigationController!.pushViewController(PulseHomeViewController(nibName: "PulseHomeView", bundle: nil), animated: true);
        (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 5, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
    }
    
    func updateTiles() {
        var checkins = SessionController.Instance.checkins;
        
        if (checkins.count > 0) {
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
            var dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "MMMM d, yyyy";
            lastCheckinDate.text = "Last updated: \(dateFormatter.stringFromDate(checkins[checkins.count - 1].dateTime))";
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
                        self.bpButton.setTitle("\(lastBpCheckin!.systolic!)/\(lastBpCheckin!.diastolic!)", forState: UIControlState.Normal);
                        self.pulseButton.setTitle("\(lastBpCheckin!.pulseBpm!)", forState: UIControlState.Normal);
                        self.mapButton.setTitle(String(format: "%.1f", lastBpCheckin!.map!), forState: UIControlState.Normal);
                    }
                    
                    if (lastWeightCheckin != nil) {
                        self.weightButton.setTitle("\(Int(lastWeightCheckin!.weightLbs!))", forState: UIControlState.Normal);
                        self.bmiButton.setTitle(String(format: "%.2f", lastWeightCheckin!.bmi!), forState: UIControlState.Normal);
                    }
                });
            });
            
        }
    }
    
    func setReminder(sender: AnyObject) {
        Flurry.logEvent("Reminder_Pressed");
        var reminderController = FindStationViewController(nibName: "FindStationView", bundle: nil);
        reminderController.reminderMode = true;
        self.navigationController!.pushViewController(reminderController, animated: true);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CheckinCell") as CheckinTableViewCell!;
        if (cell == nil) {
            cell = UINib(nibName: "CheckinTableViewCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CheckinTableViewCell;
        }
        cell.separatorInset = UIEdgeInsetsZero;
        if (UIDevice.currentDevice().systemVersion >= "8.0") {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        var checkin = SessionController.Instance.checkins[SessionController.Instance.checkins.count - 1 - indexPath.item];
        if (checkin.kioskInfo != nil) {
            cell.title.text = "\(checkin.kioskInfo!.organizations[0]) check-in";
            cell.address.text = checkin.kioskInfo!.fullAddress;
        } else {
            cell.title.text = "\(checkin.sourceVendorId!) check-in";
            cell.address.text = "";
        }
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MMMM d, yyyy";
        cell.date.text = dateFormatter.stringFromDate(checkin.dateTime);
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SessionController.Instance.checkins.count;
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        self.navigationController!.navigationBarHidden = true;
        self.navigationController!.navigationBar.userInteractionEnabled = false;
        self.fakeNavBar.hidden = true;
        checkinContainer.hidden = false;
        var checkinCard = UINib(nibName: "CheckinCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CheckinCard;
        checkinCard.frame.size = checkinCardContainer.frame.size;
        var checkin = SessionController.Instance.checkins[SessionController.Instance.checkins.count - 1 - indexPath.item];
        checkinCard.createTable(checkin, onClose: self.closeCheckinCard, onSelection: self.checkinMeasureSelected);
        checkinCardContainer.addSubview(checkinCard);
        checkinCard.frame.origin.y = checkinCardContainer.frame.size.height;
        
        UIView.animateWithDuration(0.15, delay: 0.0, options: .CurveEaseInOut, animations: {
            
            self.checkinContainer.alpha = 1.0;
            
            }, completion: {finished in
                UIView.animateWithDuration(0.35, delay: 0.0, options: .CurveEaseInOut, animations: {
                    
                    checkinCard.frame.origin.y = 0;
                    
                    }, completion: nil);
        });
        checkinCard.setupMap();
        self.revealController.panGestureRecognizer().enabled = false;
    }
    
    func closeCheckinCard(checkinCard: UIView) {
        
        UIView.animateWithDuration(0.35, delay: 0.0, options: .CurveEaseInOut, animations: {
            
            checkinCard.frame.origin.y = checkinCard.frame.size.height;
            
            }, completion: {finished in
                self.navigationController!.navigationBarHidden = false;
                self.fakeNavBar.hidden = false;
                self.navigationController!.navigationBar.userInteractionEnabled = true;
                UIView.animateWithDuration(0.15, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.checkinContainer.alpha = 0.0;
                    }, completion: {finished in
                        self.checkinContainer.hidden = true;
                });
                checkinCard.removeFromSuperview();
                self.revealController.panGestureRecognizer().enabled = true;
        });
    }
    
    func checkinMeasureSelected(checkin: HigiCheckin, selected: Int) {
        var bodyStats = BodyStatsViewController();
        bodyStats.selected = checkin;
        bodyStats.currentPage = selected;
        (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
        self.navigationController!.pushViewController(bodyStats, animated: true);
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        updateNavbar();
    }
    
    func updateNavbar() {
        var scrollY = tableView.contentOffset.y;
        if (scrollY >= 0) {
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
            self.fakeNavBar.alpha = 0;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0)];
            var alpha = max(1.0 + scrollY / (tableView.frame.size.height * 0.195), 0.0);
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
   
    @IBAction func gotoFindStation(sender: AnyObject) {
        Flurry.logEvent("NoDataFindStation_Pressed");
        (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
        self.navigationController!.pushViewController(FindStationViewController(nibName: "FindStationView", bundle: nil), animated: true);
    }
    
    @IBAction func gotoPulse(sender: AnyObject) {
        Flurry.logEvent("NoDataPulse_Pressed");
        (self.navigationController as MainNavigationController).drawerController?.tableView.selectRowAtIndexPath(NSIndexPath(forItem: 3, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None);
        self.navigationController!.pushViewController(PulseHomeViewController(nibName: "PulseHomeView", bundle: nil), animated: true);
    }
    
    func createScoreArc(score: Int) {
        higiScore.text = "0";
        if (score > 0) {
            if (arc == nil) {
                scoreRingMask.hidden = false;
                scoreRingMask.frame = CGRect(x: 43, y: 86, width: 14, height: 14);
                arc = CAShapeLayer();
                arc.lineWidth = 14;
                arc.fillColor = UIColor.whiteColor().CGColor;
                arc.strokeColor = Utility.colorFromHexString("#76C044").CGColor;
                
                var toPath = UIBezierPath();
                var center = CGPoint(x: 50.0, y: 50.0);
                var radius: CGFloat = 43.0;
                var startingPoint = CGPoint(x: center.x, y: center.y + radius);
                toPath.moveToPoint(startingPoint);
                toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(5 * M_PI_2), clockwise: true);
                toPath.closePath();
                
                arc.path = toPath.CGPath;
                scoreRing.layer.addSublayer(arc);
            }
            scoreRingMask.frame.origin = CGPoint(x: 43, y: 86);
            scoreRingMask.hidden = false;
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            arc.strokeStart = 0.0;
            arc.strokeEnd = 0.0;
            CATransaction.setDisableActions(false);
            CATransaction.commit();
            
            var percent = Double(score) / 999.0;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                NSThread.sleepForTimeInterval(0.25);
                var progress = 0.0;
                var startTime = NSDate().timeIntervalSince1970;
                var duration = 1.0;
                while (progress < 1) {
                    var currentTime = NSDate().timeIntervalSince1970;
                    progress = min((currentTime - startTime) / duration, 1.0);
                    var easeProg = (currentTime - startTime) / (duration / 2.0);
                    var drawPercent: Double;
                    
                    if (easeProg < 1) {
                        drawPercent = percent / 2.0 * pow(easeProg, 3.0);
                    } else {
                        easeProg -= 2;
                        drawPercent = percent / 2.0 * (pow(easeProg, 3.0) + 2.0);
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        // Turn off implicit animations on layer
                        CATransaction.begin();
                        CATransaction.setDisableActions(true);
                        self.arc.strokeEnd = CGFloat(drawPercent);
                        CATransaction.setDisableActions(false);
                        CATransaction.commit();
                        self.higiScore.text = "\(Int(Double(score) * (drawPercent / percent)))";
                        self.scoreRingMask.frame.origin = CGPoint(x: 43 * cos(drawPercent * M_PI * 2 + M_PI_2) + 43, y: 43 * sin(drawPercent * M_PI * 2 + M_PI_2) + 43);
                    });
                    
                    NSThread.sleepForTimeInterval(0.02);
                }
                
            });
        }
    }
    
    func createPullToRefresh() {
        pullRefreshView = UINib(nibName: "PullRefreshView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as PullRefresh;
        
        refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged);
        refreshControl.tintColor = UIColor.clearColor();
        refreshControl.backgroundColor = UIColor.clearColor();
        refreshControl.addSubview(pullRefreshView);
        tableView.addSubview(refreshControl);
        
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
        refreshing = true;
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
            
            while (self.refreshing) {
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.profileImage.image = user.profileImage;
                    self.blurredImage.image = user.blurredImage;
                });
                self.doneRefreshing = true;
                dispatch_async(dispatch_get_main_queue(), {
                    self.createScoreArc(user.currentHigiScore);
                });
                self.refreshControl.endRefreshing();
            });
            
        });
        
        HigiApi().sendGet("\(HigiApi.higiApiUrl)/data/qdata/\(SessionData.Instance.user.userId)?newSession=true", success: { operation, responseObject in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var login = HigiLogin(dictionary: responseObject as NSDictionary);
                SessionData.Instance.user = login.user;
                SessionData.Instance.user.retrieveProfileImages();
                ApiUtility.retrieveCheckins({
                    self.updateTiles();
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData();
                        self.refreshing = false;
                    });
                });
            });
           
        }, failure: nil);
        
        
    }
    
    
    
}
