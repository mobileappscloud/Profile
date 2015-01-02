//
//  ActivityViewController.swift
//  higi
//
//  Created by Dan Harms on 10/27/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ActivityViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var meterContainer: UIView!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var legendButton: UIImageView!
    
    var activitiesByDay: [[HigiActivity]] = [];
    
    let dateFormatter = NSDateFormatter();
    
    var legendIsOpen = false;
    
    var dayBuckets, weekBuckets, monthBuckets: [String: [Int]]!;
    
    var dayGraph, weekGraph, monthGraph: ActivityGraphHostingView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Activity";
        dateFormatter.dateFormat = "MM/dd/yyyy";
        populateActivities();
        createGraphs();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        drawArc();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesByDay[section].count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activitiesByDay.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ActivityCell") as ActivityCell!;
        if (cell == nil) {
            cell = UINib(nibName: "ActivityCellView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ActivityCell;
        }
        cell.separatorInset = UIEdgeInsetsZero;
        if (UIDevice.currentDevice().systemVersion >= "8.0") {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        var activity = activitiesByDay[indexPath.section][indexPath.item];
        cell.title.text = activity.device.name;
        cell.activity.text = activity.description;
        cell.points.text = "\(activity.points)";
        cell.coloredPoint.backgroundColor = Utility.colorFromHexString(activity.device.colorCode);
        cell.icon.image = nil;
        cell.icon.setImageWithURL(NSURL(string: activity.device.iconUrl)!);
        if (activity.errorDescription != nil) {
            cell.error.hidden = false;
            cell.error.text = activity.errorDescription;
            cell.contentView.alpha = 0.3;
        } else {
            cell.error.hidden = true;
            cell.contentView.alpha = 1.0;
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = UINib(nibName: "ActivityCellHeaderView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ActivityCellHeader;
        header.date.text = dateFormatter.stringFromDate(activitiesByDay[section][0].startTime);
        var total = 0;
        for activity in activitiesByDay[section] {
            total += activity.points;
        }
        header.total.text = "\(total)";
        return header;
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    @IBAction func graphButtonAction(sender: AnyObject) {
        dayButton.enabled = false;
        weekButton.enabled = false;
        monthButton.enabled = false;
        dayButton.titleLabel!.font = UIFont.systemFontOfSize(15);
        dayButton.setTitleColor(Utility.colorFromHexString("#AAAAAA"), forState: UIControlState.Normal)
        weekButton.titleLabel!.font = UIFont.systemFontOfSize(15);
        weekButton.setTitleColor(Utility.colorFromHexString("#AAAAAA"), forState: UIControlState.Normal)
        monthButton.titleLabel!.font = UIFont.systemFontOfSize(15);
        monthButton.setTitleColor(Utility.colorFromHexString("#AAAAAA"), forState: UIControlState.Normal)
        (sender as UIButton).titleLabel!.font = UIFont.boldSystemFontOfSize(15);
        (sender as UIButton).setTitleColor(Utility.colorFromHexString("#444444"), forState: UIControlState.Normal)
        dayButton.enabled = true;
        weekButton.enabled = true;
        monthButton.enabled = true;
        dayGraph.hidden = true;
        weekGraph.hidden = true;
        monthGraph.hidden = true;
        if (sender as UIButton == weekButton) {
            weekGraph.hidden = false;
        } else if (sender as UIButton == monthButton) {
            monthGraph.hidden = false;
        } else {
            dayGraph.hidden = false;
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavbar();
    }
    
    func updateNavbar() {
        var scrollY = tableView.contentOffset.y;
        if (scrollY >= 0) {
            headerImage.frame.origin.y = -scrollY / 2;
            var alpha = min(scrollY / 75, 1);
            self.fakeNavBar.alpha = alpha;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0 - alpha, alpha: 1.0)];
            if (alpha < 0.5) {
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
                toggleButton!.alpha = 1 - alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
            } else {
                toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon_inverted"), forState: UIControlState.Normal);
                toggleButton!.alpha = alpha;
                self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
            }
        } else {
            self.fakeNavBar.alpha = 0;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 1)];
        }
    }
    
    func populateActivities() {
        var savedDate = "";
        var currentSection = -1;
        var activities = SessionController.Instance.activities.reverse();
        dayBuckets = [:];
        weekBuckets = [:];
        monthBuckets = [:];
        for activity in activities {
            var dateString = dateFormatter.stringFromDate(activity.startTime);
            if (savedDate != dateString) {
                currentSection++;
                activitiesByDay.append([]);
                savedDate = dateString;
            }
            activitiesByDay[currentSection].append(activity);
            if (activity.errorDescription == nil) {
                addToBuckets(activity);
            }
        }
    }
    
    func addToBuckets(activity: HigiActivity) {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!;
        let today = dateFormatter.dateFromString(dateFormatter.stringFromDate(NSDate()))!;
        let activityDate = dateFormatter.dateFromString(dateFormatter.stringFromDate(activity.startTime))!;
        var dayComponents = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: activityDate, toDate: today, options: NSCalendarOptions.allZeros);
        var weekOffset = calendar.component(NSCalendarUnit.WeekOfYearCalendarUnit, fromDate: today) - calendar.component(NSCalendarUnit.WeekOfYearCalendarUnit, fromDate: activityDate);
        var monthOffset = calendar.component(NSCalendarUnit.MonthCalendarUnit, fromDate: today) - calendar.component(NSCalendarUnit.MonthCalendarUnit, fromDate: activityDate);
        
        let deviceName = activity.device.name;
        
        if (dayComponents.day < 7) {
            var dayArray = dayBuckets[deviceName];
            if (dayArray == nil) {
                dayArray = [0, 0, 0, 0, 0, 0, 0];
            }
            dayArray![6 - dayComponents.day] += activity.points;
            dayBuckets[deviceName] = dayArray;
        }
        
        if (weekOffset < 0) {
            weekOffset += 52;
        }
        if (weekOffset < 7) {
            var weekArray = weekBuckets[deviceName];
            if (weekArray == nil) {
                weekArray = [0, 0, 0, 0, 0, 0, 0];
            }
            weekArray![6 - weekOffset] += activity.points;
            weekBuckets[deviceName] = weekArray;
        }
        
        if (monthOffset < 0) {
            monthOffset += 12;
        }
        if (monthOffset < 7) {
            var monthArray = monthBuckets[deviceName];
            if (monthArray == nil) {
                monthArray = [0, 0, 0, 0, 0, 0, 0];
            }
            monthArray![ 6 - monthOffset] += activity.points;
            monthBuckets[deviceName] = monthArray;
        }
    }
    
    func createGraphs() {
        dayGraph = ActivityGraphHostingView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: graphContainer.frame.size), points: dayBuckets);
        weekGraph = ActivityGraphHostingView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: graphContainer.frame.size), points: weekBuckets);
        monthGraph = ActivityGraphHostingView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: graphContainer.frame.size), points: monthBuckets);
