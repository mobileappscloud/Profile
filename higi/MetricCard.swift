import Foundation

class MetricCard: UIView, MetricDelegate {
    
    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var triangleView: UIView!
    @IBOutlet weak var blankStateContainer: UIView!
    @IBOutlet weak var blankStateImage: UIImageView!
    @IBOutlet weak var blankStateTitle: UILabel!
    @IBOutlet weak var blankStateText: UILabel!
    @IBOutlet weak var blankStateButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var secondBlankStateButton: UIButton!
    
    var graph, secondaryGraph: MetricGraph!;
    
    var delegate: MetricDelegate!;
    
    var position:Int!;
    
    var selectedPoint: SelectedPoint!;
    
    var selectedCheckin: HigiCheckin!;
    
    var initializing = true, toggleOn = true, blankState = false;
    
    var regions: [UIView] = [];
    
    var points: [GraphPoint] = [], altPoints: [GraphPoint] = [];
    
    class func instanceFromNib(delegate: MetricDelegate, frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint]) -> MetricCard {
        let view = UINib(nibName: "MetricCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricCard;
        view.setup(delegate, frame: frame, points: points, altPoints: altPoints);
        return view;
    }

    func setup(delegate: MetricDelegate, frame: CGRect, points: [GraphPoint], altPoints:[GraphPoint]) {
        self.delegate = delegate;
        self.points = points;
        self.altPoints = altPoints;
        
        initFrame(frame);
        initGraphView();
        initHeader();
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if blankState {
            if containsPoint(blankStateButton.frame, point: point) {
                return blankStateButton;
            } else if containsPoint(secondBlankStateButton.frame, point: point) {
                return secondBlankStateButton;
            }
        } else if (point.y > 54 && point.y < (graphContainer.frame.origin.y + graphContainer.frame.size.height)) {
            if (!graph.hidden) {
                return graph;
            } else {
                return secondaryGraph;
            }
        }
        return super.hitTest(point, withEvent: event);
    }
    
    func getTitle() -> String {
        return delegate.getTitle();
    }
    
    func getColor() -> UIColor {
        return delegate.getColor();
    }
    
    func getIcon() -> UIImage {
        return delegate.getIcon();
    }
    
    func getType() -> MetricsType {
        return delegate.getType();
    }
    
    func getSelectedPoint() -> SelectedPoint? {
        return delegate.getSelectedPoint();
    }

    func getGraph(frame: CGRect) -> MetricGraph {
        return MetricGraphUtility.graphWithPoints(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), points: points, altPoints: altPoints, color: delegate.getColor());
    }
    
    func getSelectedValue(tab: Int) -> String {
        return delegate.getSelectedValue(tab);
    }
    
    func getSelectedUnit(tab: Int) -> String {
        return delegate.getSelectedUnit(tab);
    }
    
    func getSelectedClass(tab: Int) -> String {
        return delegate.getSelectedClass(tab);
    }
    
    func colorFromClass(className: String, tab: Int) -> UIColor {
        return delegate.colorFromClass(className, tab: tab);
    }
    
    func getBlankStateImage() -> UIImage {
        return delegate.getBlankStateImage();
    }
    
    func getBlankStateText() -> String {
        return delegate.getBlankStateText();
    }
    
    func shouldShowRegions() -> Bool {
        return delegate.shouldShowRegions();
    }

    func initGraphView() {
        let a = NSDate().timeIntervalSince1970
        graph = getGraph(graphContainer.frame);
        let b = NSDate().timeIntervalSince1970 - a;
        if (graph.points.count > 0) {
            self.graphContainer.addSubview(graph);
        } else {
            blankState = true;
            let image = delegate.getBlankStateImage();
            let height = image.size.height;
            let width = image.size.width;
            let newHeight = (height / width) * blankStateImage.frame.size.width;
            blankStateImage.image = Utility.scaleImage(image, newSize: CGSize(width: blankStateImage.frame.size.width, height: newHeight));
            blankStateTitle.text = "Welcome!";
            blankStateText.text = getBlankStateText();
            blankStateText.frame.size.height = Utility.heightForTextView(UIScreen.mainScreen().bounds.width - blankStateText.frame.origin.x, text: getBlankStateText(), fontSize: blankStateText.font.pointSize, margin: 0);
            blankStateText.sizeToFit();
            if delegate.getType() == MetricsType.DailySummary {
                secondBlankStateButton.addTarget(self, action: "findStationButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
                blankStateButton.setTitle("Connect a Device", forState: UIControlState.Normal);
                secondBlankStateButton.setTitle("Find a Station", forState: UIControlState.Normal);
                blankStateButton.addTarget(self, action: "connectDeviceButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
                orLabel.hidden = false;
                secondBlankStateButton.hidden = false;
            } else {
                blankStateButton.addTarget(self, action: "findStationButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
            }
            blankStateContainer.hidden = false;
            graphContainer.hidden = true;
        }
        let c = NSDate().timeIntervalSince1970 - a;
        initRegions(true);
        let d = NSDate().timeIntervalSince1970 - a;
        setSelected(NSDate());
        let e = NSDate().timeIntervalSince1970 - a;
        let i = 0;
    }
    
    func initRegions(isPrimaryGraph: Bool) {
        let screenWidth = max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        let screenHeight = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        let baseGraph = isPrimaryGraph ? graph : secondaryGraph;
        if (delegate.getType() == MetricsType.DailySummary && baseGraph.points.count > 0) {
            let lineY = baseGraph.getScreenPoint(0, yPoint: 100).y;
            let view = UIView(frame: CGRect(x: 0, y: lineY, width: screenWidth, height: 2));
            view.backgroundColor = Utility.colorFromHexString("#EEEEEE");
            
            self.graphContainer.insertSubview(view, belowSubview: baseGraph);
        } else if (baseGraph.points.count > 0 && delegate.shouldShowRegions()) {
            if regions.count > 0 {
                for region in regions {
                    region.removeFromSuperview();
                }
            }
            let tab = 1;
            let labelMinHeight:CGFloat = 20;
            var lastVisibleY:CGFloat = CGFloat.max;
            
            let ranges = delegate.getRanges(tab);
            var i = 0;
            
            for range in ranges {
                let lowerBound = baseGraph.getScreenPoint(0, yPoint: CGFloat(range.lowerBound));
                let upperBound = baseGraph.getScreenPoint(0, yPoint: CGFloat(range.upperBound));
                if (upperBound.y >= 0 || lowerBound.y < graphContainer.frame.size.height) {
                    lastVisibleY = lowerBound.y;
                    let view = UIView(frame: CGRect(x: 0, y: upperBound.y + graph.graph.plotAreaFrame.paddingTop, width: screenWidth, height: lowerBound.y - upperBound.y));
                    var labelHeight = view.frame.size.height;
                    var labelY:CGFloat = 0;
                    if lowerBound.y > graphContainer.frame.size.height {
                        labelHeight = graphContainer.frame.size.height - upperBound.y - 20;
                    } else if upperBound.y < 0 {
                        labelHeight = lowerBound.y;
                        labelY = view.frame.size.height - labelHeight;
                    }
                    if labelHeight >= labelMinHeight || (lowerBound.y < graphContainer.frame.size.height && upperBound.y > 0) {
                        let label = UILabel(frame: CGRect(x: 0, y: labelY, width: view.frame.size.width - 10, height: labelHeight));
                        label.text = range.label;
                        label.textAlignment = NSTextAlignment.Right;
                        label.backgroundColor = UIColor.clearColor();
                        if (i % 2 == 0) {
                            label.textColor = Utility.colorFromHexString("#EEEEEE");
                            view.backgroundColor = UIColor.whiteColor();
                        } else {
                            label.textColor = UIColor.whiteColor();
                            view.backgroundColor = Utility.colorFromHexString("#EEEEEE");
                        }
                        view.addSubview(label);
                    }
                    regions.append(view);
                    self.graphContainer.insertSubview(view, belowSubview: baseGraph);
                    i++;
                    lastVisibleY = lowerBound.y;
                }
            }
        }
    }
    
    func getRanges(tab:Int) -> [MetricGauge.Range] {
        return delegate.getRanges(tab);
    }
    
    func setSelected(date: NSDate) {
        delegate.setSelected(date);
        if (!initializing) {
            setDetailsCardPoint();
        }
        initializing = false;
    }
    
    func getCopyImage(tab: Int) -> UIImage {
        return delegate.getCopyImage(tab);
    }
    
    func initHeader() {
        icon.image = getIcon();
        title.text = getTitle();
        headerView.backgroundColor = getColor();
        //i'd rather this logic be in the view controller but the recognizers weren't playing nicely
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "cardClicked:");
        let swipe = UISwipeGestureRecognizer(target: self, action: "cardClicked:");
        swipe.direction = UISwipeGestureRecognizerDirection.Left;
        let drag = UIPanGestureRecognizer(target: self, action: "cardDragged:");
        headerView.addGestureRecognizer(tapRecognizer);
        headerView.addGestureRecognizer(swipe);
        headerView.addGestureRecognizer(drag);
    }

    func initFrame(frame: CGRect) {
        let triangle = TriangleView(frame: CGRect(x: 0, y: 0, width: triangleView.frame.size.width, height: triangleView.frame.size.height));
        triangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2));
        triangleView.addSubview(triangle);
    }
    
    @IBAction func toggleClicked(sender: AnyObject) {
        graph.hidden = toggleOn;
        secondaryGraph.hidden = !toggleOn;
        if delegate.getType() == MetricsType.Weight {
            (delegate as! WeightMetricDelegate).togglePanel(toggleOn);
            let detailsCard = (Utility.getViewController(self) as! MetricsViewController).detailsCard;
            if toggleOn {
                title.text = "Body Fat%";
                toggleButton.setTitle("Switch to Weight", forState: UIControlState.Normal);
            } else {
                title.text = delegate.getTitle();
                toggleButton.setTitle("Switch to Body Fat%", forState: UIControlState.Normal);
            }
            if (Utility.getViewController(self) as! MetricsViewController).detailsOpen {
                detailsCard.thirdPanelClicked(self);
            } else {
                detailsCard.thirdPanelSelected = true;
            }
            detailsCard.updateCopyImage(detailsCard.getCurrentTab());
            setDetailsCardPoint();
            (Utility.getViewController(self) as! MetricsViewController).setDetailsHeader();
            initRegions(!toggleOn);
        }
        toggleOn = !toggleOn;
    }

    func cardDragged(sender: AnyObject) {
        let parent = (Utility.getViewController(self) as! MetricsViewController);
        let drag = (sender as! UIPanGestureRecognizer);
        if (drag.state == UIGestureRecognizerState.Ended) {
            parent.doneDragging(position);
        } else if (sender.state != UIGestureRecognizerState.Began) {
            parent.cardDragged(position, translation: drag.translationInView(parent.view));
        }
        sender.setTranslation(CGPointZero, inView: parent.view);
    }
    
    func cardClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).cardClickedAtIndex(position);
    }

    func setDetailsCardPoint() {
        (Utility.getViewController(self) as! MetricsViewController).setDetailsCardPoint();
    }

    func connectDeviceButtonClicked(sender: AnyObject) {
        Flurry.logEvent("ConnectDevice_Pressed");
        let devicesController = (Utility.getViewController(self) as! MetricsViewController);
        devicesController.prepareForPortraitOrientation();
        devicesController.navigationController!.pushViewController(ConnectDeviceViewController(nibName: "ConnectDeviceView", bundle: nil), animated: true);
    }
    
    func findStationButtonClicked(sender: AnyObject) {
        Flurry.logEvent("FindStation_Pressed");
        let metricViewController = (Utility.getViewController(self) as! MetricsViewController);
        metricViewController.prepareForPortraitOrientation();
        metricViewController.navigationController!.pushViewController(FindStationViewController(nibName: "FindStationView", bundle: nil), animated: true);
    }

    func containsPoint(frame: CGRect, point: CGPoint) -> Bool {
        let translatedPoint = CGPoint(x: point.x, y: point.y - headerView.frame.size.height);
        return (translatedPoint.x >= frame.origin.x) && (translatedPoint.x <= frame.size.width + frame.origin.x) && (translatedPoint.y >= frame.origin.y) && (translatedPoint.y <= frame.origin.y + frame.size.height);
    }
}