import Foundation

class BodyStatCard: UIView {
    
    var selected: HigiCheckin?;
    
    var checkins: [HigiCheckin] = SessionController.Instance.checkins;
    
    var plottedCheckins: [HigiCheckin] = [];
    
    var type = BodyStatsType.BloodPressure;
    
    var index:Int!
    
    var selectedViewY:CGFloat = 267;
    
    var graphViewHeight:CGFloat!;
    
    var graph: BodyStatGraph!;
    
    var viewFrame: CGRect!;
    
    var detailsOpen = false;
    
    @IBOutlet weak var view: UIView!
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
    
    class func instanceFromNib(frame: CGRect, type: BodyStatsType) -> BodyStatCard {
        let view = UINib(nibName: "BodyStatCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BodyStatCard;
        view.type = type;
        view.frame = frame;
        view.viewFrame = frame;
        view.graphView.frame.size.width = frame.size.width;
        
        let tapRecognizer = UITapGestureRecognizer(target: view, action: "cardClicked:");
        let swipe = UISwipeGestureRecognizer(target: view, action: "cardClicked:");
        swipe.direction = UISwipeGestureRecognizerDirection.Left;
        view.headerView.addGestureRecognizer(tapRecognizer);
        view.headerView.addGestureRecognizer(swipe);
        
        let selectedTapRecognizer = UITapGestureRecognizer(target: view, action: "selectedTapped:");
        view.selectedView.addGestureRecognizer(selectedTapRecognizer);
        
        let color = Utility.colorFromBodyStatType(type);
        view.headerView.backgroundColor = color;
        view.firstPanelValue.textColor = color;
        view.secondPanelValue.textColor = color;
        view.thirdPanelValue.textColor = color;
        
        if (type == BodyStatsType.BloodPressure) {
            view.title.text = "Blood Pressure";
        } else if (type == BodyStatsType.Weight) {
            view.title.text = "Weight";
        } else {
            view.title.text = "Pulse";
            view.pulseDate.textColor = color;
            view.pulseValue.textColor = color;
        }
        view.graphViewHeight = view.graphView.frame.size.height;
        return view;
    }
    
    func resizeFrameWithWidth(width: CGFloat) {
        viewFrame.size.width = width;
        graphView.frame.size.width = width;
        graphView.frame.size.height = graphViewHeight;
        selectedView.frame.size.width = width;
        if (graph != nil) {
            graph.frame.size.width = width;
        }
    }
    
    func setupGraph() {
        var graphPoints: [GraphPoint] = [], diastolicPoints: [GraphPoint] = [], systolicPoints: [GraphPoint] = [];
        
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
//            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
        } else if (type == BodyStatsType.Weight) {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
        } else {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
        }

        let tap = UITapGestureRecognizer(target: self, action: "tapped:");
        graph.addGestureRecognizer(tap);
        
        graph.setupForBodyStat(type);
        graph.backgroundColor = UIColor.whiteColor();
        graph.userInteractionEnabled = true;
        graphView.addSubview(graph);

        setSelected(graphPoints.count - 1);
    }
    
    func selectedTapped(sender: AnyObject) {
        if (!detailsOpen) {
            UIView.animateWithDuration(1, delay: 0, options: .CurveEaseInOut, animations: {
                self.selectedView.frame.origin.y = self.headerView.frame.size.height;
                }, completion: nil);
            detailsOpen = true;
        }
    }
    
    func animateBounce() {
        selectedView.frame.origin.y = UIScreen.mainScreen().bounds.height;
        UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseInOut, animations: {
                self.selectedView.frame.origin.y = self.selectedViewY - 10;
            }, completion: { complete in
                UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                    self.selectedView.frame.origin.y = self.selectedViewY;
                    }, completion: nil);
        });
    }
    
    func showSelectedView() {
        UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseInOut, animations: {
            self.selectedView.frame.origin.y = self.selectedViewY;
        }, completion: nil);
        selectedView.frame.origin.y = self.selectedViewY;
    }
    
    func tapped(sender: AnyObject) {
        let i = 0;
    }
    
    func setSelected(index: Int) {
        let checkin = plottedCheckins[index];
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
            thirdPanel.hidden = true;
            
            firstPulsePanel.hidden = false;
            secondPulsePanel.hidden = false;
            
            secondPanelValue.text = "\(checkin.pulseBpm!)";
            secondPanelUnit.text = "mmHg";
            secondPanelLabel.text = "Beats Per Minute";
        }
    }
    
    func cardClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! BodyStatsViewController).cardClicked(index);
    }
    
    @IBAction func backButtonClick(sender: AnyObject) {
        (Utility.getViewController(self) as! BodyStatsViewController).backButtonClick();
    }
    
    @IBAction func infoButtonClick(sender: AnyObject) {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        let a = viewFrame.size.width;
        self.view.frame = viewFrame;
        graphView.frame.size.width = viewFrame.size.width;
        graphView.frame.size.height = graphViewHeight;
        selectedView.frame.size.width = viewFrame.size.width;
        if (graph != nil) {
            graph.frame.size.width = viewFrame.size.width;
        }
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        graphView.frame.size.height = graphViewHeight;
        if (selectedView.frame.contains(point)) {
            selectedTapped(self.view);
            return true;
        } else if (graphView.frame.contains(point)) {
            return graph.pointInside(point, withEvent: event);
        }
        return super.pointInside(point, withEvent: event);
    }
}