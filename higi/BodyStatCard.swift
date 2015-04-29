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
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var toggleButton: UIButton!
    
    class func instanceFromNib(frame: CGRect, type: BodyStatsType) -> BodyStatCard {
        let view = UINib(nibName: "BodyStatCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BodyStatCard;
        view.type = type;
        view.frame = frame;
        view.viewFrame = frame;
        view.graphView.frame.size.width = frame.size.width;
        
        let tapRecognizer = UITapGestureRecognizer(target: view, action: "cardClicked:");
        let swipe = UISwipeGestureRecognizer(target: view, action: "cardClicked:");
        swipe.direction = UISwipeGestureRecognizerDirection.Left;
        let drag = UIPanGestureRecognizer(target: view, action: "cardDragged:");
        
        view.addGestureRecognizer(drag);
        view.headerView.addGestureRecognizer(tapRecognizer);
        view.headerView.addGestureRecognizer(swipe);
        
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
        view.graphViewHeight = view.graphView.frame.size.height;
        return view;
    }
    
    func resizeFrameWithWidth(width: CGFloat) {
        viewFrame.size.width = width;
        graphView.frame.size.width = width;
        graphView.frame.size.height = graphViewHeight;
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
        
        var frame = CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.width);
        var graphFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.size.height - 25);
        
        if (type == BodyStatsType.BloodPressure) {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
        } else if (type == BodyStatsType.Weight) {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
            secondaryGraph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: bodyFatPoints);
            secondaryGraph.setupForBodyFat();
//            secondaryGraph.setupForBodyStat(type);
            secondaryGraph.backgroundColor = UIColor.whiteColor();
            secondaryGraph.userInteractionEnabled = true;
            graphView.addSubview(secondaryGraph);
        } else {
            graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: graphPoints);
        }

        graph.setupForBodyStat(type);
        graph.backgroundColor = UIColor.whiteColor();
        graph.userInteractionEnabled = true;
        graphView.addSubview(graph);

        setSelected(graphPoints.count - 1);
    }
    
    func setSelected(index: Int) {
        selectedCheckin = plottedCheckins[index];
        (Utility.getViewController(self) as! BodyStatsViewController).pointSelected(selectedCheckin!, type: type);
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
    
    @IBAction func infoButtonClick(sender: AnyObject) {
        
    }
    
    @IBAction func toggleClicked(sender: AnyObject) {
        graph.hidden = toggleBmiOn;
        secondaryGraph.hidden = !toggleBmiOn;
        toggleBmiOn = !toggleBmiOn;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.view.frame = viewFrame;
        graphView.frame.size.width = viewFrame.size.width;
        graphView.frame.size.height = graphViewHeight;
        if (graph != nil) {
            graph.frame.size.width = viewFrame.size.width;
        }
        if (secondaryGraph != nil) {
            secondaryGraph.frame.size.width = viewFrame.size.width;
        }
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        graphView.frame.size.height = graphViewHeight;
        if (graphView.frame.contains(point)) {
            return graph.pointInside(point, withEvent: event);
        }
        return super.pointInside(point, withEvent: event);
    }

}