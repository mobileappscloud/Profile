import Foundation

class MetricDetailCard: UIView {
    @IBOutlet weak var firstPanel: UIView!
    @IBOutlet weak var firstPanelValue: UILabel!
    @IBOutlet weak var secondPanel: UIView!
    @IBOutlet weak var secondPanelValue: UILabel!
    @IBOutlet weak var secondPanelUnit: UILabel!
    @IBOutlet weak var secondPanelLabel: UILabel!
    @IBOutlet weak var thirdPanel: UIView!
    @IBOutlet weak var thirdPanelValue: UILabel!
    @IBOutlet weak var thirdPanelUnit: UILabel!
    @IBOutlet weak var thirdPanelLabel: UILabel!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var copyScrollview: UIScrollView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var titleUnit: UILabel!
    @IBOutlet weak var checkinSource: UILabel!
    @IBOutlet weak var checkinLocation: UILabel!
    @IBOutlet weak var checkinAddress: UILabel!
    @IBOutlet weak var gaugeContainer: UIView!
    @IBOutlet weak var copyImage: UIImageView!
    @IBOutlet weak var secondPanelHeader: UILabel!
    @IBOutlet weak var thirdPanelHeader: UILabel!

    var delegate: MetricDelegate!;
    
    var triangleIndicator: TriangleView!;
    
    var gauge: MetricGauge!;
    
    let triangleHeight:CGFloat = 20;
    
    var thirdPanelSelected = true;
    
    class func instanceFromNib(selection: MetricCard.SelectedPoint, delegate: MetricDelegate) -> MetricDetailCard {
        var view = UINib(nibName: "MetricDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricDetailCard;
        view.setup(delegate, userValue: selection.secondPanel.value);
        view.setData(selection);
        view.initPointsMeter();
        return view;
    }
    
    func initPointsMeter() {
        let meterSize:CGFloat = 40;
        let pointsMeter = PointsMeter.create(CGRect(x: 8, y: (firstPanel.frame.size.height - meterSize) / 2, width: meterSize, height: meterSize));
        let tap = UITapGestureRecognizer(target: self, action: "gotoSummary:");
        pointsMeter.addGestureRecognizer(tap);
        if let (total, todaysActivities) = SessionController.Instance.activities[Constants.dateFormatter.stringFromDate(NSDate())] {
            pointsMeter.setActivities((total, todaysActivities));
            pointsMeter.drawArc(false);
        } else {
            pointsMeter.setActivities((0, []));
            pointsMeter.drawArc(false);
        }
        pointsMeter.setDarkText();
        firstPanel.addSubview(pointsMeter);
    }
    
    func setup(delegate: MetricDelegate, userValue: String) {
        self.delegate = delegate;
        let color = delegate.getColor();
        firstPanelValue.textColor = color;
        secondPanelValue.textColor = color;
        thirdPanelValue.textColor = color;
        
        let value = userValue.toInt() != nil ? userValue.toInt()! : 0;
        if (delegate.getRanges().count > 0) {
            gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, userValue: value);
            gaugeContainer.addSubview(gauge);
        }
        triangleIndicator = TriangleView(frame: CGRect(x: thirdPanel.frame.origin.x + thirdPanel.frame.size.width / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight));
        triangleIndicator.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI));
        addSubview(triangleIndicator);
        if (delegate.getType() == MetricsType.BloodPressure) {
            let secondPanelTap = UITapGestureRecognizer(target: self, action: "secondPanelClicked:");
            secondPanel.addGestureRecognizer(secondPanelTap);
            let thirdPanelTap = UITapGestureRecognizer(target: self, action: "thirdPanelClicked:");
            thirdPanel.addGestureRecognizer(thirdPanelTap);
        }
        if (delegate.getCopyImage() != nil) {
            copyScrollview.contentSize = copyImage.frame.size;
            copyImage.image = delegate.getCopyImage();
        }
    }
    
    func animateBounce(destination: CGFloat) {
        self.frame.origin.y = UIScreen.mainScreen().bounds.height;
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
            self.frame.origin.y = destination;
            }, completion: { complete in
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                    self.frame.origin.y = destination + 10;
                    }, completion: { complete in
                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                            self.frame.origin.y = destination;
                            }, completion: { complete in
                                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                                    self.frame.origin.y = destination + 4;
                                    }, completion: { complete in
                                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                                            self.frame.origin.y = destination;
                                            }, completion: nil);
                                });
                        });
                });
        });
    }
    
    func secondPanelClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).openDetailsIfClosed();
        if (thirdPanelSelected) {
            triangleIndicator.frame = CGRect(x: secondPanel.frame.origin.x + secondPanel.frame.size.width / 2 - triangleHeight / 2, y: secondPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
//            gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, userValue: value);
        }
        thirdPanelSelected = false;
    }
    
    func thirdPanelClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).openDetailsIfClosed();
        if (!thirdPanelSelected) {
            triangleIndicator.frame = CGRect(x: thirdPanel.frame.origin.x + thirdPanel.frame.size.width / 2 - triangleHeight / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
//            gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, userValue: value);
        }
        thirdPanelSelected = true;
    }
    
    func setData(selection: MetricCard.SelectedPoint) {
        firstPanelValue.text = selection.date;
        secondPanelValue.text = selection.firstPanel.value;
        secondPanelUnit.text = selection.firstPanel.unit;
        secondPanelLabel.text = selection.firstPanel.label;
        thirdPanelValue.text = selection.secondPanel.value;
        thirdPanelUnit.text = selection.secondPanel.unit;
        thirdPanelLabel.text = selection.secondPanel.label;
        
        secondPanelHeader.text = selection.firstPanel.label;
        thirdPanelHeader.text = selection.secondPanel.label;
    }
    
    func setPanelHeaders(isOpen: Bool) {
        secondPanelValue.hidden = isOpen;
        secondPanelUnit.hidden = isOpen;
        secondPanelLabel.hidden = isOpen;
        thirdPanelValue.hidden = isOpen;
        thirdPanelUnit.hidden = isOpen;
        thirdPanelLabel.hidden = isOpen;
        
        secondPanelHeader.hidden = !isOpen;
        thirdPanelHeader.hidden = !isOpen;
    }
    
    func gotoSummary(sender: AnyObject) {
        Flurry.logEvent("Summary_Pressed");
        var summaryController = DailySummaryViewController(nibName: "DailySummaryView", bundle: nil);
        Utility.getViewController(self)!.navigationController!.pushViewController(summaryController, animated: true);
    }
}