//        weekGraph.hidden = true;
//        monthGraph.hidden = true;
        
        dayGraph.setupGraph(ActivityGraphHostingView.Mode.DAY);
        weekGraph.setupGraph(ActivityGraphHostingView.Mode.WEEK);
        monthGraph.setupGraph(ActivityGraphHostingView.Mode.MONTH);
        
        graphContainer.addSubview(dayGraph);
        graphContainer.addSubview(weekGraph);
        graphContainer.addSubview(monthGraph);
    }
    
    func drawArc() {
        var total = 0;
        var center = CGPoint(x: 50.0, y: 50.0);
        var radius: CGFloat = 44.0;
        if (activitiesByDay.count > 0 && dateFormatter.stringFromDate(activitiesByDay[0][0].startTime) == dateFormatter.stringFromDate(NSDate())) {
            var lastEnd = 0.0;
            for activity in activitiesByDay[0] {
                total += activity.points;
            }
            
            for activity in activitiesByDay[0] {
                var toPath = UIBezierPath();
                var arc = CAShapeLayer();
                arc.lineWidth = 12;
                arc.fillColor = UIColor.clearColor().CGColor;
                arc.strokeColor = Utility.colorFromHexString(activity.device.colorCode).CGColor;
                
                var increment = Double(activity.points) / Double(total);
                var startingPoint = CGPoint(x: center.x + radius * CGFloat(cos(lastEnd * 2 * M_PI)), y: center.y + radius * CGFloat(sin(lastEnd * 2 * M_PI)));
                toPath.moveToPoint(startingPoint);
                var startAngle = lastEnd * 2 * M_PI;
                toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(startAngle + 2 * M_PI), clockwise: true);
                toPath.closePath();
                
                arc.path = toPath.CGPath;
                meterContainer.layer.addSublayer(arc);
                
                CATransaction.begin();
                CATransaction.setDisableActions(true);
                arc.strokeStart = CGFloat(0);
                arc.strokeEnd = CGFloat(0);
                CATransaction.setDisableActions(false);
                CATransaction.commit();
                dispatch_async(dispatch_get_main_queue(), {
                    CATransaction.begin();
                    CATransaction.setAnimationDuration(1.0);
                    arc.strokeEnd = CGFloat(increment + 0.01);
                    CATransaction.commit();
                });
                lastEnd += increment;
            }
        } else {
            var arc = CAShapeLayer();
            arc.lineWidth = 12;
            arc.fillColor = UIColor.whiteColor().CGColor;
            arc.strokeColor = Utility.colorFromHexString("#DDDDDD").CGColor;
            var toPath = UIBezierPath();
            var startingPoint = CGPoint(x: center.x, y: center.y + radius);
            toPath.moveToPoint(startingPoint);
            toPath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(5 * M_PI_2), clockwise: true);
            toPath.closePath();
            
            arc.path = toPath.CGPath;
            meterContainer.layer.addSublayer(arc);
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            arc.strokeStart = 0.0;
            arc.strokeEnd = 1.0;
            CATransaction.setDisableActions(false);
            CATransaction.commit();
        }
        
        self.points.text = "\(total)";
    }
    
    @IBAction func legendButtonTapped(sender: AnyObject) {
        if (legendIsOpen) {
            legendButton.image = UIImage(named: "oc_dropdownmenu_down");
        } else {
            legendButton.image = UIImage(named: "oc_dropdownmenu_up");
        }
        legendIsOpen = !legendIsOpen;
    }
    
    
}