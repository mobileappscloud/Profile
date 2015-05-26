import Foundation

class DailySummaryViewController: UIViewController {
    
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

    var activities: [HigiDailyActivity] = [];
    
    var activityDictionary = [String: HigiDailyActivity](), checkinDictionary = [String: HigiDailyActivity]();
    
    var totalPoints = 0;
    
    var minCircleRadius:CGFloat = 15;
    
    struct HigiDailyActivity {
        var name:String!;
        var points = 0;
        var breakdowns:[ActivityBreakdown] = [];
        var color:UIColor!;
        var checkin:HigiCheckin?;
        
        struct ActivityBreakdown {
            var icon:UIImage!;
            var metric:String!;
            var points:Int!;
            
            init(icon:UIImage, points:Int, metric:String) {
                self.icon = icon;
                self.metric = metric;
                self.points = points;
            }
        }
        
        init(name: String, color: UIColor, points: Int, breakdowns: [ActivityBreakdown]) {
            self.name = name;
            self.color = color;
            self.points = points;
            self.breakdowns = breakdowns;
        }
        
        init(name: String, color: UIColor, points: Int, checkin: HigiCheckin) {
            self.name = name;
            self.color = color;
            self.points = points;
            self.checkin = checkin;
        }
        
        mutating func addBreakdown(breakdown: ActivityBreakdown) {
            breakdowns.append(breakdown);
        }
        
        mutating func addPoints(value: Int) {
            points += value;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Daily Summary";
        pointsMeter = UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PointsMeter;
        pointsMeterContainer.addSubview(pointsMeter);
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        initBackButton();
        initHeader();
        initScrollview();
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
    
    func initScrollview() {
        
        let date = NSDate();
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyyy";
        let dateString = dateFormatter.stringFromDate(date);
        if (SessionController.Instance.activities != nil) {
            for activity in SessionController.Instance.activities {
                let a = dateFormatter.stringFromDate(activity.startTime);
                if (dateFormatter.stringFromDate(activity.startTime) == dateString) {
                    let deviceName = String(activity.device.name);
                    if var dailyActivity = activityDictionary[deviceName] {
                        let points = activity.errorDescription == nil ? activity.points : 0;
                        let icon = iconFromActivityType(String(activity.typeCategory));
//                        if (dailyActivity.name == "higi") {

//                        } else {
                            dailyActivity.addPoints(points);
                            dailyActivity.addBreakdown(HigiDailyActivity.ActivityBreakdown(icon: icon, points: points, metric: String(activity.typeName)))
//                        }
                        activityDictionary[deviceName] = dailyActivity;
                    } else {
                        let points = activity.errorDescription == nil ? activity.points : 0;
                        let icon = iconFromActivityType(String(activity.typeCategory));
                        let dailyActivity = HigiDailyActivity(name: String(activity.device.name), color: Utility.colorFromHexString(activity.device.colorCode), points: points, breakdowns: [HigiDailyActivity.ActivityBreakdown(icon: icon, points: activity.points, metric: String(activity.typeName))]);
                        activityDictionary[deviceName] = dailyActivity;
                    }
                }
            }
            
            for (name, activity) in activityDictionary {
                activities.append(activity);
                totalPoints += activity.points;
            }
            activities.sort(sortByPoints);
            var currentOrigin = CGFloat(0), gap = CGFloat(5);
            for activity in activities {
                let activityRow = UINib(nibName: "DailySummaryRowView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryRow;
                activityRow.points.text = "\(activity.points)";
                activityRow.name.text = activity.name;
                activityRow.name.textColor = activity.color;
                let proportion = CGFloat(activity.points) / CGFloat(totalPoints);
                let newHeight = max(activityRow.progressCircle.frame.size.height * proportion, minCircleRadius * 2);
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: activityRow.progressCircle.frame.size.width / 2.0, y: activityRow.progressCircle.frame.size.height / 2.0), radius: newHeight / 2, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true);
                let circleLayer = CAShapeLayer();
                circleLayer.path = circlePath.CGPath;
                circleLayer.fillColor = UIColor.whiteColor().CGColor;
                circleLayer.strokeColor = activity.color.CGColor;
                circleLayer.lineWidth = 2.0;
                circleLayer.strokeEnd = 1;
                activityRow.progressCircle.layer.addSublayer(circleLayer);
                activityRow.frame.origin.y = currentOrigin;
                
                activityContainer.addSubview(activityRow);
                currentOrigin += activityRow.frame.size.height + gap;
                
                for breakdown in activity.breakdowns {
                    let breakdownRow = UINib(nibName: "DailySummaryBreakdownView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryBreakdown;
                    breakdownRow.frame.origin.y = currentOrigin;
                    breakdownRow.frame.origin.x = activityRow.name.frame.origin.x;
//                    if (activity.name == "higi") {
//                        
//                    } else {
                        breakdownRow.points.text = "\(breakdown.points)";
                        var metric = breakdown.metric;
                        breakdownRow.metric.text = breakdown.metric;
                        activityContainer.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height + gap;
//                    }
                }
            }
        }
    }
    
    func sortByPoints(this: HigiDailyActivity, that: HigiDailyActivity) -> Bool {
        return this.points >= that.points;
    }
    
    func iconFromActivityType(type: String) -> UIImage {
        return UIImage(named: "dailysummary_night")!;
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
}