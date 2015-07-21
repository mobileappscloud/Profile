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
    
    var rows:[UIView] = [], titleRows:[UIView] = [];
    
    var margins:[CGFloat] = [];
    
    var descriptionRows:[DailySummaryBreakdown] = [];
    
    var pointsMeter:PointsMeter!;

    var activities: [HigiActivity] = [];
    
    var activityKeys: [String] = [];
    
    var activitiesByType:[String: (Int, [HigiActivity])] = [:];
    
    var totalPoints = 0;
    
    var minCircleRadius:CGFloat = 6, maxCircleRadius:CGFloat = 22, currentOrigin:CGFloat = 0, gap:CGFloat = 4, imageAspectRatio:CGFloat!;
    
    var backButton:UIButton!;
    
    var dateString: String!;
    
    var isLeaving = false, previousShouldRotate: Bool!;
    
    var previousSupportedOrientations: UInt!;
    
    var previousActualOrientation: Int!;
    
    var fakeNavBar:UIView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.title = "Daily Summary";
        pointsMeter = PointsMeter.create(CGRect(x: 0, y: 0, width: pointsMeterContainer.frame.size.width, height: pointsMeterContainer.frame.size.height));
        pointsMeterContainer.addSubview(pointsMeter);
        self.automaticallyAdjustsScrollViewInsets = false;
        scrollView.scrollEnabled = true;
        scrollView.delegate = self;
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: false);
        
        imageAspectRatio = headerBackground.frame.size.width / headerBackground.frame.size.height;
        
        initBackButton();
        initHeader();
        initSummaryview();
        
        scrollView.contentSize = activityContainer.frame.size;
        
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
    
    override func prefersStatusBarHidden() -> Bool {
        return false;
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
        let screenWidth = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height);
        fakeNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64));
        fakeNavBar.backgroundColor = UIColor.whiteColor();
        view.addSubview(fakeNavBar);
    }
    
    func initSummaryview() {
        if (dateString == nil) {
            dateString = Constants.dateFormatter.stringFromDate(NSDate());
        }
        if let (points, sessionActivities) = SessionController.Instance.activities[dateString] {
            totalPoints = points;
            activities = sessionActivities;
            activities.sort(SummaryViewUtility.sortByPoints);
        }
        var activitiesByDevice: [String: String] = [:];
        for activity in activities {
            var type = ActivityCategory.categoryFromActivity(activity).getString();
            if let (total, activityList) = activitiesByType[type] {
                let a = activitiesByDevice[String(activity.device.name)];
                if activitiesByDevice[String(activity.device.name)] == nil || type == ActivityCategory.Health.getString() {
                    var previousActivities = activityList;
                    previousActivities.append(activity);
                    var points = total;
                    if (activity.points > 0 && activity.errorDescription == nil) {
                        points += activity.points!;
                    }
                    activitiesByType[type] = (points, previousActivities);
                    activitiesByDevice[String(activity.device.name)] = type;
                }
            } else {
                var points = 0;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByType[type] = (points, [activity]);
                activityKeys.append(type);
                activitiesByDevice[String(activity.device.name)] = type;
            }
        }
        
        layoutActivityView();
    }

    func layoutActivityView() {
        for key in activityKeys {
            let (total, activityList) = activitiesByType[key]!;
            let category = ActivityCategory.categoryFromString(key);
            let color = category.getColor();
            let activityRow = UINib(nibName: "DailySummaryRowView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryRow;
            activityRow.points.text = "\(total)";
            activityRow.name.text = String(category.getString());
            activityRow.name.textColor = color;
            let proportion = CGFloat(total) / CGFloat(totalPoints);
            let newHeight = max(maxCircleRadius * proportion, minCircleRadius);
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: activityRow.progressCircle.frame.size.width / 2.0, y: activityRow.progressCircle.frame.size.height / 2.0), radius: newHeight, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true);
            let circleLayer = CAShapeLayer();
            circleLayer.path = circlePath.CGPath;
            circleLayer.fillColor = UIColor.whiteColor().CGColor;
            circleLayer.strokeColor = color.CGColor;
            circleLayer.lineWidth = 2.0;
            circleLayer.strokeEnd = 1;
            activityRow.progressCircle.layer.addSublayer(circleLayer);
            activityRow.frame.origin.y = currentOrigin;
            
            let rowMargin:CGFloat = -4;
            rows.append(activityRow);
            margins.append(rowMargin);
            
            var checkinIndex = 0;
            activityContainer.addSubview(activityRow);
            currentOrigin += activityRow.frame.size.height + rowMargin;
            let titleMargin:CGFloat = 6;
            let rowWidth = UIScreen.mainScreen().bounds.size.width - activityRow.name.frame.origin.x;
            var activitiesByDevice:[String: Bool] = [:];
            for subActivity in activityList {
                if key != ActivityCategory.Health.getString() {
                    let titleRow = SummaryViewUtility.initTitleRow(activityRow.name.frame.origin.x, originY: currentOrigin, width: rowWidth, points: subActivity.points, device: "\(subActivity.device.name)", color: color);
                    activityContainer.addSubview(titleRow);
                    titleRows.append(titleRow);
                    
                    rows.append(titleRow);
                    margins.append(titleMargin);
                    
                    currentOrigin += titleRow.frame.size.height + titleMargin;
                }
                var isDuplicate = subActivity.errorDescription != nil;
                if key == ActivityCategory.Lifestyle.getString() {
                    let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: "\(subActivity.description)", duplicate: isDuplicate);
                    activityContainer.addSubview(breakdownRow);
                    currentOrigin += breakdownRow.frame.size.height;
                    descriptionRows.append(breakdownRow);
                    
                    rows.append(breakdownRow);
                    margins.append(0);
                } else if key == ActivityCategory.Health.getString() {
                    let grayedAlpha: CGFloat = 0.5;
                    var hasCheckinData = false;
                    if let checkin = findCheckin(subActivity) {
                        hasCheckinData = true;
                    }
                    if subActivity.points > 0 || hasCheckinData {
                        let titleRow = SummaryViewUtility.initTitleRow(activityRow.name.frame.origin.x, originY: currentOrigin, width: rowWidth, points: subActivity.points, device: "\(subActivity.device.name)", color: color);
                        if subActivity.points == 0 {
                            titleRow.alpha = grayedAlpha;
                        }
                        activityContainer.addSubview(titleRow);
                        titleRows.append(titleRow);
                        
                        rows.append(titleRow);
                        margins.append(titleMargin);
                        
                        currentOrigin += titleRow.frame.size.height + titleMargin;
                        
                        if let checkin = findCheckin(subActivity) {
                            if checkin.diastolic != nil && checkin.diastolic > 0 {
                                let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: "\(checkin.systolic!)/\(checkin.diastolic!) mmHg BP", duplicate: isDuplicate);
                                if subActivity.points == 0 {
                                    breakdownRow.alpha = grayedAlpha;
                                }
                                activityContainer.addSubview(breakdownRow);
                                currentOrigin += breakdownRow.frame.size.height;
                                descriptionRows.append(breakdownRow);
                                
                                rows.append(breakdownRow);
                                margins.append(0);
                            }
                            if checkin.pulseBpm != nil && checkin.pulseBpm > 0 {
                                let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: "\(checkin.pulseBpm!) bpm Pulse", duplicate: isDuplicate);
                                if subActivity.points == 0 {
                                    breakdownRow.alpha = grayedAlpha;
                                }
                                activityContainer.addSubview(breakdownRow);
                                currentOrigin += breakdownRow.frame.size.height;
                                descriptionRows.append(breakdownRow);
                                
                                rows.append(breakdownRow);
                                margins.append(0);
                            }
                            if checkin.weightLbs != nil && checkin.weightLbs > 0 {
                                let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: "\(Int(checkin.weightLbs!)) lbs Weight", duplicate: isDuplicate);
                                if subActivity.points == 0 {
                                    breakdownRow.alpha = grayedAlpha;
                                }
                                activityContainer.addSubview(breakdownRow);
                                currentOrigin += breakdownRow.frame.size.height;
                                descriptionRows.append(breakdownRow);
                                
                                rows.append(breakdownRow);
                                margins.append(0);
                            }
                            if checkin.fatRatio != nil && checkin.fatRatio > 0 {
                                let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: String(format: "%.2f", checkin.fatRatio!) + "% Body Fat", duplicate: isDuplicate);
                                if subActivity.points == 0 {
                                    breakdownRow.alpha = grayedAlpha;
                                }
                                activityContainer.addSubview(breakdownRow);
                                currentOrigin += breakdownRow.frame.size.height;
                                descriptionRows.append(breakdownRow);
                                
                                rows.append(breakdownRow);
                                margins.append(0);
                            }
                        }
                    }
                } else if key == ActivityCategory.Fitness.getString() {
                    let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: "\(subActivity.description)", duplicate: isDuplicate);
                    activityContainer.addSubview(breakdownRow);
                    currentOrigin += breakdownRow.frame.size.height;
                    descriptionRows.append(breakdownRow);
                    
                    rows.append(breakdownRow);
                    margins.append(0);
                    activitiesByDevice[String(subActivity.device.name)] = true;
                }
                if isDuplicate {
                    let duplicateLabel = SummaryViewUtility.initDuplicateLabel(activityRow.name.frame.origin.x, originY: currentOrigin, width: scrollView.frame.size.width - activityRow.frame.origin.x, text: "\(subActivity.errorDescription)");
                    activityContainer.addSubview(duplicateLabel);
                    currentOrigin += duplicateLabel.frame.size.height;
                    
                    rows.append(duplicateLabel);
                    margins.append(0);
                }
                currentOrigin += gap;
            }
        }
    }

    func findCheckin(activity: HigiActivity ) -> HigiCheckin? {
        if SessionController.Instance.checkins != nil {
            let formatter = NSDateFormatter();
            formatter.dateFormat = "yyyyMMddHHmm";
            for checkin in SessionController.Instance.checkins.reverse() {
                let date1 = formatter.stringFromDate(activity.startTime);
                let date2 = formatter.stringFromDate(checkin.dateTime);
                if date1 == date2 {
                    let tests = activity.healthChecks;
                    var earnditTotal = 0, higiTotal = 0;
                        for test in tests {
                            switch (test) {
                                case "bloodPressure", "systolicPressure", "diastolicPressure":
                                    if (earnditTotal % 2 == 0) {
                                        earnditTotal += 1;
                                    }
                                    break;
                                case "heartRate":
                                    earnditTotal += 2;
                                    break;
                                case "weight":
                                    earnditTotal += 4;
                                    break;
                                case "bodyFatPercentage":
                                    earnditTotal += 8;
                                    break;
                                default:
                                    break;
                            }
                        }
                        if checkin.systolic != nil && checkin.systolic > 0 {
                            higiTotal += 1;
                        }
                        if checkin.pulseBpm != nil && checkin.pulseBpm > 0 {
                            higiTotal += 2;
                        }
                        if checkin.weightLbs != nil && checkin.weightLbs > 0 {
                            higiTotal += 4;
                        }
                        if checkin.fatRatio != nil && checkin.fatRatio > 0 {
                            higiTotal += 8;
                        }
                        if earnditTotal == higiTotal {
                            return checkin;
                        }
                } else if activity.startTime.timeIntervalSince1970 > checkin.dateTime.timeIntervalSince1970 {
                    break;
                }
            }
        }
        return nil;
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
        if (!isLeaving) {
            if (scrollY >= 0) {
                var alpha = min(scrollY / 75, 1);
                fakeNavBar.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: alpha);
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
                if (alpha < 0.5) {
                    self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
                    backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
                } else {
                    self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
                    backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
                }
            } else {
                fakeNavBar.backgroundColor = UIColor.whiteColor();
                self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 1)];
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
            }
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false);
        updateNavbar(0);
        resizeActivityRows(toInterfaceOrientation == UIInterfaceOrientation.Portrait);
    }
    
    func resizeActivityRows(forPortrait: Bool) {
        if descriptionRows.count > 0 {
            var rowWidth:CGFloat = max(UIScreen.mainScreen().bounds.size.height, UIScreen.mainScreen().bounds.size.width);
            if forPortrait {
                rowWidth = min(UIScreen.mainScreen().bounds.size.height, UIScreen.mainScreen().bounds.size.width);
            }
            rowWidth -= descriptionRows[0].frame.origin.x;
            for row in descriptionRows {
                row.frame.size.width = rowWidth;
                row.frame.size.height = Utility.heightForTextView(rowWidth, text: row.desc.text!, fontSize: row.desc.font.pointSize, margin: 0);
                row.desc.sizeToFit();
            }
        }

        var i = 0;
        var originY:CGFloat = 0;
        for row in rows {
            row.frame.origin.y = originY;
            originY += row.frame.size.height + margins[i];
            i++;
        }
    }
    
    func goBack(sender: AnyObject!) {
        isLeaving = true;
        self.navigationController!.popViewControllerAnimated(false);
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