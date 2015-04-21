//
//  ViewController.swift
//  higi
//
//  Created by Dan Harms on 6/9/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import UIKit

class BodyStatsViewController: BaseViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, CPTAnimationDelegate {
    
    var currentPage = 0;
    
    var selected: HigiCheckin! = SessionController.Instance.checkins.last as HigiCheckin!;
    
    var isPortrait = true;
    
    var landView = BodyStatsLandView.instanceFromNib(), portView = BodyStatsPortView.instanceFromNib();
    
    let titles = ["Blood Pressure", "Pulse", "Mean Arterial Press.", "Weight", "BMI"];
    
    var graphViews: [GraphView] = [];
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        portView.frame = self.view.frame;
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        navigationController!.interactivePopGestureRecognizer.enabled = false;
        navigationController!.interactivePopGestureRecognizer.delegate = self;
        var shareButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton;
        shareButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        shareButton.addTarget(self, action: "shareAction:", forControlEvents: UIControlEvents.TouchUpInside);
        shareButton.setBackgroundImage(UIImage(named: "btn_share_white.png"), forState: UIControlState.Normal);
        var shareButtonItem = UIBarButtonItem(customView: shareButton);
        self.navigationItem.rightBarButtonItem = shareButtonItem;
        setupGraphs();
        self.view.addSubview(portView);
        portView.pager.currentPage = currentPage;
        changePage(portView.pager);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        revealController.panGestureRecognizer().enabled = false;
        if (selected != nil) {
            revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue | UIInterfaceOrientationMask.LandscapeLeft.rawValue | UIInterfaceOrientationMask.LandscapeRight.rawValue;
            revealController.shouldRotate = true;
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (SessionController.Instance.checkins.count > 0) {
            setSelected(selected);
        }
        NSFileManager.defaultManager().removeItemAtPath(self.getShareFilePath(), error: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue;
        revealController.shouldRotate = false;
        if (!isPortrait) {
            self.view.setNeedsDisplay();

            prepareForRotate();
            constructScreen(UIInterfaceOrientation.LandscapeLeft);
        }
        super.viewWillDisappear(animated);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        if (selected != nil) {
            setSelected(selected);
        }
        portView.scrollView.contentSize = CGSize(width: portView.scrollView.frame.size.width * 5, height: portView.scrollView.frame.size.height);
        landView.scrollView.contentSize = CGSize(width: landView.scrollView.frame.size.width * 5, height: landView.scrollView.frame.size.height);
    }
    
    func setupGraphs() {
        
        landView.button1m.addTarget(self, action: "rangeClick:", forControlEvents: UIControlEvents.TouchUpInside);
        landView.button3m.addTarget(self, action: "rangeClick:", forControlEvents: UIControlEvents.TouchUpInside);
        landView.button6m.addTarget(self, action: "rangeClick:", forControlEvents: UIControlEvents.TouchUpInside);
        landView.buttonAll.addTarget(self, action: "rangeClick:", forControlEvents: UIControlEvents.TouchUpInside);
        
        landView.pager.addTarget(self, action: "changePage:", forControlEvents: UIControlEvents.ValueChanged);
        portView.pager.addTarget(self, action: "changePage:", forControlEvents: UIControlEvents.ValueChanged);
                
        var bps: [HigiCheckin] = [];
        var weights: [HigiCheckin] = [];
        
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyyy";
        var lastBpDate = "", lastBmiDate = "";
        
        for checkin in SessionController.Instance.checkins {
            var bpDate = dateFormatter.stringFromDate(checkin.dateTime);
            if (checkin.systolic != nil && checkin.systolic > 0) {
                if (bpDate != lastBpDate) {
                    bps.append(checkin);
                    lastBpDate = bpDate;
                } else {
                    bps[bps.count - 1] = checkin;
                }
            }
            
            var bmiDate = dateFormatter.stringFromDate(checkin.dateTime);
            if (checkin.weightKG != nil && checkin.weightKG > 0) {
                if (bmiDate != lastBmiDate) {
                    weights.append(checkin);
                    lastBmiDate = bmiDate;
                } else {
                    weights[weights.count - 1] = checkin;
                }
            }
        }
        
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: self.view.frame.size.width);
        var graphFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.size.height - 25);
        landView.frame = frame;
        landView.scrollView.frame = frame;
        landView.scrollView.contentSize = CGSize(width: 5 * frame.size.width, height: frame.size.height);
        var bpLandGraphView = GraphView.createViewFromNib(false);
        bpLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(bpLandGraphView);
        bpLandGraphView.initializeView(BpGraphDelegate(), frame: frame, checkins: bps, isPortrait: false)
        graphViews.append(bpLandGraphView);
        
