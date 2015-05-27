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
    
    var pointsMeter:PointsMeter!;

    var activities: [HigiActivity] = [];
    
    var activityKeys: [String] = [];
    
    var activitiesByDevice:[String: (Int, [HigiActivity])] = [:];
    
    var totalPoints = 0;
    
    var minCircleRadius:CGFloat = 6, maxCircleRadius:CGFloat = 32;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Daily Summary";
        pointsMeter = UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PointsMeter;
        pointsMeterContainer.addSubview(pointsMeter);
        self.automaticallyAdjustsScrollViewInsets = false;
        scrollView.scrollEnabled = true;
        scrollView.frame = UIScreen.mainScreen().bounds;
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height);
        scrollView.delegate = self;
        
        initBackButton();
        initHeader();
        initSummaryview();
//        initSummaryview();

        pointsMeter.setActivities((totalPoints, activities));
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        scrollView.frame = UIScreen.mainScreen().bounds;
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        pointsMeter.drawArc();
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activities.count;
    }
    
    func initBackButton() {
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    func initHeader() {
        let date = NSDate();
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
        let hour = hourFormatter.stringFromDate(date).toInt();
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
        let dateString = Constants.dateFormatter.stringFromDate(NSDate());
        if let (points, sessionActivities) = SessionController.Instance.activities[dateString] {
            totalPoints = points;
            activities = sessionActivities;
            activities.sort(sortByPoints);
        }
        for activity in activities {
            let name = String(activity.device.name);
            if let (total, activityList) = activitiesByDevice[name] {
                var previousActivities = activityList;
                previousActivities.append(activity);
                var points = total;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByDevice[name] = (points, previousActivities);
            } else {
                var points = 0;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByDevice[name] = (points, [activity]);
                activityKeys.append(name);
            }
        }
        var currentOrigin = CGFloat(0), gap = CGFloat(5);
        for key in activityKeys {
            let (total, activityList) = activitiesByDevice[key]!;
            let activity = activityList[0];
            let color = Utility.colorFromHexString(activity.device.colorCode);
            let activityRow = UINib(nibName: "DailySummaryRowView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryRow;
            activityRow.points.text = "\(total)";
            activityRow.name.text = String(activity.device.name);
            if (activity.device.name == "higi") {
                activityRow.name.text = "higi Station";
            }
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
            activityRow.frame.origin.y = currentOrigin;
            
            activityContainer.addSubview(activityRow);
            currentOrigin += activityRow.frame.size.height;
            
            for subActivity in activityList {
                if (subActivity.category == "checkin") {
                    if (activity.checkinCategory == "location") {
                        let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, icon: UIImage(named: "workouticon")!, points: "", metric: "Went to \(subActivity.typeName)");
                        activityContainer.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height;
                    } else {
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
                            let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, icon: UIImage(named: "bloodpressureicon")!, points: "\(lastSystolic)/\(lastDiastolic)", metric: "mmHg");
                            activityContainer.addSubview(breakdownRow);
                            currentOrigin += breakdownRow.frame.size.height;
                        }
                        if (lastPulse > 0) {
                            let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, icon: UIImage(named: "pulseicon")!, points: "\(lastPulse)", metric: "bpm");
                            activityContainer.addSubview(breakdownRow);
                            currentOrigin += breakdownRow.frame.size.height;
                        }
                        if (lastWeight > 0) {
                            let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, icon: UIImage(named: "weighticon")!, points: "\(Int(lastWeight))", metric: "lbs");
                            activityContainer.addSubview(breakdownRow);
                            currentOrigin += breakdownRow.frame.size.height;
                        }
                        if (lastBodyFat > 0) {
                            let breakdownRow = initBreakdownRow(activityRow.name.frame.origin.x, originY: currentOrigin, icon: UIImage(named: "workouticon")!, points: "\(lastBodyFat)%", metric: "");
                            activityContainer.addSubview(breakdownRow);
                            currentOrigin += breakdownRow.frame.size.height;
                        }
                    }
                } else {
                    let breakdownRow = UINib(nibName: "DailySummaryBreakdownView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryBreakdown;
                    breakdownRow.frame.origin.y = currentOrigin;
                    breakdownRow.frame.origin.x = activityRow.name.frame.origin.x;
                    if (activity.steps > 0) {
                        breakdownRow.icon.image = UIImage(named: "stepsicon");
                        breakdownRow.metric.text = "steps";
                        breakdownRow.points.text = "\(subActivity.steps)";
                    } else if (activity.distance > 0) {
                        breakdownRow.icon.image = UIImage(named: "runicon");
                        breakdownRow.metric.text = "miles";
                        breakdownRow.points.text = "\(subActivity.distance)";
                    } else {
                        breakdownRow.icon.image = UIImage(named: "bikeicon");
                        breakdownRow.metric.text = "miles";
                        breakdownRow.points.text = "\(subActivity.distance)";
                    }
                    activityContainer.addSubview(breakdownRow);
                    currentOrigin += breakdownRow.frame.size.height;
                }
            }
            currentOrigin += gap;
        }
        let a = currentOrigin;
        let b = headerView.frame.size.height;
        let c = activityContainer.frame.size.height;
        let d = activityView.frame.origin.y;
        let e = activityView.frame.size.height;
        scrollView.contentSize.height = currentOrigin + headerView.frame.size.height;
    }
    
    func initBreakdownRow(originX: CGFloat, originY: CGFloat, icon: UIImage, points: String, metric: String) -> DailySummaryBreakdown {
        let breakdownRow = UINib(nibName: "DailySummaryBreakdownView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryBreakdown;
        breakdownRow.frame.origin.y = originY;
        breakdownRow.frame.origin.x = originX;
        breakdownRow.icon.image = icon;
        breakdownRow.points.text = points;
        breakdownRow.metric.text = metric;
        return breakdownRow;
    }
    
    func sortByPoints(this: HigiActivity, that: HigiActivity) -> Bool {
        return this.points >= that.points;
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let i = 0;
        let scrollY = max(scrollView.contentOffset.y, 0);
        headerBackground.frame.origin.y = scrollY * -0.5;
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
}