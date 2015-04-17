import Foundation

class BodyStatCard: UIView {
    
    var selected: HigiCheckin?;
    
    var checkins: [HigiCheckin] = SessionController.Instance.checkins;
    
    var plottedCheckins: [HigiCheckin] = [];
    
    var type = BodyStatsType.BloodPressure;
    
    var graph: BodyStatGraph!;
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var firstPanel: UIView!
    @IBOutlet weak var firstPanelValue: UILabel!
    @IBOutlet weak var firstPanelLabel: UILabel!

    @IBOutlet weak var secondPanel: UIView!
    @IBOutlet weak var secondPanelValue: UILabel!
    @IBOutlet weak var secondPanelUnit: UILabel!
    @IBOutlet weak var secondPanelLabel: UILabel!

    @IBOutlet weak var thirdPanel: UIView!
    @IBOutlet weak var thirdPanelValue: UILabel!
    @IBOutlet weak var thirdPanelUnit: UILabel!
    @IBOutlet weak var thirdPanelLabel: UILabel!
    
    @IBOutlet weak var firstPulsePanel: UIView!
    @IBOutlet weak var secondPulsePanel: UIView!
    @IBOutlet weak var pulseValue: UILabel!
    @IBOutlet weak var pulseDate: UILabel!
    
    func setupGraph(type: BodyStatsType) {
        self.type = type;
        
        var graphPoints: [GraphPoint] = [];
        var diastolicPoints: [GraphPoint] = [];
        var systolicPoints: [GraphPoint] = [];
        
        let color = Utility.colorFromBodyStatType(type);
        for checkin in checkins {
            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
            if (type == BodyStatsType.BloodPressure && checkin.map != nil && checkin.map > 0) {
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
            
            if (type == BodyStatsType.Weight && checkin.weightKG != nil && checkin.weightKG > 0) {
                graphPoints.append(GraphPoint(x: checkinTime, y: checkin.bmi));
                plottedCheckins.append(checkin);
            }
            
            if (type == BodyStatsType.Pulse && checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                graphPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.pulseBpm!)));
                plottedCheckins.append(checkin);
            }
        }
        
        var frame = CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.width);
        var graphFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.size.height - 25);
        
        if (type == BodyStatsType.BloodPressure) {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
            title.text = "Blood Pressure";
        } else if (type == BodyStatsType.Weight) {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
            title.text = "Weight";
        } else {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
            title.text = "Pulse";
            pulseDate.textColor = color;
            pulseValue.textColor = color;
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "cardClicked:");
        headerView.addGestureRecognizer(tapRecognizer);
        
        headerView.backgroundColor = color;
        firstPanelValue.textColor = color;
        secondPanelValue.textColor = color;
        thirdPanelValue.textColor = color;
        
        graph.setupForBodyStat(type);
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
        if (type == BodyStatsType.BloodPressure) {
            secondPanelValue.text = "\(checkin.systolic!)/\(checkin.diastolic!)";
            secondPanelUnit.text = "mmHg";
            secondPanelLabel.text = "Blood Pressure";
            thirdPanelValue.text = "\(Int(checkin.map!))";
            thirdPanelUnit.text = "mmHg";
            thirdPanelLabel.text = "Mean Arterial Pressure";
        } else if (type == BodyStatsType.Weight) {
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
    
    func cardClicked() {
//        (Utility.getViewController(self) as! BodyStatsViewController).cardClicked(self.tag);
    }
    
    @IBAction func backButtonClick(sender: AnyObject) {
        (Utility.getViewController(self) as! BodyStatsViewController).backButtonClick();
    }
    
    @IBAction func infoButtonClick(sender: AnyObject) {
        
    }
}