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
    @IBOutlet weak var gaugeContainer: UIView!
    @IBOutlet weak var copyImage: UIImageView!
    @IBOutlet weak var secondPanelHeader: UILabel!
    @IBOutlet weak var thirdPanelHeader: UILabel!

    var delegate: MetricDelegate!;
    
    var triangleIndicator: TriangleView!;
    
    var gauge: MetricGauge!;
    
    var meter: PointsMeter!;
    
    let triangleHeight:CGFloat = 20;
    
    var thirdPanelSelected = true;
    
    var blankState = false;
    
    class func instanceFromNib(card: MetricCard) -> MetricDetailCard {
        var view = UINib(nibName: "MetricDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricDetailCard;
        if (card.getSelectedPoint() != nil) {
            view.setData(card.getSelectedPoint()!);
            view.setup(card.delegate);
        } else {
            view.blankState = true;
//            view.animateBounceOut();
        }
        return view;
    }

    func setup(delegate: MetricDelegate) {
        self.delegate = delegate;
        let color = delegate.getColor();
        firstPanelValue.textColor = color;
        secondPanelValue.textColor = color;
        thirdPanelValue.textColor = color;
        
        let tab = thirdPanelSelected ? 1 : 0;
        var value: Int;
        if (delegate.getType() == MetricsType.DailySummary) {
            if (gauge != nil && gauge.superview != nil) {
                gauge.removeFromSuperview();
            }
            meter = PointsMeter.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height));
            let dateString = Constants.dateFormatter.stringFromDate(Constants.displayDateFormatter.dateFromString(delegate.getSelectedPoint()!.date)!);
            if (SessionController.Instance.activities[dateString] != nil) {
                meter.setActivities(SessionController.Instance.activities[dateString]!);
            } else {
                meter.setActivities((0, []));
            }
            gaugeContainer.addSubview(meter);
            meter.drawArc(false);
            meter.setDarkText();
            let tap = UITapGestureRecognizer(target: self, action: "gotoDailySummary:");
            meter.addGestureRecognizer(tap);
        } else if (delegate.getRanges(tab).count > 0) {
            if (meter != nil && meter.superview != nil) {
                meter.removeFromSuperview();
            }
            gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: tab);
            gaugeContainer.addSubview(gauge);
        }
        triangleIndicator = TriangleView(frame: CGRect(x: thirdPanel.frame.origin.x + thirdPanel.frame.size.width / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight));
        triangleIndicator.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI));
        addSubview(triangleIndicator);
        
        if (delegate.getType() == MetricsType.BloodPressure || delegate.getType() == MetricsType.Weight) {
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
    
    func animateBounceIn(destination: CGFloat) {
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
    
    func animateBounceOut() {
        let height = UIScreen.mainScreen().bounds.height;
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
            self.frame.origin.y = height;
            }, completion: { complete in
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                    self.frame.origin.y = height - 10;
                    }, completion: { complete in
                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                            self.frame.origin.y = height;
                            }, completion: { complete in
                                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                                    self.frame.origin.y = height - 4;
                                    }, completion: { complete in
                                        UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
                                            self.frame.origin.y = height;
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
            if (gauge.superview != nil) {
                let tab = 0;
                gauge.removeFromSuperview();
                gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: tab);
                gaugeContainer.addSubview(gauge);
            }
        }
        thirdPanelSelected = false;
    }
    
    func thirdPanelClicked(sender: AnyObject) {
        (Utility.getViewController(self) as! MetricsViewController).openDetailsIfClosed();
        if (!thirdPanelSelected) {
            triangleIndicator.frame = CGRect(x: thirdPanel.frame.origin.x + thirdPanel.frame.size.width / 2 - triangleHeight / 2, y: thirdPanel.frame.size.height - 2, width: triangleHeight, height: triangleHeight);
            if (gauge.superview != nil) {
                let value = thirdPanelValue.text?.toInt() != nil ? thirdPanelValue.text!.toInt()! : 0;
                gauge.removeFromSuperview();
                let tab = 1;
                gauge = MetricGauge.create(CGRect(x: 0, y: 0, width: gaugeContainer.frame.size.width, height: gaugeContainer.frame.size.height), delegate: delegate, tab: 1);
                gaugeContainer.addSubview(gauge);
            }
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
    
    func gotoDailySummary(sender: AnyObject) {
        Flurry.logEvent("Summary_Pressed");
        var summaryController = DailySummaryViewController(nibName: "DailySummaryView", bundle: nil);
        let dateString = Constants.dateFormatter.stringFromDate(Constants.displayDateFormatter.dateFromString(delegate.getSelectedPoint()!.date)!);
        summaryController.dateString = dateString;
        Utility.getViewController(self)!.navigationController!.pushViewController(summaryController, animated: true);
    }
}