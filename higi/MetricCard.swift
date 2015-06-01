import Foundation

class MetricCard: UIView {
    
    var selectedCheckin: HigiCheckin?;
    
    var selectedActivity: (Double, Int)?;
    
    var checkins: [HigiCheckin] = SessionController.Instance.checkins;
    
    var plottedCheckins: [HigiCheckin] = [];
    
    var plottedActivities: [(Double, Int)] = [];
    
    var type = MetricsType.BloodPressure;
    
    var index:Int!
    
    var graphViewHeight:CGFloat!;
    
    var graph, secondaryGraph: MetricGraph!;
    
    var viewFrame: CGRect!;
    
    var toggleBmiOn = true;
    
    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var toggleButton: UIButton!
    
    class func instanceFromNib(frame: CGRect, type: MetricsType) -> MetricCard {
        let view = UINib(nibName: "MetricCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricCard;
        view.type = type;
        view.frame = frame;
        view.viewFrame = frame;
        
        let tapRecognizer = UITapGestureRecognizer(target: view, action: "cardClicked:");
        let swipe = UISwipeGestureRecognizer(target: view, action: "cardClicked:");
        swipe.direction = UISwipeGestureRecognizerDirection.Left;
        let drag = UIPanGestureRecognizer(target: view, action: "cardDragged:");
        
        view.headerView.addGestureRecognizer(tapRecognizer);
        view.headerView.addGestureRecognizer(swipe);
        view.headerView.addGestureRecognizer(drag);
        
        let color = Utility.colorFromMetricType(type);
        view.headerView.backgroundColor = color;
        
        if (type == MetricsType.DailySummary) {
            view.title.text = "Activity";
            view.icon.image = Utility.imageWithColor(UIImage(named: "workouticon")!, color: UIColor.whiteColor());
        } else if (type == MetricsType.BloodPressure) {
            view.title.text = "Blood Pressure";
            view.icon.image = Utility.imageWithColor(UIImage(named: "bloodpressureicon")!, color: UIColor.whiteColor());
        } else if (type == MetricsType.Weight) {
            view.title.text = "Weight";
            view.icon.image = Utility.imageWithColor(UIImage(named: "weighticon")!, color: UIColor.whiteColor());
            view.toggleButton.hidden = false;
        } else {
            view.icon.image = Utility.imageWithColor(UIImage(named: "pulseicon")!, color: UIColor.whiteColor());
            view.title.text = "Pulse";
        }
        return view;
    }
    
    func resizeFrameWithWidth(width: CGFloat) {
        viewFrame.size.width = width;
    }
    
    func setupGraph() {
        var graphPoints: [GraphPoint] = [], diastolicPoints: [GraphPoint] = [], systolicPoints: [GraphPoint] = [], bodyFatPoints: [GraphPoint] = [];
        for checkin in checkins {
            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
            if (type == MetricsType.BloodPressure && checkin.map != nil && checkin.map > 0) {
                graphPoints.append(GraphPoint(x: checkinTime, y: checkin.map));
                plottedCheckins.append(checkin);
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
            }
            if (type == MetricsType.Weight && checkin.weightLbs != nil && checkin.weightLbs > 0) {
                if (checkin.fatRatio > 0) {
                    bodyFatPoints.append(GraphPoint(x: checkinTime, y: checkin.fatRatio));
                }
                graphPoints.append(GraphPoint(x: checkinTime, y: checkin.weightLbs));
                plottedCheckins.append(checkin);
            }
            if (type == MetricsType.Pulse && checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                graphPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.pulseBpm!)));
                plottedCheckins.append(checkin);
            }
        }
        
        if (type == MetricsType.DailySummary) {
            var activityPoints:[GraphPoint] = [];
            let dateString = Constants.dateFormatter.stringFromDate(NSDate());
            var totalPoints = 0;
            for (date, (total, activityList)) in SessionController.Instance.activities {
                if (date == dateString) {
                    totalPoints = total;
                }
                if (activityList.count > 0) {
                    let activityDate =  Double(activityList[0].startTime.timeIntervalSince1970);
                    plottedActivities.append((activityDate, total));
                    graphPoints.append(GraphPoint(x: activityDate, y: Double(total)));
                }
            }
            plottedActivities.sort({$0.0 < $1.0});
            graphPoints.sort({$0.x < $1.x});
        }
        
//        let graphY = headerView.frame.size.height;
        let graphY:CGFloat = 0;
        let graphWidth = UIScreen.mainScreen().bounds.size.width;
        let graphHeight:CGFloat = frame.size.height - headerView.frame.size.height - (frame.size.height - 267);
        if (type == MetricsType.BloodPressure) {
            graph = MetricGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
        } else if (type == MetricsType.Weight) {
            graph = MetricGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints);
            secondaryGraph = MetricGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: bodyFatPoints);
            secondaryGraph.setupForMetric(type, isBodyFat: true);
            secondaryGraph.backgroundColor = UIColor.whiteColor();
            self.graphContainer.addSubview(secondaryGraph);
        } else {
            graph = MetricGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints);
        }
        graph.setupForMetric(type, isBodyFat: false);
        graph.backgroundColor = UIColor.whiteColor();
        graph.userInteractionEnabled = true;
        self.graphContainer.addSubview(graph);
        
        setSelected(graphPoints.count - 1);
    }
    
    func setSelected(index: Int) {
        if (type == MetricsType.DailySummary && index >= 0 && index < plottedActivities.count) {
            selectedActivity = plottedActivities[index];
            (Utility.getViewController(self) as! MetricsViewController).activitySelected(selectedActivity!, type: type);
        } else if (index >= 0 && index < plottedCheckins.count) {
            selectedCheckin = plottedCheckins[index];
            (Utility.getViewController(self) as! MetricsViewController).pointSelected(selectedCheckin!, type: type);
        }
    }
    
    func cardDragged(sender: AnyObject) {
        let parent = (Utility.getViewController(self) as! MetricsViewController);
        let drag = (sender as! UIPanGestureRecognizer);
        if (drag.state == UIGestureRecognizerState.Ended) {
            parent.doneDragging(index);
        } else {
            let translation = drag.translationInView(parent.view);
            parent.cardDragged(index, translation: translation);
        }
    }
    
    func cardClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).cardClicked(index);
    }
    
    @IBAction func backButtonClick(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).backButtonClick();
    }
    
    @IBAction func toggleClicked(sender: AnyObject) {
        graph.hidden = toggleBmiOn;
        secondaryGraph.hidden = !toggleBmiOn;
        toggleBmiOn = !toggleBmiOn;
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if (point.y > headerView.frame.size.height && point.y < headerView.frame.size.height + graph.frame.size.height) {
            graph.selectPlotFromPoint(point);
        }
        return true;
    }
    
}