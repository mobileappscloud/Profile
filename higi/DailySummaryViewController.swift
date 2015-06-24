import Foundation

class DailySummaryViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pointsMeterContainer: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var monthYear: UILabel!
    @IBOutlet weak var dayOfWeek: UILabel!
    @IBOutlet weak var dateNumber: UILabel!
    @IBOutlet weak var greeting: UILabel!
    @IBOutlet weak var headerBackground: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityContainer: UIView!
    @IBOutlet weak var scrollviewMainContentView: UIView!
    
    var titleRows:[UIView] = [];
    var pointsMeter:PointsMeter!;

    var activities: [HigiActivity] = [];
    
    var activityKeys: [String] = [];
    
    var activitiesByType:[String: (Int, [HigiActivity])] = [:];
    
    var totalPoints = 0;
    
    var minCircleRadius:CGFloat = 6, maxCircleRadius:CGFloat = 32, currentOrigin:CGFloat = 0, imageAspectRatio:CGFloat!;
    
    var backButton:UIButton!;
    
    var dateString: String!;
    
    var previousShouldRotate: Bool!;
    
    var previousSupportedOrientations: UInt!;
    
    var previousActualOrientation: Int!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.title = "Daily Summary";
        pointsMeter = PointsMeter.create();
        pointsMeterContainer.addSubview(pointsMeter);
        self.automaticallyAdjustsScrollViewInsets = false;
        scrollView.scrollEnabled = true;
        scrollView.delegate = self;
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: false);
        
        imageAspectRatio = headerBackground.frame.size.width / headerBackground.frame.size.height;
        
        initBackButton();
        initHeader();
        initSummaryview();

        pointsMeter.setActivities((totalPoints, activities));
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        let revealController = (navigationController as! MainNavigationController).revealController;
        previousActualOrientation = self.interfaceOrientation.rawValue;
        previousSupportedOrientations = revealController.supportedOrientations;
        previousShouldRotate = revealController.shouldRotate;
        revealController.panGestureRecognizer().enabled = false;
        revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue | UIInterfaceOrientationMask.LandscapeLeft.rawValue | UIInterfaceOrientationMask.LandscapeRight.rawValue;
        revealController.shouldRotate = true;
        activityView.frame.size.width = UIScreen.mainScreen().bounds.size.width;
        for row in titleRows {
            row.frame.size.width = UIScreen.mainScreen().bounds.size.width - row.frame.origin.x;
        }
        updateNavbar(0);
    }
    
    override func viewWillDisappear(animated: Bool) {
        let revealController = (self.navigationController as! MainNavigationController).revealController;
        revealController.supportedOrientations = previousSupportedOrientations;
        self.navigationController!.navigationBarHidden = false;
        UIDevice.currentDevice().setValue(previousActualOrientation, forKey: "orientation");
        revealController.shouldRotate = previousShouldRotate;
        super.viewWillDisappear(animated);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        pointsMeter.drawArc(true);
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activities.count;
    }
    
    func initBackButton() {
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        backButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    func initHeader() {
        var date:NSDate!;
        if (dateString == nil) {
            date = NSDate();
        } else {
            date = Constants.dateFormatter.dateFromString(dateString);
        }
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "dd";
        let monthYearFormatter = NSDateFormatter();
        monthYearFormatter.dateFormat = "MMMM yyyy";
        let dayOfWeekFormatter = NSDateFormatter();
        dayOfWeekFormatter.dateFormat = "EEEE";
        let hourFormatter = NSDateFormatter();
        hourFormatter.dateFormat = "HH";
        dateNumber.text = dateFormatter.stringFromDate(date);
        dayOfWeek.text = dayOfWeekFormatter.stringFromDate(date);
        monthYear.text = monthYearFormatter.stringFromDate(date);
        //Greeting should reflect current day's time even if we are looking at past daily summary
        let hour = hourFormatter.stringFromDate(NSDate()).toInt();
        if (hour >= 4 && hour < 12) {
            greeting.text = "Good Morning!";
            headerBackground.image = UIImage(named: "dailysummary_morning");
        } else if (hour >= 12 && hour < 17) {
            greeting.text = "Good Afternoon!";
            headerBackground.image = UIImage(named: "dailysummary_afternoon");
        } else {
            greeting.text = "Good Evening!";
            headerBackground.image = UIImage(named: "dailysummary_night");
        }
    }
    
    func initSummaryview() {
        if (dateString == nil) {
            dateString = Constants.dateFormatter.stringFromDate(NSDate());
        }
        if let (points, sessionActivities) = SessionController.Instance.activities[dateString] {
            totalPoints = points;
            activities = sessionActivities;
            activities.sort(sortByPoints);
        }
        for activity in activities {
            var type = ActivityCategory.categoryFromActivity(activity).getString();
            //TEMPORARY
            if (activity.device.name == "higi") {
                type = ActivityCategory.Health.getString();
            }
            //TEMPORARY
            if let (total, activityList) = activitiesByType[type] {
                var previousActivities = activityList;
                previousActivities.append(activity);
                var points = total;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByType[type] = (points, previousActivities);
            } else {
                var points = 0;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByType[type] = (points, [activity]);
                activityKeys.append(type);
            }
        }
        var gap = CGFloat(4);
        for key in activityKeys {
            let (total, activityList) = activitiesByType[key]!;
            let activity = activityList[0];
            let category = ActivityCategory.categoryFromString(key);
            let color = category.getColor();
            let activityRow = UINib(nibName: "DailySummaryRowView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryRow;
            activityRow.points.text = "\(total)";
            activityRow.name.text = String(category.getString());
            activityRow.name.textColor = color;
            let proportion = CGFloat(activity.points) / CGFloat(totalPoints);
            let newHeight = max(maxCircleRadius * proportion, minCircleRadius * 2);
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: activityRow.progressCircle.frame.size.width / 2.0, y: activityRow.progressCircle.frame.size.height / 2.0), radius: newHeight / 2, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true);
            let circleLayer = CAShapeLayer();
            circleLayer.path = circlePath.CGPath;
            circleLayer.fillColor = UIColor.whiteColor().CGColor;
            circleLayer.strokeColor = color.CGColor;
            circleLayer.lineWidth = 2.0;
            circleLayer.strokeEnd = 1;
            activityRow.progressCircle.layer.addSublayer(circleLayer);
            activityRow.frame.origin.y = currentOrigin
            
            activityContainer.addSubview(activityRow);
            currentOrigin += activityRow.frame.size.height - 4;
            let titleMargin:CGFloat = 2;
            for subActivity in activityList {
                let name = subActivity.device.name == "higi" ? "higi Station Check In" : "\(subActivity.device.name)";
                let titleRow = initTitleRow(activityRow.name.frame.origin.x, originY: currentOrigin, points: subActivity.points, device: name, color: color);
                activityContainer.addSubview(titleRow);
                titleRows.append(titleRow);
                currentOrigin += titleRow.frame.size.height + titleMargin;
                var isDuplicate = subActivity.errorDescription != nil;
                if (key == ActivityCategory.Lifestyle.getString()) {
                    let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, text: "Gym \(subActivity.typeName)", duplicate: isDuplicate);
                    activityContainer.addSubview(breakdownRow);
                    currentOrigin += breakdownRow.frame.size.height;
                } else if (key == ActivityCategory.Health.getString()) {
                    var lastSystolic = 0, lastDiastolic = 0, lastPulse = 0;
                    var lastBodyFat = 0.0, lastWeight = 0.0;
                    for checkin in SessionController.Instance.checkins {
                        if (Constants.dateFormatter.stringFromDate(checkin.dateTime) == dateString) {
                            if (lastDiastolic == 0 && checkin.diastolic != nil && checkin.diastolic > 0) {
                                lastDiastolic = checkin.diastolic!;
                            }
                            if (lastSystolic == 0 && checkin.systolic != nil && checkin.systolic > 0) {
                                lastSystolic = checkin.systolic!;
                            }
                            if (lastPulse == 0 && checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                                lastPulse = checkin.pulseBpm!;
                            }
                            if (lastWeight == 0 && checkin.weightLbs != nil && checkin.weightLbs > 0) {
                                lastWeight = checkin.weightLbs!;
                            }
                            if (lastBodyFat == 0 && checkin.fatRatio != nil && checkin.fatRatio > 0) {
                                lastBodyFat = checkin.fatRatio!;
                            }
                        }
                    }
                    if (lastDiastolic > 0) {
                        let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, text: "\(lastSystolic)/\(lastDiastolic) mmHg BP", duplicate: isDuplicate);
                        activityContainer.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height;
                    }
                    if (lastPulse > 0) {
                        let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, text: "\(lastPulse) bpm Pulse", duplicate: isDuplicate);
                        activityContainer.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height;
                    }
                    if (lastWeight > 0) {
                        let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, text: "\(Int(lastWeight)) lbs Weight", duplicate: isDuplicate);
                        activityContainer.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height;
                    }
                    if (lastBodyFat > 0) {
                        let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, text: "\(lastBodyFat)% Body Fat", duplicate: isDuplicate);
                        activityContainer.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height;
                    }
                } else if (key == ActivityCategory.Fitness.getString()) {
                    var text = "";
                    if (activity.steps > 0) {
                        text = "Walked \(subActivity.steps) steps";
                    } else if (activity.distance > 0) {
                        text = "Walked \(subActivity.distance) miles";
                    } else {
                        text = "Rode \(subActivity.distance) miles";
                    }
                    let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, text: text, duplicate: isDuplicate);
                    activityContainer.addSubview(breakdownRow);
                    currentOrigin += breakdownRow.frame.size.height;
                }
                if (isDuplicate) {
                    let labelHeight:CGFloat = 20;
                    let duplicateLabel = UILabel(frame: CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: scrollView.frame.size.width - activityRow.frame.origin.x, height: labelHeight));
                    duplicateLabel.text = "\(subActivity.errorDescription)";
                    duplicateLabel.textColor = UIColor.lightGrayColor();
                    duplicateLabel.font = UIFont.italicSystemFontOfSize(15);
                    activityContainer.addSubview(duplicateLabel);
                    currentOrigin += labelHeight;
                }
                currentOrigin += gap;
            }
        }
    }
    
    func initBreakdownRow(originX: CGFloat, originY: CGFloat, text: String, duplicate: Bool) -> DailySummaryBreakdown {
        let breakdownRow = UINib(nibName: "DailySummaryBreakdownView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryBreakdown;
        breakdownRow.frame.origin.y = originY;
        breakdownRow.frame.origin.x = originX;
        breakdownRow.desc.text = text;
        if (duplicate) {
            breakdownRow.desc.textColor = UIColor.lightGrayColor();
        }
        return breakdownRow;
    }
    
    func initTitleRow(originX: CGFloat, originY: CGFloat, points: Int, device: String, color: UIColor) -> BreakdownTitleRow {
        let titleRow = UINib(nibName: "BreakdownTitleRowView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BreakdownTitleRow;
        titleRow.frame.origin.x = originX;
        titleRow.frame.origin.y = originY;
        titleRow.frame.size.width = UIScreen.mainScreen().bounds.size.width - originX;
        titleRow.points.text = "\(points)";
        titleRow.device.text = device;
        titleRow.points.textColor = color;
        return titleRow;
    }
    
    func sortByPoints(this: HigiActivity, that: HigiActivity) -> Bool {
        return this.points >= that.points;
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollY = scrollView.contentOffset.y;
        if (scrollY >= 0) {
            headerBackground.frame.origin.y = scrollY * -0.5;
            updateNavbar(scrollY);
        } else {
            headerBackground.frame.origin.y = 0;
            headerView.frame.origin.y = 0;
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation);
        viewWillLayoutSubviews();
    }
    
    func updateNavbar(scrollY: CGFloat) {
        if (scrollY >= 0) {
            var alpha = min(scrollY / 75, 1);
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
            if (alpha < 0.5) {
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
                backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
            } else {
                self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
                backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
            }
        } else {
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 1)];
            self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        }
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        scrollView.contentSize.height = activityContainer.frame.origin.y + currentOrigin + activityView.frame.origin.y;
        activityView.frame.size.width = scrollView.frame.size.width;
        for row in titleRows {
            row.frame.size.width = scrollView.frame.size.width - row.frame.origin.x;
        }
    }
}