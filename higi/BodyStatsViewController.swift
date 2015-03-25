import Foundation

class BodyStatsViewController: BaseViewController {
    
    var selected: HigiCheckin?;
    
    var checkins: [HigiCheckin] = SessionController.Instance.checkins;
    
    var plottedCheckins: [HigiCheckin] = [];
    
    let titles = ["Blood Pressure", "Pulse", "Weight"];
    
    var type:String!;
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var selectedFirstPanelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.navigationController!.navigationBarHidden = true;
        
        setupGraph();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        revealController.panGestureRecognizer().enabled = false;
        revealController.supportedOrientations = UIInterfaceOrientationMask.LandscapeRight.rawValue;
        revealController.shouldRotate = true;
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation");
    }
    
    override func viewWillDisappear(animated: Bool) {
        revealController.supportedOrientations = UIInterfaceOrientationMask.Portrait.rawValue;
        self.navigationController!.navigationBarHidden = false;
        self.view.setNeedsDisplay();
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation");
        super.viewWillDisappear(animated);
    }
    
    @IBAction func backButtonClick(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    @IBAction func infoButtonClick(sender: AnyObject) {
        
    }
    
    func setupGraph() {
        var graphPoints: [GraphPoint] = [];
        var diastolicPoints: [GraphPoint] = [];
        var systolicPoints: [GraphPoint] = [];
        
        var color = UIColor.whiteColor();
        var graph:BodyStatGraph;
        for checkin in checkins {
            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
            if (type == "bp") {
                if (checkin.map != nil && checkin.map > 0) {
                    graphPoints.append(GraphPoint(x: checkinTime, y: checkin.map));
                    if (checkin.diastolic != nil && checkin.diastolic > 0) {
                        diastolicPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.diastolic!)));
                    }
                    if (checkin.systolic != nil && checkin.systolic > 0) {
                        systolicPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.systolic!)));
                    }
                    plottedCheckins.append(checkin);
                }
            }
            
            if (type == "weight" && checkin.weightKG != nil && checkin.weightKG > 0) {
                graphPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: checkin.bmi));
                plottedCheckins.append(checkin);
            }
            
            if (type == "pulse" && checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                graphPoints.append(GraphPoint(x: Double(checkin.dateTime.timeIntervalSince1970), y: Double(checkin.pulseBpm!)));
                plottedCheckins.append(checkin);
            }
        }
        
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: self.view.frame.size.width);
        var graphFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.size.height - 25);

        if (type == "bp") {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
            color = Utility.colorFromHexString("#8379B5");
            headerView.backgroundColor = color;
            selectedFirstPanelLabel.textColor = color;
            cardTitle.text = "Blood Pressure";
        } else if (type == "weight") {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
            color = Utility.colorFromHexString("#EE6C55");
            headerView.backgroundColor = color;
            selectedFirstPanelLabel.textColor = color;
            cardTitle.text = "Weight";
        } else {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
            color = Utility.colorFromHexString("#5FAFDF");
            headerView.backgroundColor = color;
            selectedFirstPanelLabel.textColor = color;
            cardTitle.text = "Pulse";
        }
        
        graph.setupForBodyStat(color);
        graphView.addSubview(graph);
    }
    
//    func setSelected(selected: HigiCheckin) {
//        self.selected = selected;
//        
////        for graphView in graphViews {
////            graphView.setSelectedCheckin(selected);
////        }
//    }
    
    func setSelected(index: Int) {
        let checkin = plottedCheckins[index];
        if (selectedView.hidden) {
            selectedView.hidden = false;
        }
        if (type == "bp") {
            selectedFirstPanelLabel.text = "\(checkin.map) mmHg";
        } else if (type == "weight") {
            selectedFirstPanelLabel.text = "\(checkin.weightLbs) lbs";
        } else {
            selectedFirstPanelLabel.text = "\(checkin.pulseBpm) bpm";
        }
    }
}
