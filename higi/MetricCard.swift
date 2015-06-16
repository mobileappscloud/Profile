import Foundation

class MetricCard: UIView, MetricDelegate {
    
    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var graph, secondaryGraph: MetricGraph!;
    
    var viewFrame: CGRect!;
    
    var delegate: MetricDelegate!;
    
    var position:Int!;
    
    var selectedPoint: SelectedPoint!;
    
    var selectedCheckin: HigiCheckin!;
    
    var initializing = true, toggleOn = true;
    
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
    
    func getSelectedPoint() -> MetricCard.SelectedPoint {
        return delegate.getSelectedPoint();
    }

    func getGraph(frame: CGRect) -> MetricGraph {
        return delegate.getGraph(frame);
    }
    
    func initGraphView() {
        graph = getGraph(graphContainer.frame);
        self.graphContainer.addSubview(graph);
    }

    func populate() {
        
    }
    
    func initRegions() {
        
    }
    
    func getRanges() -> [MetricGauge.Range] {
        return delegate.getRanges();
    }
    
    func setSelected(date: NSDate) {
        delegate.setSelected(date);
        if (!initializing) {
            updateDetailsCard();
        }
        initializing = false;
    }
    
    func getCopyImage() -> UIImage? {
        return delegate.getCopyImage();
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
    }
    
    func resizeFrameWithWidth(width: CGFloat) {
        viewFrame.size.width = width;
    }
    
    @IBAction func toggleClicked(sender: AnyObject) {
        graph.hidden = toggleOn;
        secondaryGraph.hidden = !toggleOn;
        toggleOn = !toggleOn;
    }
    
    func cardDragged(sender: AnyObject) {
        let parent = (Utility.getViewController(self) as! MetricsViewController);
        let drag = (sender as! UIPanGestureRecognizer);
        if (drag.state == UIGestureRecognizerState.Ended) {
            parent.doneDragging(position);
        } else {
            let translation = drag.translationInView(parent.view);
            parent.cardDragged(position, translation: translation);
        }
    }
    
    func cardClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).cardClickedAtIndex(position);
    }

    func updateDetailsCard() {
        (Utility.getViewController(self) as! MetricsViewController).updateDetailCard();
    }
}