import Foundation

class MetricCard: UIView, MetricDelegate {
    
    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var triangleView: UIView!
    @IBOutlet weak var blankStateContainer: UIView!
    @IBOutlet weak var blankStateImage: UIImageView!
    @IBOutlet weak var blankStateText: UILabel!
    @IBOutlet weak var blankStateButton: UIButton!
    @IBOutlet weak var secondBlankStateButton: UIButton!
    @IBOutlet weak var secondBlankStateImage: UIImageView!
    @IBOutlet weak var firstBlankContainer: UIView!
    @IBOutlet weak var secondBlankContainer: UIView!

    var graph, secondaryGraph: MetricGraph!;
    
    var delegate: MetricDelegate!;
    
    var position:Int!;
    
    var selectedPoint: SelectedPoint!;
    
    var selectedCheckin: HigiCheckin!;
    
    var initializing = true, toggleOn = true, blankState = false;
    
    var regions: [UIView] = [];
    
    var points: [GraphPoint] = [], altPoints: [GraphPoint] = [];
    
    class func instanceFromNib(delegate: MetricDelegate, frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint]) -> MetricCard {
        let nib = UINib(nibName: "MetricCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricCard;
        nib.setup(delegate, frame: frame, points: points, altPoints: altPoints);
        return nib;
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
        graph = getGraph(graphContainer.frame);
        if (graph.points.count > 0) {
            self.graphContainer.addSubview(graph);
        } else {
            layoutBlankStateView();
        }
        initRegions(true);
        setSelected(NSDate());
    }
    
    func layoutBlankStateView() {
        blankState = true;

        let image = blankStateImage.image!;
        let height = image.size.height;
        let width = image.size.width;
        let newHeight = (height / width) * blankStateImage.frame.size.width;
        blankStateImage.image = Utility.scaleImage(image, newSize: CGSize(width: blankStateImage.frame.size.width, height: newHeight));
        blankStateText.text = getBlankStateText();
        blankStateButton.addTarget(self, action: "findStationButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
        if delegate.getType() == MetricsType.DailySummary {
            let image = secondBlankStateImage.image!;
            let height = image.size.height;
            let width = image.size.width;
            let newHeight = (height / width) * blankStateImage.frame.size.width;
            secondBlankStateImage.image = Utility.scaleImage(image, newSize: CGSize(width: blankStateImage.frame.size.width, height: newHeight));
            secondBlankStateButton.addTarget(self, action: "connectDeviceButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
            secondBlankStateButton.hidden = false;
            secondBlankStateImage.hidden = false;
        } else {
            firstBlankContainer.frame.size.width = UIScreen.mainScreen().bounds.size.width - firstBlankContainer.frame.origin.x * 2;
//            secondBlankContainer
        }
        blankStateContainer.hidden = false;
        graphContainer.hidden = true;
    }
    
    func initRegions(isPrimaryGraph: Bool) {
        let screenWidth = max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        let baseGraph = isPrimaryGraph ? graph : secondaryGraph;
        if (delegate.getType() == MetricsType.DailySummary && baseGraph.points.count > 0) {
            var frame = graphContainer.frame;
            let lineY = baseGraph.getScreenPoint(0, yPoint: 100).y - frame.origin.y + 20;
            
            let path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, 0, lineY);
            let screenWidth = max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
            CGPathAddLineToPoint(path, nil, screenWidth, lineY);
            
            let shapeLayer = CAShapeLayer();
            shapeLayer.lineWidth = 1;
            shapeLayer.lineDashPattern = [NSNumber(integer: 10), NSNumber(integer: 5)];
            shapeLayer.fillColor = UIColor.clearColor().CGColor;
            shapeLayer.strokeColor = Utility.colorFromHexString("#eeeeee").CGColor;
            shapeLayer.frame = graphContainer.frame;
            shapeLayer.position = graphContainer.center;
            shapeLayer.path = path;
 
            graphContainer.layer.insertSublayer(shapeLayer, atIndex: 0);
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
                    let region = UIView(frame: CGRect(x: 0, y: upperBound.y + graph.graph.plotAreaFrame.paddingTop, width: screenWidth, height: lowerBound.y - upperBound.y));
                    var labelHeight = region.frame.size.height;
                    var labelY:CGFloat = 0;
                    if lowerBound.y > graphContainer.frame.size.height {
                        labelHeight = graphContainer.frame.size.height - upperBound.y - 20;
                    } else if upperBound.y < 0 {
                        labelHeight = lowerBound.y;
                        labelY = region.frame.size.height - labelHeight;
                    }
                    if labelHeight >= labelMinHeight || (lowerBound.y < graphContainer.frame.size.height && upperBound.y > 0) {
                        let label = UILabel(frame: CGRect(x: 0, y: labelY, width: region.frame.size.width - 10, height: labelHeight));
                        label.text = range.label;
                        label.textAlignment = NSTextAlignment.Right;
                        label.backgroundColor = UIColor.clearColor();
                        if (i % 2 == 0) {
                            label.textColor = Utility.colorFromHexString("#EEEEEE");
                            region.backgroundColor = UIColor.whiteColor();
                        } else {
                            label.textColor = UIColor.whiteColor();
                            region.backgroundColor = Utility.colorFromHexString("#EEEEEE");
                        }
                        region.addSubview(label);
                    }
                    regions.append(region);
                    self.graphContainer.insertSubview(region, belowSubview: baseGraph);
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
    
    override func layoutSubviews() {
        super.layoutSubviews();
        if blankState && delegate.getType() != MetricsType.DailySummary {
            var imageFrame = blankStateImage.frame;
            var buttonFrame = blankStateButton.frame;
            
            let screenWidth = UIScreen.mainScreen().bounds.size.width;
//            blankStateButton.center.x = screenWidth / 2;
//            blankStateImage.center.x = screenWidth / 2;

            blankStateButton.frame.origin.x = (screenWidth - blankStateButton.frame.size.width) / 2;
            blankStateImage.frame.origin.x = (screenWidth - blankStateImage.frame.size.width) / 2;
        }
    }
}