import Foundation

class BodyStatsViewController: BaseViewController, UIGestureRecognizerDelegate, CPTAnimationDelegate {
    var selected: HigiCheckin! = SessionController.Instance.checkins.last as HigiCheckin!;
    
//    var landView = BodyStatsLandView.instanceFromNib();
    
    let titles = ["Blood Pressure", "Pulse", "Weight"];
    
    var type:String!;
    
    @IBOutlet weak var graphView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad();
//        landView.frame = self.view.frame;
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        navigationController!.interactivePopGestureRecognizer.enabled = false;
        navigationController!.interactivePopGestureRecognizer.delegate = self;
        setupGraph();

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
    }
    
    override func viewWillDisappear(animated: Bool) {
        revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue;
        revealController.shouldRotate = false;
        self.view.setNeedsDisplay();

        prepareForRotate();
        constructScreen(UIInterfaceOrientation.LandscapeLeft);
        super.viewWillDisappear(animated);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        if (selected != nil) {
            setSelected(selected);
        }
    }
    
    func setupGraph() {

        var graphPoints: [GraphPoint] = [];
        var diastolicPoints: [GraphPoint] = [];
        var systolicPoints: [GraphPoint] = [];
        
        var color = UIColor.whiteColor();
        var graph:DashboardBodyStatGraph;
        for checkin in SessionController.Instance.checkins {
            if (type == "bp" && checkin.systolic != nil && checkin.systolic > 0) {
                graphPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: checkin.map));
                diastolicPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.diastolic!)));
                systolicPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.systolic!)));
                color = Utility.colorFromHexString("#8379B5");
            }
            
            if (type == "weight" && checkin.weightKG != nil && checkin.weightKG > 0) {
                graphPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: checkin.bmi));
                color = Utility.colorFromHexString("#EE6C55");
            }
            
            if (type == "pulse" && checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                graphPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.pulseBpm!)));
                color = Utility.colorFromHexString("#5FAFDF");
            }
        }
        
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: self.view.frame.size.width);
        var graphFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.size.height - 25);

        if (type == "bp") {
            graph = DashboardBodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
        } else {
            graph = DashboardBodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
        }
        graph.setupForBodyStat(color);
        graphView.addSubview(graph);
    }
    
    func animationDidUpdate(operation: CPTAnimationOperation!) {
        setSelected(selected);
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
            self.view.backgroundColor = Utility.colorFromHexString("#FFFFFF");
        }
    }
    
    func constructScreen(fromInterfaceOrientation: UIInterfaceOrientation) {
        if (SessionController.Instance.checkins.count > 0) {

            self.view.backgroundColor = Utility.colorFromHexString("#FFFFFF");
            self.navigationController!.navigationBarHidden = true;
            var delay: UInt64 = 10;
            var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSEC_PER_MSEC));
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.setSelected(self.selected);
                self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
            });
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
        return false;
    }
    
    func setSelected(selected: HigiCheckin) {
        self.selected = selected;
//        for graphView in graphViews {
//            graphView.setSelectedCheckin(selected);
//        }
    }

}


