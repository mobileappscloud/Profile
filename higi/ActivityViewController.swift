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
    @IBOutlet weak var legendButton: UIImageView!
    @IBOutlet weak var pointsMeterContainer: UIView!
    @IBOutlet weak var noPoints: UIImageView!
    
    @IBOutlet weak var errorState: UIView!
    @IBOutlet weak var noActivityEverView: UIView!

    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var activityContainer: UIView!
    var pointsMeter: PointsMeter!;
    
    var activitiesByDay: [[HigiActivity]] = [], todaysActivities: [HigiActivity] = [];
    
    let dateFormatter = NSDateFormatter();
    
    var legendIsOpen = false;
    
    var dayBuckets, weekBuckets, monthBuckets: [String: [Int]]!;
    
    var dayGraph, weekGraph, monthGraph: ActivityGraphHostingView!;

    var meterContainerHeight:CGFloat!;
    var activityContainerOriginY:CGFloat!;
    var headerContainerHeight:CGFloat!;
    var legendButtonOriginY:CGFloat!;
    var legendSize:CGFloat!;
    
    var legendRowHeight:CGFloat = 25;
    var legendDeviceRows:[ActivityLegend] = [];
    
    var legendView:UIView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Activity";
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        
        dateFormatter.dateFormat = "MM/dd/yyyy";
        pointsMeter = UINib(nibName: "PointsMeterView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as PointsMeter;
        pointsMeterContainer.addSubview(pointsMeter);
        populateActivities();
        if (todaysActivities.count > 0) {
            pointsMeter.activities = todaysActivities;
        } else {
            pointsMeter.hidden = true;
            noPoints.hidden = false;
            legendButton.hidden = true;
        }
        tableView.rowHeight = 63;
        createGraphs();
        
        meterContainerHeight = meterContainer.frame.size.height;
        activityContainerOriginY = activityContainer.frame.origin.y;
        headerContainerHeight = headerContainer.frame.size.height;
        legendButtonOriginY = legendButton.frame.origin.y;
        
        addLegendDevices();
        if (legendDeviceRows.count == 0) {
            legendButton.hidden = true;
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        pointsMeter.drawArc();
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
            Flurry.logEvent("ActivityWeekGraph_Pressed");
            weekGraph.hidden = false;
        } else if (sender as UIButton == monthButton) {
            Flurry.logEvent("ActivityMonthGraph_Pressed");
            monthGraph.hidden = false;
        } else {
            Flurry.logEvent("ActivityDayGraph_Pressed");
            dayGraph.hidden = false;
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateNavbar();
    }
    
    func updateNavbar() {
        var scrollY = tableView.contentOffset.y;
        if (scrollY >= 0) {
            headerImage.frame.origin.y = -scrollY / 1.5;
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
            headerImage.frame.origin.y = 0;
            self.fakeNavBar.alpha = 0;
            toggleButton!.setBackgroundImage(UIImage(named: "nav_ocmicon"), forState: UIControlState.Normal);
            toggleButton!.alpha = 1;
            self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 1)];
            self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        }
    }
    
    func populateActivities() {
        var savedDate = "";
        var currentSection = -1;
        var activities = SessionController.Instance.activities;
        dayBuckets = [:];
        weekBuckets = [:];
        monthBuckets = [:];
        todaysActivities = [];
        activitiesByDay = [];
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
        
        var blankSeries = ["higi": [0, 0, 0, 0, 0, 0, 0]];
       
        if (dayBuckets.count == 0) {
            dayBuckets = blankSeries;
        }
        
        if (weekBuckets.count == 0) {
            weekBuckets = blankSeries;
        }
        
        if (monthBuckets.count == 0) {
            monthBuckets = blankSeries;
        }
    }
    
    func addToBuckets(activity: HigiActivity) {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!;
        let today = dateFormatter.dateFromString(dateFormatter.stringFromDate(NSDate()))!;
        let activityDate = dateFormatter.dateFromString(dateFormatter.stringFromDate(activity.startTime))!;
        var dayComponents = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: activityDate, toDate: today, options: NSCalendarOptions.allZeros);
        var weekOffset = calendar.components(NSCalendarUnit.WeekOfYearCalendarUnit, fromDate: today).weekOfYear - calendar.components(NSCalendarUnit.WeekOfYearCalendarUnit, fromDate: activityDate).weekOfYear;
        var monthOffset = calendar.components(NSCalendarUnit.MonthCalendarUnit, fromDate: today).month - calendar.components(NSCalendarUnit.MonthCalendarUnit, fromDate: activityDate).month;
        
        let deviceName = activity.device.name;
        
        if (dayComponents.day < 7) {
            var dayArray = dayBuckets[deviceName];
            if (dayArray == nil) {
                dayArray = [0, 0, 0, 0, 0, 0, 0];
            }
            dayArray![6 - dayComponents.day] += activity.points;
            dayBuckets[deviceName] = dayArray;
            if (dayComponents.day == 0) {
                todaysActivities.append(activity);
                legendDeviceRows.append(ActivityLegend.instanceFromNib(activity.device, points: activity.points));
            }
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
        
        if (SessionController.Instance.activities.count > 0) {
            dayGraph = ActivityGraphHostingView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: graphContainer.frame.size), points: dayBuckets);
            weekGraph = ActivityGraphHostingView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: graphContainer.frame.size), points: weekBuckets);
            monthGraph = ActivityGraphHostingView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: graphContainer.frame.size), points: monthBuckets);
            
            weekGraph.hidden = true;
            monthGraph.hidden = true;
            
            dayGraph.setupGraph(ActivityGraphHostingView.Mode.DAY);
            weekGraph.setupGraph(ActivityGraphHostingView.Mode.WEEK);
            monthGraph.setupGraph(ActivityGraphHostingView.Mode.MONTH);

            graphContainer.addSubview(dayGraph);
            graphContainer.addSubview(weekGraph);
            graphContainer.addSubview(monthGraph);
        } else {
            tableView.hidden = true;
            if (SessionController.Instance.earnditError) {
                errorState.hidden = false;
            } else {
                noActivityEverView.hidden = false;
            }
        }
    }
    
    func addLegendDevices() {
        legendView = UIView(frame: CGRect(x: 0, y: legendButtonOriginY, width: legendButton.frame.size.width, height: (legendRowHeight) * CGFloat(legendDeviceRows.count)));
        var yPos:CGFloat = 2;
        for row in legendDeviceRows {
            row.frame.origin.y = yPos;
            yPos += legendRowHeight + 2;
            legendView.addSubview(row);
        }
        legendView.hidden = true;
        meterContainer.addSubview(legendView);
        
        meterContainer.bringSubviewToFront(legendButton);
    }
    
    @IBAction func connectDevices(sender: AnyObject) {
        Flurry.logEvent("ConnectDevice_Pressed");
        self.navigationController!.pushViewController(ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil), animated: true);
    }
    
    @IBAction func legendButtonTapped(sender: AnyObject) {
        let animationDuration = 0.25;
        
        if (legendIsOpen) {
            legendButton.image = UIImage(named: "oc_dropdownmenu_down");
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.meterContainer.frame.size.height = self.meterContainerHeight;
                self.activityContainer.frame.origin.y = self.activityContainerOriginY;
                self.headerContainer.frame.size.height = self.headerContainerHeight;
                self.legendButton.frame.origin.y = self.legendButtonOriginY;
                }, completion: { success in
                    self.legendView.hidden = true;
            });
        } else {
            legendView.hidden = false;
            legendButton.image = UIImage(named: "oc_dropdownmenu_up");
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.meterContainer.frame.size.height = self.meterContainerHeight + self.legendView.frame.size.height;
                self.activityContainer.frame.origin.y = self.activityContainerOriginY + self.legendView.frame.size.height;
                self.headerContainer.frame.size.height = self.headerContainerHeight + self.legendView.frame.size.height;
                self.legendButton.frame.origin.y = self.legendButtonOriginY + self.legendView.frame.size.height;
                }, completion: nil);
        }
        
        tableView.beginUpdates();
        tableView.tableHeaderView = tableView.tableHeaderView!;
        tableView.endUpdates();
        
        legendIsOpen = !legendIsOpen;
    }
}