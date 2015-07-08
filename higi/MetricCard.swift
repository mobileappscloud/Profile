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
    
    var graph, secondaryGraph: MetricGraph!;
    
    var viewFrame: CGRect!;
    
    var delegate: MetricDelegate!;
    
    var position:Int!;
    
    var selectedPoint: SelectedPoint!;
    
    var selectedCheckin: HigiCheckin!;
    
    var initializing = true, toggleOn = true;
    
    var regions: [UIView] = [];
    
    struct SelectedPoint {
        var date:String!
        
        var firstPanel, secondPanel: Panel!;
        
        struct Panel {
            var value, label, unit: String!;
            
            init(value: String, label: String, unit:String) {
                self.value = value;
                self.label = label;
                self.unit = unit;
            }
        }
        
        init(date: String, panelValue: String, panelLabel: String, panelUnit: String) {
            self.date = date;
            self.firstPanel = Panel(value: "", label: "", unit: "");
            self.secondPanel = Panel(value: panelValue, label: panelLabel, unit: panelUnit);
        }
        
        init(date: String, firstPanelValue: String, firstPanelLabel: String, firstPanelUnit: String, secondPanelValue: String, secondPanelLabel: String, secondPanelUnit: String) {
            self.date = date;
            self.firstPanel = Panel(value: firstPanelValue, label: firstPanelLabel, unit: firstPanelUnit);
            self.secondPanel = Panel(value: secondPanelValue, label: secondPanelLabel, unit: secondPanelUnit);
        }
    }
    
    class func instanceFromNib(delegate: MetricDelegate, frame: CGRect) -> MetricCard {
        let view = UINib(nibName: "MetricCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricCard;
        view.delegate = delegate;
        view.initFrame(frame);
        view.initGraphView();
        view.initRegions(true);
        view.initHeader();
        view.setSelected(NSDate());
        return view;
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if (point.y > 54 && point.y < (graphContainer.frame.origin.y + graphContainer.frame.size.height)) {
            if (!graph.hidden) {
                return graph;
            } else {
                return secondaryGraph;
            }
        } else {
            return super.hitTest(point, withEvent: event);
        }
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
    
    func getSelectedPoint() -> MetricCard.SelectedPoint? {
        return delegate.getSelectedPoint();
    }

    func getGraph(frame: CGRect) -> MetricGraph {
        return delegate.getGraph(frame);
    }
    
    func getSelectedValue(tab: Int) -> String {
        return getSelectedValue(tab);
    }
    
    func getSelectedUnit(tab: Int) -> String {
        return getSelectedUnit(tab);
    }
    
    func getBlankStateImage() -> UIImage {
        return delegate.getBlankStateImage();
    }
    
    func shouldShowRegions() -> Bool {
        return delegate.shouldShowRegions();
    }
    
    func initGraphView() {
        graph = getGraph(graphContainer.frame);
        if (graph.points.count > 0) {
            self.graphContainer.addSubview(graph);
        } else {
            let image = UIImageView(frame: graphContainer.frame);
            image.image = delegate.getBlankStateImage();
            self.graphContainer.addSubview(image);
        }
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
            let ranges = delegate.getRanges(tab);
            var i = 0;
            for range in ranges {
                let lowerBound = baseGraph.getScreenPoint(0, yPoint: CGFloat(range.lowerBound));
                let upperBound = baseGraph.getScreenPoint(0, yPoint: CGFloat(range.upperBound));
                if (upperBound.y >= 0 || lowerBound.y < graphContainer.frame.size.height) {
                    let view = UIView(frame: CGRect(x: 0, y: upperBound.y + graph.graph.plotAreaFrame.paddingTop, width: screenWidth, height: lowerBound.y - upperBound.y));
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 10, height: view.frame.size.height));
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
                    regions.append(view);
                    self.graphContainer.insertSubview(view, belowSubview: baseGraph);
                    i++;
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
            updateDetailsCard();
        }
        initializing = false;
    }
    
    func getCopyImage(tab: Int) -> UIImage? {
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
        self.frame = frame;
        viewFrame = frame;
        let triangle = TriangleView(frame: CGRect(x: 0, y: 0, width: triangleView.frame.size.width, height: triangleView.frame.size.height));
        triangle.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2));
        triangleView.addSubview(triangle);
    }
    
    func resizeFrameWithWidth(width: CGFloat) {
        viewFrame.size.width = width;
        
    }
    
    @IBAction func toggleClicked(sender: AnyObject) {
        graph.hidden = toggleOn;
        secondaryGraph.hidden = !toggleOn;
        if delegate.getType() == MetricsType.Weight {
            (delegate as! WeightMetricDelegate).togglePanel(toggleOn);
            updateDetailsCard();
            (Utility.getViewController(self) as! MetricsViewController).setDetailsHeader();
            initRegions(!toggleOn);
        }
        if toggleOn {
            title.text = "Body Fat%";
            toggleButton.setTitle("Switch to Weight", forState: UIControlState.Normal);
        } else {
            title.text = delegate.getTitle();
            toggleButton.setTitle("Switch to Body Fat%", forState: UIControlState.Normal);
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

    func updateDetailsCard() {
        (Utility.getViewController(self) as! MetricsViewController).updateDetailCard();
    }
}