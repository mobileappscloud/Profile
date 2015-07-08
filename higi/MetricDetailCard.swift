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
    @IBOutlet weak var copyScrollview: UIScrollView!
    @IBOutlet weak var gaugeContainer: UIView!
    @IBOutlet weak var secondPanelHeader: UILabel!
    @IBOutlet weak var thirdPanelHeader: UILabel!

    var delegate: MetricDelegate!;
    
    var triangleIndicator: TriangleView!;
    
    var gauge: MetricGauge!;
    
    var meter: PointsMeter!;
    
    let triangleHeight:CGFloat = 20;
    
    var copyImageOrigin:CGFloat = 0, copyScrollViewHeight: CGFloat = 0;
    
    var thirdPanelSelected = true;
    
    var blankState = false;
    
    var selected:MetricCard.SelectedPoint!;
    
    var copyImage: UIImageView!
    
    class func instanceFromNib(card: MetricCard) -> MetricDetailCard {
        var view = UINib(nibName: "MetricDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricDetailCard;
        if (card.getSelectedPoint() != nil) {
            view.setup(card.delegate);
            view.setData(card.getSelectedPoint()!);
        } else {
            view.blankState = true;
        }
        return view;
    }

    func setup(delegate: MetricDelegate) {
        self.delegate = delegate;
        let color = delegate.getColor();
        firstPanelValue.textColor = color;
        secondPanelValue.textColor = color;
        thirdPanelValue.textColor = color;
        
        let tab = thirdPanelSelected ? 1 : 0;
        var value: Int;
        if (delegate.getType() == MetricsType.DailySummary) {
            if (gauge != nil && gauge.superview != nil) {
                gauge.removeFromSuperview();
            }
            meter = PointsMeter.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width - 50, height: gaugeContainer.frame.size.height - 50), thickArc: true);
            meter.setLightArc();
            let dateString = Constants.dateFormatter.stringFromDate(Constants.displayDateFormatter.dateFromString(delegate.getSelectedPoint()!.date)!);
            if (SessionController.Instance.activities[dateString] != nil) {
                meter.setActivities(SessionController.Instance.activities[dateString]!);
            } else {
                meter.setActivities((0, []));
            }
            gaugeContainer.addSubview(meter);
            meter.drawArc(false);
            meter.setDarkText();
            let tap = UITapGestureRecognizer(target: self, action: "gotoDailySummary:");
            meter.addGestureRecognizer(tap);
            
            initSummaryview(dateString);
        } else {
            if (meter != nil && meter.superview != nil) {
                meter.removeFromSuperview();
            }
            gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: tab);
            gaugeContainer.addSubview(gauge);
        }
        triangleIndicator = TriangleView(frame: CGRect(x: thirdPanel.frame.origin.x + thirdPanel.frame.size.width / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight));
        triangleIndicator.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI));
        addSubview(triangleIndicator);
        
        if (delegate.getType() == MetricsType.BloodPressure || (delegate.getType() == MetricsType.Weight && !(delegate as! WeightMetricDelegate).weightMode)) {
            let secondPanelTap = UITapGestureRecognizer(target: self, action: "secondPanelClicked:");
            secondPanel.addGestureRecognizer(secondPanelTap);
            let thirdPanelTap = UITapGestureRecognizer(target: self, action: "thirdPanelClicked:");
            thirdPanel.addGestureRecognizer(thirdPanelTap);
        }
        updateCopyImage(tab);
    }
    
    func updateCopyImage(tab: Int) {
        if let image = delegate.getCopyImage(tab) {
            let height = image.size.height;
            let width = image.size.width;
            let newHeight = (height / width) * copyScrollview.frame.size.width;
            if copyImage != nil && copyImage.superview != nil {
                copyImage.removeFromSuperview();
            }
            copyImage = UIImageView(frame: CGRect(x: 0, y: copyImageOrigin, width: copyScrollview.frame.size.width, height: newHeight));
            copyImage.image = Utility.scaleImage(image, newSize: CGSize(width: copyScrollview.frame.size.width, height: newHeight));
            copyScrollview.contentSize.height = copyScrollViewHeight + copyImage.frame.size.height + copyImage.frame.origin.y;
            copyScrollview.addSubview(copyImage);
        } else {
            copyScrollview.contentSize.height = copyScrollViewHeight;
        }
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
    
    func secondPanelClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).openDetailsIfClosed();
        if (thirdPanelSelected) {
            let tab = 0;
            triangleIndicator.frame = CGRect(x: secondPanel.frame.origin.x + secondPanel.frame.size.width / 2 - triangleHeight / 2, y: secondPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
            if (gauge.superview != nil) {
                gauge.removeFromSuperview();
                gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: tab);
                gaugeContainer.addSubview(gauge);
            }
            updateCopyImage(tab);
        }
        thirdPanelSelected = false;
    }
    
    func thirdPanelClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).openDetailsIfClosed();
        if (!thirdPanelSelected) {
            let tab = 1;
            triangleIndicator.frame = CGRect(x: thirdPanel.frame.origin.x + thirdPanel.frame.size.width / 2 - triangleHeight / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
            if (gauge.superview != nil) {
                gauge.removeFromSuperview();
                gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: 1);
                gaugeContainer.addSubview(gauge);
            }
            updateCopyImage(tab);
        }
        thirdPanelSelected = true;
    }
    
    func setData(selection: MetricCard.SelectedPoint) {
        selected = selection;
        firstPanelValue.text = selection.date;
        secondPanelUnit.text = selection.firstPanel.unit;
        secondPanelLabel.text = selection.firstPanel.label;
        thirdPanelUnit.text = selection.secondPanel.unit;
        thirdPanelLabel.text = selection.secondPanel.label;
        
        secondPanelHeader.text = selection.firstPanel.label;
        thirdPanelHeader.text = selection.secondPanel.label;
        
        if selected.firstPanel.unit == "" && selection.firstPanel.value != "" {
            let label = UILabel(frame: CGRect(x: secondPanelValue.frame.origin.x, y: secondPanelValue.frame.origin.y, width: secondPanelValue.frame.size.width - (2 * secondPanelValue.frame.origin.x), height: secondPanelValue.frame.size.height));
            label.text = selection.firstPanel.value;
            label.textAlignment = NSTextAlignment.Center;
            label.textColor = delegate.getColor();
            secondPanel.addSubview(label);
            secondPanel.sendSubviewToBack(label);
            secondPanelValue.hidden = true;
        } else {
            secondPanelValue.text = selection.firstPanel.value;
        }
        if selected.secondPanel.unit == "" && selection.secondPanel.value != "" {
            let label = UILabel(frame: CGRect(x: thirdPanelValue.frame.origin.x, y: thirdPanelValue.frame.origin.y, width: thirdPanel.frame.size.width - (2 * thirdPanelValue.frame.origin.x), height: thirdPanelValue.frame.size.height));
            label.text = selection.secondPanel.value;
            label.textAlignment = NSTextAlignment.Center;
            label.textColor = delegate.getColor();
            thirdPanel.addSubview(label);
            thirdPanel.sendSubviewToBack(label);
            thirdPanelValue.hidden = true;
        } else {
            thirdPanelValue.text = selection.secondPanel.value;
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
    }
    
    func initSummaryview(date: String?) {
        var activities: [HigiActivity] = [];
        var activityKeys: [String] = [];
        var activitiesByType:[String: (Int, [HigiActivity])] = [:];
        var totalPoints = 0;
        var minCircleRadius:CGFloat = 6, maxCircleRadius:CGFloat = 32, currentOrigin:CGFloat = 0;
        var dateString = date;
        if (dateString == nil) {
            dateString = Constants.dateFormatter.stringFromDate(NSDate());
        }
        if let (points, sessionActivities) = SessionController.Instance.activities[dateString!] {
            totalPoints = points;
            activities = sessionActivities;
            activities.sort(SummaryViewUtility.sortByPoints);
        }
        for activity in activities {
            var type = ActivityCategory.categoryFromActivity(activity).getString();
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
            let activityRow = SummaryViewUtility.initTitleRow(0, originY: currentOrigin, width: copyScrollview.frame.size.width, points: activity.points, device: String(category.getString()), color: color);
            activityRow.device.font = UIFont.boldSystemFontOfSize(20);
            activityRow.points.font = UIFont.boldSystemFontOfSize(20);
            activityRow.device.textColor = color;
            copyScrollview.addSubview(activityRow);
            currentOrigin += activityRow.frame.size.height;
            var todaysCheckins:[HigiCheckin] = [];
            for checkin in SessionController.Instance.checkins {
                if (Constants.dateFormatter.stringFromDate(checkin.dateTime) == dateString) {
                    todaysCheckins.append(checkin);
                }
            }
            var checkinIndex = 0;
            for subActivity in activityList {
                if (subActivity.errorDescription == nil && subActivity.points > 0) {
                    let titleRow = SummaryViewUtility.initTitleRow(activityRow.frame.origin.x, originY: currentOrigin, width: copyScrollview.frame.size.width - activityRow.frame.origin.x, points: subActivity.points, device: "\(subActivity.device.name)", color: Utility.colorFromHexString("#444444"));
                    titleRow.device.font = UIFont.systemFontOfSize(16);
                    titleRow.points.font = UIFont.systemFontOfSize(16);
                    copyScrollview.addSubview(titleRow);
                    currentOrigin += titleRow.frame.size.height;
                }
            }
            currentOrigin += gap;
        }
        copyImageOrigin = currentOrigin;
        copyScrollViewHeight = copyScrollview.frame.origin.y + currentOrigin + 40;
    }

    func gotoDailySummary(sender: AnyObject) {
        Flurry.logEvent("Summary_Pressed");
        (Utility.getViewController(self) as! MetricsViewController).selectedType = MetricsType.DailySummary;
        var summaryController = DailySummaryViewController(nibName: "DailySummaryView", bundle: nil);
        let dateString = Constants.dateFormatter.stringFromDate(Constants.displayDateFormatter.dateFromString(delegate.getSelectedPoint()!.date)!);
        summaryController.dateString = dateString;
        Utility.getViewController(self)!.navigationController!.pushViewController(summaryController, animated: true);
    }
}