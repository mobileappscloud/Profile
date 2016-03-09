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
    
    var totalPoints = 0, largestActivityPoints = 0;
    
    var minCircleRadius:CGFloat = 8, maxCircleRadius:CGFloat = 20, currentOrigin:CGFloat = 0
    
    var dateString: String!;
    
    var isLeaving = false
    
    var timeOfDay:TimeOfDay!;
    
    var universalLinkCheckinsObserver: NSObjectProtocol? = nil
    var universalLinkActivitiesObserver: NSObjectProtocol? = nil
    
    enum TimeOfDay {
        case Morning;
        case Afternoon;
        case Evening;
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = NSLocalizedString("DAILY_SUMMARY_VIEW_TITLE", comment: "Title for Daily Summary view.")
        
        pointsMeter = PointsMeter.create(CGRect(x: 0, y: 0, width: pointsMeterContainer.frame.size.width, height: pointsMeterContainer.frame.size.height));
        pointsMeterContainer.addSubview(pointsMeter);
        self.automaticallyAdjustsScrollViewInsets = false;
        scrollView.scrollEnabled = true;
        scrollView.delegate = self;
        
        initHeader();
        initSummaryview();
        
        pointsMeter.setActivities((totalPoints, activities));
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        pointsMeter.drawArc(true);
        
        // Note 1) Hotfix to work around lack of complete autolayout constraints
        view.setNeedsLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Note 1) Hotfix to work around lack of complete autolayout constraints
        activityView.frame.size.width = UIScreen.mainScreen().bounds.width
        scrollView.contentSize.height = activityContainer.frame.origin.y + currentOrigin + activityView.frame.origin.y;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activities.count;
    }
    
    func initHeader() {
        var date:NSDate!;
        if (dateString == nil) {
            date = NSDate();
        } else {
            date = Constants.dateFormatter.dateFromString(dateString);
        }
        /*
            @internal If the date formatter assumes the current locale, then the strings for date format
            may be acceptable as-is since the individual units of date/time are being extracted. The layout of the actual labels may need to be refactored due to the fixed ordering of the labels.
        */
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "d";
        let monthYearFormatter = NSDateFormatter();
        monthYearFormatter.dateFormat = "MMMM yyyy";
        let dayOfWeekFormatter = NSDateFormatter();
        dayOfWeekFormatter.dateFormat = "EEEE";
        let hourFormatter = NSDateFormatter();
        hourFormatter.dateFormat = "HH";
        let dateNumberText = dateFormatter.stringFromDate(date);
        dateNumber.text = dateNumberText;
        dateNumber.frame.size.width = Utility.widthForTextView(dateNumber.frame.size.height, text: dateNumberText, fontSize: dateNumber.font.pointSize, margin: 0);
        dayOfWeek.text = dayOfWeekFormatter.stringFromDate(date);
        monthYear.text = monthYearFormatter.stringFromDate(date);
        //Greeting should reflect current day's time even if we are looking at past daily summary
        let hour = Int(hourFormatter.stringFromDate(NSDate()));
        if (hour >= 4 && hour < 12) {
            timeOfDay = TimeOfDay.Morning;
            greeting.text = NSLocalizedString("DAILY_SUMMARY_VIEW_HEADER_GREETING_MORNING_TEXT", comment: "Greeting text to display in header of the Daily Summary view during the morning.")
            headerBackground.image = UIImage(named: "dailysummary_morning");
        } else if (hour >= 12 && hour < 17) {
            timeOfDay = TimeOfDay.Afternoon;
            greeting.text = NSLocalizedString("DAILY_SUMMARY_VIEW_HEADER_GREETING_AFTERNOON_TEXT", comment: "Greeting text to display in header of the Daily Summary view during the afternoon.")
            headerBackground.image = UIImage(named: "dailysummary_afternoon");
        } else {
            timeOfDay = TimeOfDay.Evening;
            greeting.text = NSLocalizedString("DAILY_SUMMARY_VIEW_HEADER_GREETING_EVENING_TEXT", comment: "Greeting text to display in header of the Daily Summary view during the evening.")
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
            activities.sortInPlace(SummaryViewUtility.sortByPoints);
        }
        var activitiesByDevice: [String: String] = [:];
        for activity in activities {
            let type = activity.type.getString();
            if let (total, activityList) = activitiesByType[type] {
                var previousActivities = activityList;
                previousActivities.append(activity);
                var points = total;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByType[type] = (points, previousActivities);
                activitiesByDevice[String(activity.device.name)] = type;
            } else {
                activitiesByType[type] = (activity.points!, [activity]);
                activityKeys.append(type);
                activitiesByDevice[String(activity.device.name)] = type;
            }
        }
        
        if activities.count == 0 {
            layoutBlankState();
        } else {
            for (type, (total, activityList)) in activitiesByType {
                if total > largestActivityPoints {
                    largestActivityPoints = total;
                }
            }
            activityKeys.sortInPlace(sortByValue);
            layoutActivityView();
        }
    }

    func sortByValue(key1: String, key2: String) -> Bool {
        let (total1, list1) = activitiesByType[key1]!;
        let (total2, list2) = activitiesByType[key2]!;
        return total1 > total2;
    }

    func layoutBlankState() {
        let totalPoints = 140, higiPoints = 100, foursquarePoints = 15, morningPoints = 15, afternoonPoints = 15, activityTrackerPoints = 50;
        
        let higiTitle = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_HIGI_TITLE", comment: "Title for higi station; displayed on the Daily Summary view blank state.");
        let foursquareTitle = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_FOURSQUARE_TITLE", comment: "Title for Foursquare; displayed on the Daily Summary view blank state.");
        let activityTrackerTitle: String
        if HealthKitManager.isHealthDataAvailable() {
            activityTrackerTitle = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_ACTIVITY_TRACKER_BRANDED_TITLE", comment: "Title for branded activity tracker; displayed on the Daily Summary view blank state.");
        } else {
            activityTrackerTitle = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_ACTIVITY_TRACKER_TITLE", comment: "Title for activity tracker; displayed on the Daily Summary view blank state.");
        }
        let morningTitle = "", afternoonTitle = "";
        
        let higiText = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_HIGI_TEXT", comment: "Descriptive text for higi station; displayed on the Daily Summary view blank state.");
        let activityTrackerText = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_ACTIVITY_TRACKER_DEFAULT_TEXT", comment: "Default descriptive text for activity tracker; displayed on the Daily Summary view blank state.");
        let altActivityTrackerText = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_ACTIVITY_TRACKER_ALTERNATE_TEXT", comment: "Alternate descriptive text for activity tracker; displayed on the Daily Summary view blank state.");
        let foursquareText = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_FOURSQUARE_TEXT", comment: "Descriptive text for Foursquare; displayed on the Daily Summary view blank state.");
        let morningText = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_MORNING_TEXT", comment: "Descriptive text shown in the morning; displayed on the Daily Summary view blank state.");
        let afternoonText = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_AFTERNOON_TEXT", comment: "Descriptive text shown in the afternoon; displayed on the Daily Summary view blank state.");
        
        let higiCallToAction = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_CALL_TO_ACTION_FIND_STATION", comment: "Title for call-to-action to find a higi station; displayed in the Daily Summary blank-state view.");
        let morningCallToAction = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_CALL_TO_ACTION_FIND_STATION", comment: "Title for call-to-action to find a higi station; displayed in the Daily Summary blank-state view.");
        let afternoonCallToAction = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_CALL_TO_ACTION_FIND_STATION", comment: "Title for call-to-action to find a higi station; displayed in the Daily Summary blank-state view.");
        let connectDeviceCallToAction: String
        if HealthKitManager.isHealthDataAvailable() {
            connectDeviceCallToAction = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_CALL_TO_ACTION_CONNECT_DEVICE_BRANDED", comment: "Title for call-to-action to connect a branded device; displayed in the Daily Summary blank-state view.");
        } else {
            connectDeviceCallToAction = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_CALL_TO_ACTION_CONNECT_DEVICE", comment: "Title for call-to-action to connect a device; displayed in the Daily Summary blank-state view.");
        }
        let activityTrackerCallToAction = connectDeviceCallToAction;
        let foursquareCallToAction = NSLocalizedString("DAILY_SUMMARY_VIEW_BLANK_STATE_CALL_TO_ACTION_CONNECT_DEVICE", comment: "Title for call-to-action to connect a device; displayed in the Daily Summary blank-state view.")

        
        let higiButtonTarget:Selector = "higiCallToActionClicked:", activityTrackerButtonTarget:Selector = "activityTrackerCallToActionClicked:", foursquareButtonTarget:Selector = "foursquareCallToActionClicked:", morningButtonTarget:Selector = "morningCallToActionClicked:", afternoonButtonTarget:Selector = "afternoonCallToActionClicked:";
        
        let noCheckins = SessionController.Instance.checkins.count == 0;
        var noDevices = true;
        var devices = SessionController.Instance.devices;
        for (_, device) in devices {
            if let connected = device.connected where connected {
                noDevices = false;
                break;
            }
        }
        if noDevices {
            let semaphore = dispatch_semaphore_create(0)
            HealthKitManager.checkReadAuthorizationForStepData({ isAuthorized in
                noDevices = !isAuthorized
                dispatch_semaphore_signal(semaphore)
            })
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
        
        largestActivityPoints = 0;

        if noCheckins {
            createBlankStateRow(higiTitle, points: higiPoints, text: higiText, buttonCta: higiCallToAction, target: higiButtonTarget);
            if noDevices {
                createBlankStateRow(activityTrackerTitle, points: activityTrackerPoints, text: activityTrackerText, buttonCta: activityTrackerCallToAction, target: activityTrackerButtonTarget);
                createBlankStateRow(foursquareTitle, points: foursquarePoints, text: foursquareText, buttonCta: foursquareCallToAction, target: foursquareButtonTarget);
            }
        } else if noDevices {
            createBlankStateRow(activityTrackerTitle, points: activityTrackerPoints, text: altActivityTrackerText, buttonCta: activityTrackerCallToAction, target: activityTrackerButtonTarget);
        } else {
            if timeOfDay == TimeOfDay.Morning {
                createBlankStateRow(morningTitle, points: morningPoints, text: morningText, buttonCta: nil, target: nil);
            } else {
                createBlankStateRow(afternoonTitle, points: afternoonPoints, text: afternoonText, buttonCta: nil, target: nil);
            }
        }
    }
    
    func createBlankStateRow(title: String, points: Int, text: String, buttonCta: String?, target: Selector?) {
        let color = Utility.colorFromHexString("#444444");
        let titleMargin:CGFloat = -4, rowMargin:CGFloat = 4, buttonMargin: CGFloat = 16, textOffset: CGFloat = 16, alpha: CGFloat = 0.6;
        
        if largestActivityPoints < points {
            largestActivityPoints = points;
        }
        let titleRow = initActivityRow(title, points: points, totalPoints: largestActivityPoints, color: color, alpha: alpha);
        titleRow.frame.origin.y = currentOrigin;
        
        let rowWidth = UIScreen.mainScreen().bounds.size.width - titleRow.name.frame.origin.x - 10;
        let rowX = titleRow.name.frame.origin.x;
        
        rows.append(titleRow);
        margins.append(rowMargin);
        activityContainer.addSubview(titleRow);
        currentOrigin += titleRow.frame.size.height + titleMargin;
        
        let textRow = SummaryViewUtility.initBreakdownRow(CGRect(x: rowX - textOffset, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: text, duplicate: false);
        textRow.bulletPoint.hidden = true;
        textRow.desc.numberOfLines = 5
        textRow.desc.minimumScaleFactor = 0.5
        textRow.desc.sizeToFit()
        textRow.alpha = alpha;
        
        activityContainer.addSubview(textRow);
        textRow.translatesAutoresizingMaskIntoConstraints = false
        
        activityContainer.addConstraint(NSLayoutConstraint(item: textRow, attribute: .Top, relatedBy: .Equal, toItem: titleRow, attribute: .Bottom, multiplier: 1.0, constant: 5.0))
        activityContainer.addConstraint(NSLayoutConstraint(item: textRow, attribute: .Leading, relatedBy: .Equal, toItem: titleRow.name, attribute: .Leading, multiplier: 1.0, constant: -16.0))
        self.view.addConstraint(NSLayoutConstraint(item: textRow, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: -8.0))
        textRow.setNeedsUpdateConstraints()
        
        currentOrigin += textRow.frame.size.height + buttonMargin;
        descriptionRows.append(textRow);
        rows.append(textRow);
        margins.append(buttonMargin);
        
        if buttonCta != nil && target != nil {
            let button = initCallToActionButton(rowX, text: buttonCta!, action: target!);
            activityContainer.addSubview(button);
            currentOrigin += button.frame.size.height + buttonMargin;
            rows.append(button);
            margins.append(buttonMargin);
        }
    }
    
    func layoutActivityView() {
        for key in activityKeys {
            let (total, activityList) = activitiesByType[key]!;
            let category = ActivityCategory.categoryFromString(key);
            let color = category.getColor();
            let activityRow = initActivityRow(String(category.getString()), points: total, totalPoints: totalPoints, color: color, alpha: 1);
            activityRow.frame.origin.y = currentOrigin;
            
            let rowMargin:CGFloat = -4;
            rows.append(activityRow);
            margins.append(rowMargin);
            
            var checkinIndex = 0;
            activityContainer.addSubview(activityRow);
            currentOrigin += activityRow.frame.size.height + rowMargin;
            let rowWidth = UIScreen.mainScreen().bounds.size.width - activityRow.name.frame.origin.x;
            for subActivity in activityList {
                if key != ActivityCategory.Health.getString() {
                    let titleRow = SummaryViewUtility.initTitleRow(activityRow.name.frame.origin.x, originY: currentOrigin, width: rowWidth, points: subActivity.points, device: "\(subActivity.device.name)", color: color);
                    activityContainer.addSubview(titleRow);
                    titleRows.append(titleRow);
                    
                    rows.append(titleRow);
                    margins.append(0);
                    
                    currentOrigin += titleRow.frame.size.height;
                }
                let isDuplicate = subActivity.errorDescription != nil;
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
                        margins.append(0);
                        
                        currentOrigin += titleRow.frame.size.height;
                        
                        if let checkin = findCheckin(subActivity) {
                            if checkin.diastolic != nil && checkin.diastolic > 0 {
                                let suffix = NSLocalizedString("DAILY_SUMMARY_VIEW_ACTIVITY_BREAKDOWN_ROW_TEXT_BLOOD_PRESSURE", comment: "Text to display in activity breakdown of the daily summary view for blood pressure activity.")
                                let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: "\(checkin.systolic!)/\(checkin.diastolic!) \(suffix)", duplicate: isDuplicate);
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
                                let suffix = NSLocalizedString("DAILY_SUMMARY_VIEW_ACTIVITY_BREAKDOWN_ROW_TEXT_PULSE", comment: "Text to display in activity breakdown of the daily summary view for heart rate activity.")
                                let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: "\(checkin.pulseBpm!) \(suffix)", duplicate: isDuplicate);
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
                                let suffix = NSLocalizedString("DAILY_SUMMARY_VIEW_ACTIVITY_BREAKDOWN_ROW_TEXT_WEIGHT", comment: "Text to display in activity breakdown of the daily summary view for weigh-in activity.")
                                let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: "\(Int(checkin.weightLbs!)) \(suffix)", duplicate: isDuplicate);
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
                                let suffix = NSLocalizedString("DAILY_SUMMARY_VIEW_ACTIVITY_BREAKDOWN_ROW_TEXT_BODY_FAT", comment: "Text to display in activity breakdown of the daily summary view for body fat measurement.")
                                let breakdownRow = SummaryViewUtility.initBreakdownRow(CGRect(x: activityRow.name.frame.origin.x, y: currentOrigin, width: rowWidth, height: CGFloat.max), text: String(format: "%.2f", checkin.fatRatio!) + " \(suffix)", duplicate: isDuplicate);
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
                }
                if isDuplicate {
                    let duplicateLabel = SummaryViewUtility.initDuplicateLabel(activityRow.name.frame.origin.x, originY: currentOrigin, width: scrollView.frame.size.width - activityRow.frame.origin.x, text: "\(subActivity.errorDescription)");
                    activityContainer.addSubview(duplicateLabel);
                    currentOrigin += duplicateLabel.frame.size.height;
                    
                    rows.append(duplicateLabel);
                    margins.append(0);
                }
                let titleBottomMargin:CGFloat = 15;
                if margins.count > 0 {
                    margins[margins.count - 1] = titleBottomMargin
                }
                currentOrigin += titleBottomMargin;
            }
        }
    }

    func initActivityRow(title: String, points: Int, totalPoints: Int, color: UIColor, alpha: CGFloat) -> DailySummaryRow {
        let activityRow = UINib(nibName: "DailySummaryRowView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! DailySummaryRow;
        activityRow.points.text = "\(points)";
        activityRow.points.alpha = alpha;
        activityRow.name.text = title;
        activityRow.name.textColor = color;
        activityRow.name.alpha = alpha + 0.1;

        let proportion = CGFloat(points) / CGFloat(largestActivityPoints);

        let newHeight = max(maxCircleRadius * proportion, minCircleRadius);
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: activityRow.progressCircle.frame.size.width / 2.0, y: activityRow.progressCircle.frame.size.height / 2.0), radius: newHeight, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true);
        let circleLayer = CAShapeLayer();
        circleLayer.path = circlePath.CGPath;
        circleLayer.fillColor = UIColor.whiteColor().CGColor;
        circleLayer.strokeColor = color.colorWithAlphaComponent(alpha + 0.1).CGColor;
        circleLayer.lineWidth = 2.0;
        circleLayer.strokeEnd = 1;
        activityRow.progressCircle.layer.addSublayer(circleLayer);
        activityRow.frame.origin.y = currentOrigin;
        
        return activityRow;
    }
    
    func initCallToActionButton(x: CGFloat, text: String, action: Selector) -> UIButton {
        let buttonWidth: CGFloat = 140, buttonHeight: CGFloat = 40;
        let button = UIButton(frame: CGRect(x: x, y: currentOrigin, width: buttonWidth, height: buttonHeight));
        button.setTitle(text, forState: UIControlState.Normal);
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(14);
        button.backgroundColor = Utility.colorFromHexString(Constants.higiGreen);
        button.layer.cornerRadius = 4;
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside);
        button.userInteractionEnabled = true;
        return button;
    }
    
    func findCheckin(activity: HigiActivity ) -> HigiCheckin? {
        if SessionController.Instance.checkins != nil {
            let formatter = NSDateFormatter();
            formatter.dateFormat = "yyyyMMddHHmm";
            for checkin in Array(SessionController.Instance.checkins.reverse()) {
                let date1 = formatter.stringFromDate(activity.utcStartTime);
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
        } else {
            headerBackground.frame.origin.y = 0;
            headerView.frame.origin.y = 0;
        }
    }
    
    // MARK: -
    
    func higiCallToActionClicked(sender: AnyObject!) {
        navigateToFindStationView();
    }
    
    func activityTrackerCallToActionClicked(sender: AnyObject!) {
        navigateToConnectDeviceView();
    }
    
    func foursquareCallToActionClicked(sender: AnyObject!) {
        navigateToConnectDeviceView();
    }
    
    func morningCallToActionClicked(sender: AnyObject!) {
        navigateToFindStationView();
    }
    
    func afternoonCallToActionClicked(sender: AnyObject!) {
        navigateToFindStationView();
    }
    
    func navigateToConnectDeviceView() {
        Flurry.logEvent("ConnectDevice_Pressed");
        
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    ConnectDeviceViewController.navigateToConnectDevice()
                })
            })
        })
    }
    
    func navigateToFindStationView() {
        Flurry.logEvent("FindStation_Pressed");
        
        guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    mainTabBarController.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                    mainTabBarController.selectedIndex = TabBarController.ViewControllerIndex.FindStation.rawValue
                })
            })
        })
    }
}