        frame.origin.x += frame.size.width;
        var pulseLandGraphView = GraphView.createViewFromNib(false);
        pulseLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(pulseLandGraphView);
        pulseLandGraphView.initializeView(PulseGraphDelegate(), frame: frame, checkins: bps, isPortrait: false)
        graphViews.append(pulseLandGraphView);
        
        frame.origin.x += frame.size.width;
        var mapLandGraphView = GraphView.createViewFromNib(false);
        mapLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(mapLandGraphView);
        mapLandGraphView.initializeView(MapGraphDelegate(), frame: frame, checkins: bps, isPortrait: false)
        graphViews.append(mapLandGraphView);
        
        frame.origin.x += frame.size.width;
        var weightLandGraphView = GraphView.createViewFromNib(false);
        weightLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(weightLandGraphView);
        weightLandGraphView.initializeView(WeightGraphDelegate(), frame: frame, checkins: weights, isPortrait: false)
        graphViews.append(weightLandGraphView);
        
        frame.origin.x += frame.size.width;
        var bmiLandGraphView = GraphView.createViewFromNib(false);
        bmiLandGraphView.graphContainer.frame = graphFrame;
        landView.scrollView.addSubview(bmiLandGraphView);
        bmiLandGraphView.initializeView(BmiGraphDelegate(), frame: frame, checkins: weights, isPortrait: false);
        graphViews.append(bmiLandGraphView);
        
        landView.scrollView.delegate = self;
        
        frame = portView.scrollView.bounds;
        var bpPortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(bpPortGraphView);
        bpPortGraphView.initializeView(BpGraphDelegate(), frame: frame, checkins: bps, isPortrait: true);
        graphViews.append(bpPortGraphView);
        
        frame.origin.x += portView.scrollView.frame.size.width;
        var pulsePortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(pulsePortGraphView);
        pulsePortGraphView.initializeView(PulseGraphDelegate(), frame: frame, checkins: bps, isPortrait: true);
        graphViews.append(pulsePortGraphView);
        
        frame.origin.x += portView.scrollView.frame.size.width;
        var mapPortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(mapPortGraphView);
        mapPortGraphView.initializeView(MapGraphDelegate(), frame: frame, checkins: bps, isPortrait: true);
        graphViews.append(mapPortGraphView);
        
        frame.origin.x += portView.scrollView.frame.size.width;
        var weightPortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(weightPortGraphView);
        weightPortGraphView.initializeView(WeightGraphDelegate(), frame: frame, checkins: weights, isPortrait: true);
        graphViews.append(weightPortGraphView);
        
        frame.origin.x += portView.scrollView.frame.size.width;
        var bmiPortGraphView = GraphView.createViewFromNib(true);
        portView.scrollView.addSubview(bmiPortGraphView);
        bmiPortGraphView.initializeView(BmiGraphDelegate(), frame: frame, checkins: weights, isPortrait: true);
        graphViews.append(bmiPortGraphView);
        
        portView.scrollView.delegate = self;
        
