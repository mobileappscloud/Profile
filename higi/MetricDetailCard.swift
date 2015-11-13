import Foundation

class MetricDetailCard: UIView {
    @IBOutlet weak var firstPanel: UIView!
    @IBOutlet weak var firstPanelValue: UILabel!
    @IBOutlet weak var secondPanel: UIView!
    @IBOutlet weak var secondPanelValue: UILabel!
    @IBOutlet weak var secondPanelUnit: UILabel!
    @IBOutlet weak var secondPanelLabel: UILabel!
    @IBOutlet weak var thirdPanel: UIView!
    @IBOutlet weak var thirdPanelValue: UILabel!
    @IBOutlet weak var thirdPanelUnit: UILabel!
    @IBOutlet weak var thirdPanelLabel: UILabel!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var bodyContainer: UIView!
    @IBOutlet weak var copyScrollview: UIScrollView!
    @IBOutlet weak var gaugeContainer: UIView!
    @IBOutlet weak var meterContainer: UIView!
    @IBOutlet weak var secondPanelHeader: UILabel!
    @IBOutlet weak var thirdPanelHeader: UILabel!
    @IBOutlet weak var checkinLocation: UILabel!
    @IBOutlet weak var checkinStreetAddress: UILabel!
    @IBOutlet weak var checkinCityStateZip: UILabel!
    @IBOutlet weak var checkinAddressContainer: UIView!

    var secondPanelExtraLabel: UILabel!, thirdPanelExtraLabel: UILabel!;
    
    var triangleIndicator: TriangleView!;
    
    var gauge: MetricGauge!;
    
    var meter: PointsMeter!;
    
    var delegate: MetricDelegate!;
    
    let triangleHeight:CGFloat = 20;
    
    var copyImageOrigin:CGFloat = 0, copyScrollViewHeight: CGFloat = 0, screenWidth:CGFloat!, activityRowHeight:CGFloat = 0;
    
    var thirdPanelSelected = true, blankState = false, shouldShowCenteredSecondPanel = false, shouldShowCenteredThirdPanel = false;
    
    var firstCopyImage: UIImageView!, secondCopyImage: UIImageView!;
    
    var activityRows:[BreakdownTitleRow] = [];
    
    let scrollViewPadding:CGFloat = 20;
    
    class func instanceFromNib(card: MetricCard) -> MetricDetailCard {
        let view = UINib(nibName: "MetricDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricDetailCard;
        view.setupView(card.delegate);
        view.updateCard(card);
        return view;
    }

    func updateCard(card: MetricCard) {
        if let selected = card.getSelectedPoint() {
            setData(selected);
        } else {
            blankState = true;
        }
    }
    
    func updateCopyImageIfNeeded() {
        let tab = thirdPanelSelected ? 1 : 0;
        switchCopyImage(tab);
    }
    
    func switchCopyImage(tab: Int) {
        if firstCopyImage != nil && secondCopyImage != nil {
            if tab == 0 {
                firstCopyImage.hidden = false;
                secondCopyImage.hidden = true;
                self.copyScrollview.contentSize.height = self.copyImageOrigin + self.firstCopyImage.frame.origin.y + firstCopyImage.frame.size.height + self.scrollViewPadding;
            } else {
                firstCopyImage.hidden = true;
                secondCopyImage.hidden = false;
                self.copyScrollview.contentSize.height = self.copyImageOrigin + self.firstCopyImage.frame.origin.y + secondCopyImage.frame.size.height + self.scrollViewPadding;
            }
            if (delegate.getType() == MetricsType.DailySummary) {
                secondCopyImage.frame.origin.y = copyImageOrigin;
            }
        }
    }
    
