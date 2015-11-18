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
    
    var graph, secondaryGraph: MetricGraph!;
    
    var delegate: MetricDelegate!;
    
    var position:Int!;
    
    var selectedPoint: SelectedPoint!;
    
    var selectedCheckin: HigiCheckin!;
    
    var initializing = true, toggleOn = true, blankState = false;
    
    var regions: [UIView] = [];
    
    var points: [GraphPoint] = [], altPoints: [GraphPoint] = [];
    
    var kioskButton, deviceButton: UIButton!;
    
    class func instanceFromNib(delegate: MetricDelegate, frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint]) -> MetricCard {
        let nib = UINib(nibName: "MetricCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricCard;
        nib.setup(delegate, frame: frame, points: points, altPoints: altPoints);
        return nib;
    }

    func setup(delegate: MetricDelegate, frame: CGRect, points: [GraphPoint], altPoints:[GraphPoint]) {
        self.delegate = delegate;
        self.points = points;
        self.altPoints = altPoints;

        let bgView = UIView(frame: CGRect(x: 0, y: headerView.frame.size.height, width: UIScreen.mainScreen().bounds.size.height, height: UIScreen.mainScreen().bounds.size.width - headerView.frame.size.height))
        bgView.backgroundColor = UIColor.whiteColor();
        insertSubview(bgView, belowSubview: cardContainer);
        
        initFrame(frame);
        initGraphView();
        initHeader();
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if blankState {
            if kioskButton != nil && containsPoint(kioskButton.frame, point: point) {
                return kioskButton;
            } else if deviceButton != nil && containsPoint(deviceButton.frame, point: point) {
                return deviceButton;
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
    
    func getSecondaryColor() -> UIColor? {
        return delegate.getSecondaryColor();
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
        return MetricGraphUtility.graphWithPoints(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), points: points, altPoints: altPoints, color: delegate.getColor(), secondaryColor: delegate.getSecondaryColor());
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
            blankState = true;
            layoutBlankStateView();
        }
        initRegions(true);
        setSelected(NSDate());
    }
    
    func layoutBlankStateView() {
        let messageMarginX:CGFloat = 34, messageMarginY:CGFloat = 8, messageHeight: CGFloat = 90, imageHeight:CGFloat = 75, imageWidth:CGFloat = 150, imageMargin:CGFloat = 0, buttonWidth:CGFloat = 150, buttonHeight:CGFloat = 40, buttonMargin:CGFloat = 8, screenWidth = max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height), screenHeight = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        
        let container = UIView(frame: CGRect(x: 0, y: headerView.frame.size.height - 1, width: screenWidth, height: screenHeight - headerView.frame.size.height));
        container.backgroundColor = Utility.colorFromHexString("#EFEFEF");
        
        let message = UILabel(frame: CGRect(x: messageMarginX, y: messageMarginY, width: screenWidth - messageMarginX * 2, height: messageHeight));
        message.text = getBlankStateText();
        message.textColor = Utility.colorFromHexString("#444444");
        message.font = UIFont.systemFontOfSize(14);
        message.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        message.numberOfLines = 0;
        
        let kioskImage = UIImageView(frame: CGRect(x: (screenWidth / 2 - imageWidth) / 2, y: messageMarginY + messageHeight + imageMargin, width: imageWidth, height: imageHeight));
        var image = UIImage(named: "higistation")!;
        var height = image.size.height;
        var width = image.size.width;
        var newHeight = (height / width) * kioskImage.frame.size.width;
        kioskImage.image = Utility.scaleImage(image, newSize: CGSize(width: kioskImage.frame.size.width, height: newHeight));
        kioskImage.frame.size.height = newHeight;
        
        kioskButton = UIButton(frame: CGRect(x: (screenWidth / 2 - buttonWidth) / 2, y: kioskImage.frame.origin.y + kioskImage.frame.size.height + buttonMargin, width: buttonWidth, height: buttonHeight));
        kioskButton.setTitle(NSLocalizedString("METRICS_CARD_VIEW_FIND_STATION_BUTTON_TITLE", comment: "Title to display on button to find a higi Station."), forState: UIControlState.Normal);
        kioskButton.addTarget(self, action: "findStationButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
        kioskButton.backgroundColor = Utility.colorFromHexString(Constants.higiGreen);
        kioskButton.layer.cornerRadius = 4;
        kioskButton.titleLabel?.font = UIFont.systemFontOfSize(14);
        
        let deviceImage = UIImageView(frame: CGRect(x: ((screenWidth * 3 / 2) - imageWidth) / 2, y: messageMarginY + messageHeight + imageMargin, width: imageWidth, height: imageHeight));
        image = UIImage(named: "fitnessband")!;
        height = image.size.height;
        width = image.size.width;
        newHeight = (image.size.height / image.size.width) * deviceImage.frame.size.width;
        deviceImage.image = Utility.scaleImage(image, newSize: CGSize(width: deviceImage.frame.size.width, height: newHeight));
        deviceImage.frame.size.height = newHeight;
        deviceImage.frame.origin.y = kioskImage.frame.origin.y + ((kioskImage.frame.size.height - newHeight) / 2);
        
        deviceButton = UIButton(frame: CGRect(x: ((screenWidth * 3 / 2) - buttonWidth) / 2, y: kioskImage.frame.origin.y + kioskImage.frame.size.height + buttonMargin, width: buttonWidth, height: buttonHeight));
        let deviceButtonTitle: String
        if HealthKitManager.isHealthDataAvailable() {
            deviceButtonTitle = NSLocalizedString("METRICS_CARD_VIEW_CONNECT_DEVICE_BRANDED_BUTTON_TITLE", comment: "Title to display on button to connect a branded activity device.")            
        } else {
            deviceButtonTitle = NSLocalizedString("METRICS_CARD_VIEW_CONNECT_DEVICE_BUTTON_TITLE", comment: "Title to display on button to connect a device.")
        }
        deviceButton.setTitle(deviceButtonTitle, forState: UIControlState.Normal);
        deviceButton.addTarget(self, action: "connectDeviceButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside);
        deviceButton.backgroundColor = Utility.colorFromHexString(Constants.higiGreen);
        deviceButton.layer.cornerRadius = 4;
        deviceButton.titleLabel?.font = UIFont.systemFontOfSize(14);

        container.addSubview(message);
        container.addSubview(kioskImage);
        container.addSubview(kioskButton);
        container.addSubview(deviceImage);
        container.addSubview(deviceButton);
        
        cardContainer.addSubview(container);
        graphContainer.hidden = true;
    }
    
    func initRegions(isPrimaryGraph: Bool) {
        let screenWidth = max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height);
        let baseGraph = isPrimaryGraph ? graph : secondaryGraph;
        if (delegate.getType() == MetricsType.DailySummary && baseGraph.points.count > 0) {
            let frame = graphContainer.frame;
            let lineY = baseGraph.getScreenPoint(0, yPoint: 100).y - frame.origin.y + 20;
            
            let path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, 0, lineY);
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
            
            let ranges = delegate.getRanges(tab);
            var i = 0;
            let graphHeight = graphContainer.frame.size.height;
            for range in ranges {
                var lowerBound = baseGraph.getScreenPoint(0, yPoint: CGFloat(range.lowerBound));
                var upperBound = baseGraph.getScreenPoint(0, yPoint: CGFloat(range.upperBound));
                //if graph points are above largest region
                if i == ranges.count - 1 && upperBound.y < 0 {
                    upperBound.y = -20;
                    lowerBound.y = graphContainer.frame.size.height + upperBound.y;
                } //if graph points are lower than lowest region
                else if i == 0 && lowerBound.y > 0 {
                    upperBound.y = graphHeight - upperBound.y;
                    lowerBound.y = graphHeight;
                }
                //if visible, add to screen
                if (upperBound.y >= 0 || lowerBound.y <= graphHeight) {
                    var y = upperBound.y + graph.graph.plotAreaFrame.paddingTop;
                    var height = lowerBound.y - upperBound.y;
                    if (upperBound.y + graph.graph.plotAreaFrame.paddingTop < 0) {
                        y = 0;
                        height = height + (upperBound.y + graph.graph.plotAreaFrame.paddingTop);
                    }
                    let region = UIView(frame: CGRect(x: 0, y: y, width: screenWidth, height: height));
                    var labelHeight = region.frame.size.height;
                    var labelY:CGFloat = 0;
                    if lowerBound.y > graphHeight {
                        labelHeight = graphHeight - upperBound.y - 20;
                    } else if upperBound.y < 0 {
                        labelHeight = lowerBound.y;
                        labelY = region.frame.size.height - labelHeight;
                    }
                    if labelHeight >= labelMinHeight || (lowerBound.y < graphHeight && upperBound.y > 0) {
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
        graphContainer.frame.size.height = frame.size.height - headerView.frame.size.height;
    }
    
    @IBAction func toggleClicked(sender: AnyObject) {
        graph.hidden = toggleOn;
        secondaryGraph.hidden = !toggleOn;
        if delegate.getType() == MetricsType.Weight {
            (delegate as! WeightMetricDelegate).togglePanel(toggleOn);
            let detailsCard = (Utility.getViewController(self) as! MetricsViewController).detailsCard;
            if toggleOn {
                title.text = NSLocalizedString("METRICS_CARD_VIEW_WEIGHT_BODY_FAT_TITLE", comment: "Title to display on weight metrics card displaying body fat.");
                toggleButton.setTitle(NSLocalizedString("METRICS_CARD_VIEW_WEIGHT_TOGGLE_BUTTON_WEIGHT_TITLE", comment: "Title to display on button which toggles weight metrics card from body fat to weight."), forState: UIControlState.Normal);
            } else {
                title.text = delegate.getTitle();
                toggleButton.setTitle(NSLocalizedString("METRICS_CARD_VIEW_WEIGHT_TOGGLE_BUTTON_BODY_FAT_TITLE", comment: "Title to display on button which toggles weight metrics card from weight to body fat."), forState: UIControlState.Normal);
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