        if (SessionController.Instance.checkins.count == 0) {
            portView.orientationIndicator.hidden = true;
        }
        
        
    }
    
    @IBAction func rangeClick(sender: AnyObject) {
        
        if (!isPortrait) {
            landView.button1m.setBackgroundImage(nil, forState: UIControlState.Normal);
            landView.button3m.setBackgroundImage(nil, forState: UIControlState.Normal);
            landView.button6m.setBackgroundImage(nil, forState: UIControlState.Normal);
            landView.buttonAll.setBackgroundImage(nil, forState: UIControlState.Normal);
            (sender as! UIButton).setBackgroundImage(UIImage(named: "graph_timespan_bg"), forState: UIControlState.Normal);
            var range = 0;
            if (sender as! NSObject == landView.button1m) {
                range = 0;
            } else if (sender as! NSObject == landView.button3m) {
                range = 1;
            } else if (sender as! NSObject == landView.button6m) {
                range = 2;
            } else {
                range = 3;
            }
            var delegateSet = false;
            for graphView in graphViews {
                graphView.setRange(range, delegate: (delegateSet ? self : nil));
                delegateSet = true;
            }
        }
        
    }
    
    func animationDidUpdate(operation: CPTAnimationOperation!) {
        setSelected(selected);
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width));
        var pager = isPortrait ? portView.pager : landView.pager;
        pager.currentPage = page;
        changePage(pager);
    }
    
    @IBAction func changePage(sender: AnyObject) {
        var pager = sender as! UIPageControl;
        var page = pager.currentPage;
        self.title = titles[page];
        landView.titleLabel.text = titles[page];
        
        var frame = isPortrait ? portView.scrollView.frame : landView.scrollView.frame;
        
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        if (isPortrait) {
            portView.scrollView.setContentOffset(frame.origin, animated: true);
        } else {
            landView.scrollView.setContentOffset(frame.origin, animated: true);
        }
        
    }
    
    func shareAction(sender: AnyObject) {
        Flurry.logEvent("BodystatShare_Pressed");
        var activityItems = ["higi_results.csv", exportData()];
        var shareScreen = UIActivityViewController(activityItems: activityItems, applicationActivities: nil);
        self.presentViewController(shareScreen, animated: true, completion: nil);
        
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration);
        
        prepareForRotate();
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation);
        constructScreen(fromInterfaceOrientation);
    }
    
    func prepareForRotate() {
        if (SessionController.Instance.checkins.count > 0) {
            landView.removeFromSuperview();
            portView.removeFromSuperview();
            var page: Int;
            if (isPortrait) {
                page = portView.pager.currentPage;
            } else {
                page = landView.pager.currentPage;
            }
            switch (page) {
            case 0:
                self.view.backgroundColor = Utility.colorFromHexString("#8478C2");
            case 1:
                self.view.backgroundColor = Utility.colorFromHexString("#5FB0E0");
            case 2:
                self.view.backgroundColor = Utility.colorFromHexString("#4CA156");
            case 3:
                self.view.backgroundColor = Utility.colorFromHexString("#EF6C56");
            case 4:
                self.view.backgroundColor = Utility.colorFromHexString("#4EC9AE");
            default:
                self.view.backgroundColor = Utility.colorFromHexString("#FFFFFF");
            }
        }
    }
    
    func constructScreen(fromInterfaceOrientation: UIInterfaceOrientation) {
        if (SessionController.Instance.checkins.count > 0) {
            if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
                self.view.addSubview(portView);
                isPortrait = true;
                portView.pager.currentPage = landView.pager.currentPage;
            } else {
                self.view.addSubview(landView);
                isPortrait = false;
                landView.pager.currentPage = portView.pager.currentPage;
            }
            var page = portView.pager.currentPage;
            var frame: CGRect;
            if (isPortrait) {
                frame = portView.scrollView.frame;
            } else {
                frame = landView.scrollView.frame;
            }
            
            frame.origin.x = frame.size.width * CGFloat(page);
            frame.origin.y = 0;
            if (isPortrait) {
                portView.scrollView.scrollRectToVisible(frame, animated: false);
            } else {
                landView.scrollView.scrollRectToVisible(frame, animated: false);
            }
            self.view.backgroundColor = Utility.colorFromHexString("#FFFFFF");
            self.navigationController!.navigationBarHidden = !isPortrait;
            var delay: UInt64 = 10;
            var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSEC_PER_MSEC));
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.setSelected(self.selected);
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
            });
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false;
    }
    
    func setSelected(selected: HigiCheckin) {
        self.selected = selected;
        for graphView in graphViews {
            graphView.setSelectedCheckin(selected);
        }
    }
    
    func exportData() -> NSURL {
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyy";
        var contents = "Date,Location,Address of higi Station,Systolic Pressure (mmHg),Diastolic Pressure (mmHg),Pulse (bpm),Mean Arterial Pressure (mmHg), Weight (lbs),Body Mass Index\n";
        
        for index in reverse(0..<SessionController.Instance.checkins.count) {
            var checkin = SessionController.Instance.checkins[index];
            var address = "", systolic = "", diastolic = "", pulse = "", map = "", weight = "", bmi = "";
            var organization = checkin.sourceVendorId!;
            if (checkin.kioskInfo != nil) {
                organization = checkin.kioskInfo!.organizations[0];
                address = "\"\(checkin.kioskInfo!.fullAddress)\"";
            }
            
            if (checkin.systolic != nil && checkin.pulseBpm != nil) {
                systolic = "\(checkin.systolic!)";
                diastolic = "\(checkin.diastolic!)";
                pulse = "\(checkin.pulseBpm!)";
                map = String(format: "%.1f", checkin.map!);
            }
            
            if (checkin.bmi != nil) {
                bmi = String(format: "%.2f", checkin.bmi!);
                weight = "\(Int(checkin.weightLbs!))";
            }
            
            var row = "\(dateFormatter.stringFromDate(checkin.dateTime)),\(organization),\(address),\(systolic),\(diastolic),\(pulse),\(map),\(weight),\(bmi)\n";
            contents += row;
        }
        
        let filePath = getShareFilePath();
        
        contents.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil);
        
        return NSURL(fileURLWithPath: filePath)!;
        
    }
    
    func getShareFilePath() -> String {
        var docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String;
        return docPath.stringByAppendingPathComponent("higi_results.csv");
    }
    
}