    func updateCopyImage(tab: Int) {
        if firstCopyImage != nil {
            firstCopyImage.removeFromSuperview();
        }
        if secondCopyImage != nil {
            secondCopyImage.removeFromSuperview();
        }
        let firstImage = delegate.getCopyImage(0);
        let secondImage = delegate.getCopyImage(1);
        
        let newFirstHeight = (firstImage.size.height / firstImage.size.width) * copyScrollview.frame.size.width;
        let newSecondHeight = (secondImage.size.height / secondImage.size.width) * copyScrollview.frame.size.width;
        let newWidth = copyScrollview.frame.size.width;

        firstCopyImage = UIImageView(frame: CGRect(x: 0, y: copyImageOrigin, width: newWidth, height: newFirstHeight));
        firstCopyImage.hidden = true;
        secondCopyImage = UIImageView(frame: CGRect(x: 0, y: copyImageOrigin, width: newWidth, height: newSecondHeight));
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let firstScaledImage = Utility.scaleImage(firstImage, newSize: CGSize(width: newWidth, height: newFirstHeight));
            let secondScaledImage = Utility.scaleImage(secondImage, newSize: CGSize(width: newWidth, height: newSecondHeight));
            dispatch_async(dispatch_get_main_queue(), {
                self.firstCopyImage.image = firstScaledImage;
                self.secondCopyImage.image = secondScaledImage;
                self.copyScrollview.contentSize.height = self.copyImageOrigin + self.firstCopyImage.frame.origin.y + newSecondHeight + self.scrollViewPadding;
                self.copyScrollview.addSubview(self.firstCopyImage);
                self.copyScrollview.addSubview(self.secondCopyImage);
            });
        });
    }
    
    func animateBounceIn(destination: CGFloat) {
        self.frame.origin.y = UIScreen.mainScreen().bounds.height;
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
            self.frame.origin.y = destination;
            }, completion: { complete in
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                    self.frame.origin.y = destination + 10;
                    }, completion: { complete in
                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                            self.frame.origin.y = destination;
                            }, completion: { complete in
                                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                                    self.frame.origin.y = destination + 4;
                                    }, completion: { complete in
                                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                                            self.frame.origin.y = destination;
                                            }, completion: nil);
                                });
                        });
                });
        });
    }
    
    func animateBounceOut() {
        let height = UIScreen.mainScreen().bounds.height;
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
            self.frame.origin.y = height;
            }, completion: { complete in
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                    self.frame.origin.y = height - 10;
                    }, completion: { complete in
                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                            self.frame.origin.y = height;
                            }, completion: { complete in
                                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                                    self.frame.origin.y = height - 4;
                                    }, completion: { complete in
                                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                                            self.frame.origin.y = height;
                                            }, completion: nil);
                                });
                        });
                });
        });
    }
    
    func getCurrentTab() -> Int {
        return thirdPanelSelected ? 1 : 0;
    }
    
    func secondPanelClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).openDetailsIfClosed();
        if secondPanelValue.text != "" {
            if (thirdPanelSelected) {
                moveToSecondPanel();
            }
            thirdPanelSelected = false;
        }
    }
    
    func thirdPanelClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).openDetailsIfClosed();
        if (!thirdPanelSelected) {
            moveToThirdPanel();
        }
        thirdPanelSelected = true;
    }
    
    func moveToSecondPanel() {
        if triangleIndicator != nil {
            triangleIndicator.frame = CGRect(x: secondPanel.frame.origin.x + secondPanel.frame.size.width / 2 - triangleHeight / 2, y: secondPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
        }
        let tab = 0;
        if gauge != nil {
            gauge.setData(delegate, tab: tab);
        }
        switchCopyImage(tab);
    }
    
    func moveToThirdPanel() {
        if triangleIndicator != nil {
        triangleIndicator.frame = CGRect(x: screenWidth - thirdPanel.frame.size.width / 2 - triangleHeight / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
        }
        let tab = 1;
        if gauge != nil {
            gauge.setData(delegate, tab: tab);
        }
        switchCopyImage(tab);
    }
    
    func setupView(delegate: MetricDelegate) {
        self.delegate = delegate;
        
        screenWidth = max(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height);
        
        self.frame.size.width = screenWidth;
        headerContainer.frame.size.width = screenWidth;
        bodyContainer.frame.size.width = screenWidth;
        
        let secondPanelTap = UITapGestureRecognizer(target: self, action: "secondPanelClicked:");
        secondPanel.addGestureRecognizer(secondPanelTap);
        let thirdPanelTap = UITapGestureRecognizer(target: self, action: "thirdPanelClicked:");
        thirdPanel.addGestureRecognizer(thirdPanelTap);
        
        setMetricType(delegate);
    }
    
    func setMetricType(delegate: MetricDelegate) {
        self.delegate = delegate;
        let color = delegate.getColor();
        
        firstPanelValue.textColor = color;
        secondPanelValue.textColor = color;
        thirdPanelValue.textColor = color;
                
        if let selected = delegate.getSelectedPoint() {
            setData(selected);
            blankState = false;
        } else {
            blankState = true;
        }
        
        thirdPanelSelected = true;
        moveToThirdPanel();
        
        updateCopyImage(1);
    }
    
    func setData(selection: SelectedPoint) {
        let tab = thirdPanelSelected ? 1 : 0;
        
        firstPanelValue.text = Constants.displayDateFormatter.stringFromDate(Constants.dateFormatter.dateFromString(selection.date!)!);
        secondPanelUnit.text = selection.firstPanel.unit;
        secondPanelLabel.text = selection.firstPanel.label;
        thirdPanelUnit.text = selection.secondPanel.unit;
        thirdPanelLabel.text = selection.secondPanel.label;
        
        secondPanelHeader.text = selection.firstPanel.label;
        thirdPanelHeader.text = selection.secondPanel.label;
        
        if selection.firstPanel.unit == "" && selection.firstPanel.value != "" {
            if secondPanelExtraLabel == nil {
                secondPanelExtraLabel = initCenteredLabel(CGRect(x: secondPanel.frame.origin.x, y: secondPanelValue.frame.origin.y, width: secondPanel.frame.size.width - (2 * secondPanelValue.frame.origin.x), height: secondPanelValue.frame.size.height));
                secondPanelValue.addSubview(secondPanelExtraLabel);
            }
            secondPanelExtraLabel.hidden = false;
            shouldShowCenteredSecondPanel = true;
            secondPanelExtraLabel.text = selection.firstPanel.value;
            secondPanel.hidden = true;
        } else if selection.firstPanel.unit == "" && selection.firstPanel.value == "" {
            secondPanel.hidden = true;
            if secondPanelExtraLabel != nil {
                secondPanelExtraLabel.hidden = true;
            }
            shouldShowCenteredSecondPanel = false;
        } else {
            secondPanel.hidden = false;
            secondPanelValue.text = selection.firstPanel.value;
            secondPanelValue.hidden = false;
            if secondPanelExtraLabel != nil {
                secondPanelExtraLabel.hidden = true;
            }
            shouldShowCenteredSecondPanel = false;
        }
        if selection.secondPanel.unit == "" && selection.secondPanel.value != "" {
            if thirdPanelExtraLabel == nil {
                thirdPanelExtraLabel = initCenteredLabel(CGRect(x: thirdPanelValue.frame.origin.x, y: thirdPanelValue.frame.origin.y, width: thirdPanel.frame.size.width - (2 * thirdPanelValue.frame.origin.x), height: thirdPanelValue.frame.size.height));
                thirdPanel.addSubview(thirdPanelExtraLabel);
            }
            thirdPanelExtraLabel.hidden = false;
            thirdPanelExtraLabel.text = selection.secondPanel.value;
            thirdPanelValue.hidden = true;
            shouldShowCenteredThirdPanel = true;
        } else if selection.secondPanel.unit == "" && selection.secondPanel.value == "" {
            thirdPanel.hidden = true;
            if thirdPanelExtraLabel != nil {
                thirdPanelExtraLabel.hidden = true;
            }
            shouldShowCenteredThirdPanel = false;

        } else {
            thirdPanelValue.text = selection.secondPanel.value;
            thirdPanel.hidden = false;
            thirdPanelValue.hidden = false;
            if thirdPanelExtraLabel != nil {
                thirdPanelExtraLabel.hidden = true;
            }
            shouldShowCenteredThirdPanel = false;
        }

        if activityRows.count > 0 {
            for row in activityRows {
                row.removeFromSuperview();
            }
        }
        copyImageOrigin = scrollViewPadding;

        if (delegate.getType() == MetricsType.DailySummary) {
            meterContainer.hidden = false;
            gaugeContainer.hidden = true;
            checkinAddressContainer.hidden = true;
            if meter == nil {
                meter = initMeterView();
                meterContainer.addSubview(meter);
            }
            let dateString = delegate.getSelectedPoint()!.date!;
            if (SessionController.Instance.activities[dateString] != nil) {
                meter.setActivities(SessionController.Instance.activities[dateString]!);
            } else {
                meter.setActivities((0, []));
            }
            meter.drawArc(false);
            initSummaryview(dateString);
        } else {
            meterContainer.hidden = true;
            gaugeContainer.hidden = false;
            
            var title = "", address = "", cityStateZip = "";
            
            if let device = selection.device {
                title = device;
            }
            
            if let kioskInfo = selection.kioskInfo {
                title = "higi Station at \(kioskInfo.organizations[0])";
                address = "\(kioskInfo.address1)";
                cityStateZip = "\(kioskInfo.cityStateZip)";
            }
            
            checkinAddressContainer.hidden = false;
            checkinLocation.text = title;
            checkinStreetAddress.text = address;
            checkinCityStateZip.text = cityStateZip;
            if gauge == nil {
                gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: tab);
                gaugeContainer.addSubview(gauge);
            } else {
                gauge.setData(delegate, tab: tab);
            }
        }
        addPanelTriangle();
        
        switchCopyImage(tab);
    }

    func addPanelTriangle() {
        if triangleIndicator == nil {
            triangleIndicator = TriangleView(frame: CGRect(x: screenWidth - thirdPanel.frame.size.width / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight));
            triangleIndicator.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI));
            addSubview(triangleIndicator);
        }
    }
    
    func setPanelHeaders(isOpen: Bool) {
        secondPanelValue.hidden = isOpen;
        secondPanelUnit.hidden = isOpen;
        secondPanelLabel.hidden = isOpen;
        thirdPanelValue.hidden = isOpen;
        thirdPanelUnit.hidden = isOpen;
        thirdPanelLabel.hidden = isOpen;
        
        secondPanelHeader.hidden = !isOpen;
        thirdPanelHeader.hidden = !isOpen;
        
        if secondPanelExtraLabel != nil {
            secondPanelExtraLabel.hidden = !shouldShowCenteredSecondPanel || isOpen;
        }
        
        if thirdPanelExtraLabel != nil {
            thirdPanelExtraLabel.hidden = !shouldShowCenteredThirdPanel || isOpen;
        }
    }
    
    func initMeterView() -> PointsMeter {
        let meterWidth = meterContainer.frame.size.width - 50;
        let meterHeight = meterContainer.frame.size.height - 50;
        let meter = PointsMeter.create(CGRect(x: (meterContainer.frame.size.width - meterWidth) / 2, y: 0, width: meterWidth, height: meterHeight), thickArc: true);
        meter.setLightArc();
        meterContainer.addSubview(meter);
        meter.setDarkText();
        let tap = UITapGestureRecognizer(target: self, action: "gotoDailySummary:");
        meter.addGestureRecognizer(tap);
        return meter;
    }
    
    func initCenteredLabel(frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame);
        label.backgroundColor = UIColor.whiteColor();
        label.textAlignment = NSTextAlignment.Center;
        label.textColor = delegate.getColor();
        return label;
    }
    
    func initSummaryview(date: String?) {
        var activities: [HigiActivity] = [];
        var activityKeys: [String] = [];
        var activitiesByType:[String: (Int, [HigiActivity])] = [:];
        var currentOrigin:CGFloat = scrollViewPadding;
        var dateString = date;
        if (dateString == nil) {
            dateString = Constants.dateFormatter.stringFromDate(NSDate());
        }
        if let (_, sessionActivities) = SessionController.Instance.activities[dateString!] {
            activities = sessionActivities;
            activities.sortInPlace(SummaryViewUtility.sortByPoints);
        }

        var activitiesByDevice: [String: Int] = [:];
        for activity in activities {
            let type = activity.type.getString();
            if let (total, activityList) = activitiesByType[type] {
                if let devicePoints = activitiesByDevice[String(activity.device.name)] {
                    var previousActivities = activityList;
                    previousActivities.append(activity);
                    var points = total;
                    var newDevicePoints = devicePoints;
                    if (activity.points > 0 && activity.errorDescription == nil) {
                        points += activity.points!;
                        newDevicePoints += activity.points!;
                    }
                    activitiesByType[type] = (points, previousActivities);
                    activitiesByDevice[String(activity.device.name)] = newDevicePoints;
                } else {
                    var previousActivities = activityList;
                    previousActivities.append(activity);
                    var points = total;
                    if (activity.points > 0 && activity.errorDescription == nil) {
                        points += activity.points!;
                    }
                    activitiesByType[type] = (points, previousActivities);
                    activitiesByDevice[String(activity.device.name)] = activity.points!;
                }
            } else {
                var points = 0;
                if (activity.points > 0 && activity.errorDescription == nil) {
                    points += activity.points!;
                }
                activitiesByType[type] = (points, [activity]);
                activityKeys.append(type);
                activitiesByDevice[String(activity.device.name)] = points;
            }
        }
        
        let gap = CGFloat(4);
        for key in activityKeys {
            let (total, activityList) = activitiesByType[key]!;
            let category = ActivityCategory.categoryFromString(key);
            let color = category.getColor();
            let activityRow = SummaryViewUtility.initTitleRow(0, originY: 0, width: copyScrollview.frame.size.width, points: total, device: String(category.getString()), color: color);
            activityRow.device.font = UIFont.boldSystemFontOfSize(20);
            activityRow.points.font = UIFont.boldSystemFontOfSize(20);
            activityRow.device.textColor = color;
            activityRowHeight = activityRow.frame.size.height;
            let wrapperView = UIView(frame: CGRect(x: 0, y: currentOrigin, width: copyScrollview.frame.size.width, height: activityRow.frame.size.height));
            wrapperView.addSubview(activityRow);
            copyScrollview.addSubview(wrapperView);
            activityRows.append(activityRow);
            currentOrigin += activityRow.frame.size.height;
            var seenDevices: [String: Bool] = [:];
            for subActivity in activityList {
                let deviceName = String(subActivity.device.name);
                if (subActivity.points > 0 || (key != ActivityCategory.Health.getString() && subActivity.errorDescription == nil)) {
                    if seenDevices[deviceName] == nil {
                        let titleRow = SummaryViewUtility.initTitleRow(activityRow.frame.origin.x, originY: currentOrigin, width: copyScrollview.frame.size.width - activityRow.frame.origin.x, points: activitiesByDevice[String(subActivity.device.name)]!, device: "\(subActivity.device.name)", color: Utility.colorFromHexString("#444444"));
                        titleRow.device.font = UIFont.systemFontOfSize(16);
                        titleRow.points.font = UIFont.systemFontOfSize(16);
                        copyScrollview.addSubview(titleRow);
                        activityRows.append(titleRow);
                        currentOrigin += titleRow.frame.size.height;
                        seenDevices[deviceName] = true;
                    }
                }
            }
            currentOrigin += gap;
        }
        currentOrigin += gap * 2;
        copyImageOrigin = currentOrigin;
        copyScrollViewHeight = copyScrollview.frame.origin.y + currentOrigin;
    }

    func gotoDailySummary(sender: AnyObject) {
        Flurry.logEvent("Summary_Pressed");
        (Utility.getViewController(self) as! MetricsViewController).selectedType = MetricsType.DailySummary;
        let summaryController = DailySummaryViewController(nibName: "DailySummaryView", bundle: nil);
        let dateString = delegate.getSelectedPoint()!.date;
        summaryController.dateString = dateString;
        Utility.getViewController(self)!.navigationController!.pushViewController(summaryController, animated: true);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        for row in activityRows {
            row.frame.size.width = copyScrollview.frame.size.width;
            row.frame.size.height = activityRowHeight;
        }
    }
}