extension DailySummaryViewController: UniversalLinkHandler {
    
    func handleUniversalLink(URL: NSURL, pathType: PathType, parameters: [String]?) {
        
        var loadedActivities = false
        var loadedCheckins = false
        let application = UIApplication.sharedApplication().delegate as! AppDelegate
        if application.didRecentlyLaunchToContinueUserActivity() {
            let loadingViewController = self.presentLoadingViewController()
            
            self.universalLinkActivitiesObserver = NSNotificationCenter.defaultCenter().addObserverForName(ApiUtility.ACTIVITIES, object: nil, queue: nil, usingBlock: { (notification) in
                loadedActivities = true
                self.pushDailySummary(loadedActivities, loadedCheckins: loadedCheckins, presentedViewController: loadingViewController)
                if let observer = self.universalLinkActivitiesObserver {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
            })
            self.universalLinkCheckinsObserver = NSNotificationCenter.defaultCenter().addObserverForName(ApiUtility.CHECKINS, object: nil, queue: nil, usingBlock: { (notification) in
                loadedCheckins = true
                self.pushDailySummary(loadedActivities, loadedCheckins: loadedCheckins, presentedViewController: loadingViewController)
                if let observer = self.universalLinkCheckinsObserver {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
            })
        } else {
            self.pushDailySummary(true, loadedCheckins: true, presentedViewController: nil)
        }
    }
    
    private func pushDailySummary(loadedActivities: Bool, loadedCheckins: Bool, presentedViewController: UIViewController?) {
        if !loadedActivities || !loadedCheckins {
            return
        }
        guard let mainTabBarController = Utility.mainTabBarController() else { return }
        
        InterfaceOrientation.force(.Portrait)
        
        let dailySummaryViewController = DailySummaryViewController(nibName: "DailySummaryView", bundle: nil)
        dailySummaryViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: dailySummaryViewController, action: Selector("didTapDoneButton:"))
        let dailySummaryNav = UINavigationController(rootViewController: dailySummaryViewController)
        dispatch_async(dispatch_get_main_queue(), {
            presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            mainTabBarController.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
            mainTabBarController.presentViewController(dailySummaryNav, animated: true, completion: nil)
        })
    }
}

extension DailySummaryViewController {
    
    func didTapDoneButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
