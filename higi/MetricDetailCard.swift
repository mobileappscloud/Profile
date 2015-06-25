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
    @IBOutlet weak var copyImage: UIImageView!
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
    
    class func instanceFromNib(card: MetricCard) -> MetricDetailCard {
        var view = UINib(nibName: "MetricDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricDetailCard;
        if (card.getSelectedPoint() != nil) {
            view.setData(card.getSelectedPoint()!);
            view.setup(card.delegate);
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
            meter = PointsMeter.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height));
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
        } else if (delegate.getRanges(tab).count > 0) {
            if (meter != nil && meter.superview != nil) {
                meter.removeFromSuperview();
            }
            gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: tab);
            gaugeContainer.addSubview(gauge);
        }
        triangleIndicator = TriangleView(frame: CGRect(x: thirdPanel.frame.origin.x + thirdPanel.frame.size.width / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight));
        triangleIndicator.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI));
        addSubview(triangleIndicator);
        
        if (delegate.getType() == MetricsType.BloodPressure || delegate.getType() == MetricsType.Weight) {
            let secondPanelTap = UITapGestureRecognizer(target: self, action: "secondPanelClicked:");
            secondPanel.addGestureRecognizer(secondPanelTap);
            let thirdPanelTap = UITapGestureRecognizer(target: self, action: "thirdPanelClicked:");
            thirdPanel.addGestureRecognizer(thirdPanelTap);
        }
        
        if (delegate.getCopyImage() != nil) {
            copyScrollview.contentSize.height = copyScrollViewHeight + copyImage.frame.size.height;
            copyImage.image = delegate.getCopyImage();
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
            triangleIndicator.frame = CGRect(x: secondPanel.frame.origin.x + secondPanel.frame.size.width / 2 - triangleHeight / 2, y: secondPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
            if (gauge.superview != nil) {
                let tab = 0;
                gauge.removeFromSuperview();
                gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: tab);
                gaugeContainer.addSubview(gauge);
            }
        }
        thirdPanelSelected = false;
    }
    
    func thirdPanelClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).openDetailsIfClosed();
        if (!thirdPanelSelected) {
            triangleIndicator.frame = CGRect(x: thirdPanel.frame.origin.x + thirdPanel.frame.size.width / 2 - triangleHeight / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
            if (gauge.superview != nil) {
                let value = thirdPanelValue.text?.toInt() != nil ? thirdPanelValue.text!.toInt()! : 0;
                gauge.removeFromSuperview();
                let tab = 1;
                gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: 1);
                gaugeContainer.addSubview(gauge);
            }
        }
        thirdPanelSelected = true;
    }
    
    func setData(selection: MetricCard.SelectedPoint) {
        firstPanelValue.text = selection.date;
        secondPanelValue.text = selection.firstPanel.value;
        secondPanelUnit.text = selection.firstPanel.unit;
        secondPanelLabel.text = selection.firstPanel.label;
        thirdPanelValue.text = selection.secondPanel.value;
        thirdPanelUnit.text = selection.secondPanel.unit;
        thirdPanelLabel.text = selection.secondPanel.label;
        
        secondPanelHeader.text = selection.firstPanel.label;
        thirdPanelHeader.text = selection.secondPanel.label;
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
            let activityRow = UILabel(frame: CGRect(x: 0, y: currentOrigin, width: copyScrollview.frame.size.width, height: 20));
            activityRow.text = String(category.getString());
            activityRow.textColor = color;
            copyScrollview.addSubview(activityRow);
            currentOrigin += activityRow.frame.size.height - 4;
            let titleMargin:CGFloat = 2;
            for subActivity in activityList {
                let name = subActivity.device.name == "higi" ? "higi Station Check In" : "\(subActivity.device.name)";
                let titleRow = SummaryViewUtility.initTitleRow(activityRow.frame.origin.x, originY: currentOrigin, width: copyScrollview.frame.size.width - activityRow.frame.origin.x, points: subActivity.points, device: name, color: color);
                copyScrollview.addSubview(titleRow);
                currentOrigin += titleRow.frame.size.height + titleMargin;
                var isDuplicate = subActivity.errorDescription != nil;
                if (key == ActivityCategory.Lifestyle.getString()) {
                    let breakdownRow = SummaryViewUtility.initBreakdownRow(activityRow.frame.origin.x, originY: currentOrigin, text: "Gym \(subActivity.typeName)", duplicate: isDuplicate);
                    copyScrollview.addSubview(breakdownRow);
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
                        let breakdownRow = SummaryViewUtility.initBreakdownRow(activityRow.frame.origin.x, originY: currentOrigin, text: "\(lastSystolic)/\(lastDiastolic) mmHg BP", duplicate: isDuplicate);
                        copyScrollview.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height;
                    }
                    if (lastPulse > 0) {
                        let breakdownRow = SummaryViewUtility.initBreakdownRow(activityRow.frame.origin.x, originY: currentOrigin, text: "\(lastPulse) bpm Pulse", duplicate: isDuplicate);
                        copyScrollview.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height;
                    }
                    if (lastWeight > 0) {
                        let breakdownRow = SummaryViewUtility.initBreakdownRow(activityRow.frame.origin.x, originY: currentOrigin, text: "\(Int(lastWeight)) lbs Weight", duplicate: isDuplicate);
                        copyScrollview.addSubview(breakdownRow);
                        currentOrigin += breakdownRow.frame.size.height;
                    }
                    if (lastBodyFat > 0) {
                        let breakdownRow = SummaryViewUtility.initBreakdownRow(activityRow.frame.origin.x, originY: currentOrigin, text: "\(lastBodyFat)% Body Fat", duplicate: isDuplicate);
                        copyScrollview.addSubview(breakdownRow);
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
                    let breakdownRow = SummaryViewUtility.initBreakdownRow(activityRow.frame.origin.x, originY: currentOrigin, text: text, duplicate: isDuplicate);
                    copyScrollview.addSubview(breakdownRow);
                    currentOrigin += breakdownRow.frame.size.height;
                }
                if (isDuplicate) {
                    let duplicateLabel = SummaryViewUtility.initDuplicateLabel(activityRow.frame.origin.x, originY: currentOrigin, width: copyScrollview.frame.size.width - activityRow.frame.origin.x, text: "\(subActivity.errorDescription)");
                    copyScrollview.addSubview(duplicateLabel);
                    currentOrigin += duplicateLabel.frame.size.height;
                }
                currentOrigin += gap;
            }
        }
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