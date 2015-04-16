import Foundation

class BodyStatsViewController: BaseViewController {
    
    var selected: HigiCheckin?;
    
    var checkins: [HigiCheckin] = SessionController.Instance.checkins;
    
    var plottedCheckins: [HigiCheckin] = [];
    
    let titles = ["Blood Pressure", "Pulse", "Weight"];
    
    var type = "bp";
    
    var detailsShowing = false;
    
    var graph: BodyStatGraph!;
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var firstPanel: UIView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var secondPanel: UIView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var thirdPanel: UIView!
    @IBOutlet weak var firstPanelValue: UILabel!
    @IBOutlet weak var thirdPanelLabel: UILabel!
    @IBOutlet weak var thirdPanelUnit: UILabel!
    @IBOutlet weak var thirdPanelValue: UILabel!
    @IBOutlet weak var secondPanelUnit: UILabel!
    @IBOutlet weak var secondPanelLabel: UILabel!
    @IBOutlet weak var secondPanelValue: UILabel!
    @IBOutlet weak var pulseValue: UILabel!
    @IBOutlet weak var firstPanelLabel: UILabel!
    @IBOutlet weak var secondPulsePanel: UIView!
    @IBOutlet weak var pulseDate: UILabel!
    
    @IBOutlet weak var firstPulsePanel: UIView!
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
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
        for checkin in checkins {
            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
            if (type == "bp" && checkin.map != nil && checkin.map > 0) {
                graphPoints.append(GraphPoint(x: checkinTime, y: checkin.map));
                if (checkin.diastolic != nil && checkin.diastolic > 0) {
                    diastolicPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.diastolic!)));
                } else {
                    diastolicPoints.append(GraphPoint(x: checkinTime, y: 0));
                }
                if (checkin.systolic != nil && checkin.systolic > 0) {
                    systolicPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.systolic!)));
                } else {
                    systolicPoints.append(GraphPoint(x: checkinTime, y: 0));
                }
                plottedCheckins.append(checkin);
            }
            
            if (type == "weight" && checkin.weightKG != nil && checkin.weightKG > 0) {
                graphPoints.append(GraphPoint(x: checkinTime, y: checkin.bmi));
                plottedCheckins.append(checkin);
            }

            if (type == "pulse" && checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                graphPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.pulseBpm!)));
                plottedCheckins.append(checkin);
            }
        }
        
        var frame = CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: self.view.frame.size.width);
        var graphFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.size.height - 25);

        if (type == "bp") {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
            color = Utility.colorFromHexString("#8379B5");
            cardTitle.text = "Blood Pressure";
        } else if (type == "weight") {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
            color = Utility.colorFromHexString("#EE6C55");
            cardTitle.text = "Weight";
        } else {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
            color = Utility.colorFromHexString("#5FAFDF");
            cardTitle.text = "Pulse";
            pulseDate.textColor = color;
            pulseValue.textColor = color;
        }
        
        headerView.backgroundColor = color;
        firstPanelValue.textColor = color;
        secondPanelValue.textColor = color;
        thirdPanelValue.textColor = color;
        
        graph.setupForBodyStat(color);
        graphView.addSubview(graph);
    }

    func setSelected(index: Int) {
        let checkin = plottedCheckins[index];
        if (selectedView.hidden) {
            UIView.animateWithDuration(0.5, animations: {
                self.graphView.frame.size.height = 265;
                self.selectedView.hidden = false;
                }, completion: { complete in
                    self.graph.layoutSubviews();
            });
            
        }
        let formatter = NSDateFormatter();
        formatter.dateFormat = "MM/dd/yyyy";
        firstPanelValue.text = "\(formatter.stringFromDate(checkin.dateTime))";
        if (type == "bp") {
            secondPanelValue.text = "\(checkin.systolic!)/\(checkin.diastolic!)";
            secondPanelUnit.text = "mmHg";
            secondPanelLabel.text = "Blood Pressure";
            thirdPanelValue.text = "\(Int(checkin.map!))";
            thirdPanelUnit.text = "mmHg";
            thirdPanelLabel.text = "Mean Arterial Pressure";
        } else if (type == "weight") {
            secondPanelValue.text = "\(Int(checkin.weightLbs!))";
            secondPanelUnit.text = "lbs";
            secondPanelLabel.text = "Weight";
            thirdPanelValue.text = "\(Int(checkin.bmi!))";
            thirdPanelUnit.text = "";
            thirdPanelLabel.text = "Body Mass Index";
        } else {
            firstPanel.hidden = true;
            secondPanel.hidden = true;
            thirdPanel.hidden = true;
            
            firstPulsePanel.hidden = false;
            secondPulsePanel.hidden = false;
            
            pulseDate.text = "\(formatter.stringFromDate(checkin.dateTime))";
            pulseValue.text = "\(checkin.pulseBpm!)";
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false;
    }
}
