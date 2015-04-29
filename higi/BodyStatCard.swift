import Foundation

class BodyStatCard: UIView {
    
    var selectedCheckin: HigiCheckin?;
    
    var checkins: [HigiCheckin] = SessionController.Instance.checkins;
    
    var plottedCheckins: [HigiCheckin] = [];
    
    var type = BodyStatsType.BloodPressure;
    
    var index:Int!
    
    var graphViewHeight:CGFloat!;
    
    var graph, secondaryGraph: BodyStatGraph!;
    
    var viewFrame: CGRect!;
    
    var toggleBmiOn = true;
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var toggleButton: UIButton!
    
    class func instanceFromNib(frame: CGRect, type: BodyStatsType) -> BodyStatCard {
        let view = UINib(nibName: "BodyStatCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BodyStatCard;
        view.type = type;
        view.frame = frame;
        view.viewFrame = frame;
        
        let tapRecognizer = UITapGestureRecognizer(target: view, action: "cardClicked:");
        let swipe = UISwipeGestureRecognizer(target: view, action: "cardClicked:");
        swipe.direction = UISwipeGestureRecognizerDirection.Left;
        let drag = UIPanGestureRecognizer(target: view, action: "cardDragged:");
        
        view.addGestureRecognizer(tapRecognizer);
        view.addGestureRecognizer(swipe);
        view.addGestureRecognizer(drag);
        
        let color = Utility.colorFromBodyStatType(type);
        view.headerView.backgroundColor = color;
        
        if (type == BodyStatsType.BloodPressure) {
            view.title.text = "Blood Pressure";
        } else if (type == BodyStatsType.Weight) {
            view.title.text = "Weight";
            view.toggleButton.hidden = false;
        } else {
            view.title.text = "Pulse";
        }
        return view;
    }
    
    func resizeFrameWithWidth(width: CGFloat) {
        viewFrame.size.width = width;
        self.view.frame = viewFrame;
        if (graph != nil) {
            graph.frame.size.width = width;
        }
        if (secondaryGraph != nil) {
            secondaryGraph.frame.size.width = viewFrame.size.width;
        }
    }
    
    func setupGraph() {
        var graphPoints: [GraphPoint] = [], diastolicPoints: [GraphPoint] = [], systolicPoints: [GraphPoint] = [], bodyFatPoints: [GraphPoint] = [];
        
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
            
            if (type == BodyStatsType.Weight && checkin.weightLbs != nil && checkin.weightLbs > 0) {
                if (checkin.fatRatio > 0) {
                    bodyFatPoints.append(GraphPoint(x: checkinTime, y: checkin.fatRatio));
                }
                graphPoints.append(GraphPoint(x: checkinTime, y: checkin.weightLbs));
                plottedCheckins.append(checkin);
            }
            
            if (type == BodyStatsType.Pulse && checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                graphPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.pulseBpm!)));
                plottedCheckins.append(checkin);
            }
        }
        

        let graphY = headerView.frame.size.height;
        let graphWidth = frame.size.width;
        let graphHeight:CGFloat = 214;
        
        if (type == BodyStatsType.BloodPressure) {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
        } else if (type == BodyStatsType.Weight) {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints);
            secondaryGraph = BodyStatGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: bodyFatPoints);
            secondaryGraph.setupForBodyStat(type, isBodyFat: true);
            secondaryGraph.backgroundColor = UIColor.whiteColor();
            secondaryGraph.userInteractionEnabled = true;
            self.view.addSubview(secondaryGraph);
        } else {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints);
        }
        
        graph.setupForBodyStat(type, isBodyFat: false);
        graph.backgroundColor = UIColor.whiteColor();
        graph.userInteractionEnabled = true;
        
        self.view.addSubview(graph);

        setSelected(graphPoints.count - 1);
    }
    
    func setSelected(index: Int) {
        if (index > 0) {
            selectedCheckin = plottedCheckins[index];
            (Utility.getViewController(self) as! BodyStatsViewController).pointSelected(selectedCheckin!, type: type);
        }
    }
    
    func cardDragged(sender: AnyObject) {
        let parent = (Utility.getViewController(self) as! BodyStatsViewController);
        let drag = (sender as! UIPanGestureRecognizer);
        if (drag.state == UIGestureRecognizerState.Ended) {
            parent.doneDragging(index);
        } else {
            let translation = drag.translationInView(parent.view);
            parent.cardDragged(index, translation: translation);
        }
    }
    
    func cardClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! BodyStatsViewController).cardClicked(index);
    }
    
    @IBAction func backButtonClick(sender: AnyObject) {
        (Utility.getViewController(self) as! BodyStatsViewController).backButtonClick();
    }
    
    @IBAction func toggleClicked(sender: AnyObject) {
        graph.hidden = toggleBmiOn;
        secondaryGraph.hidden = !toggleBmiOn;
        toggleBmiOn = !toggleBmiOn;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.view.frame = viewFrame;
        if (graph != nil) {
            graph.frame.size.width = viewFrame.size.width;
        }
        if (secondaryGraph != nil) {
            secondaryGraph.frame.size.width = viewFrame.size.width;
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if (graph.frame.contains(point)) {
            return graph.pointInside(point, withEvent: event);
        }
        return super.pointInside(point, withEvent: event);
    }
    
}