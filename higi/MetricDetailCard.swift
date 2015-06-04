import Foundation

class MetricDetailCard: UIView {
    @IBOutlet weak var firstPanel: UIView!
    @IBOutlet weak var firstPanelValue: UILabel!
    @IBOutlet weak var firstPanelLabel: UILabel!
    
    @IBOutlet weak var secondPanel: UIView!
    @IBOutlet weak var secondPanelValue: UILabel!
    @IBOutlet weak var secondPanelUnit: UILabel!
    @IBOutlet weak var secondPanelLabel: UILabel!
    
    @IBOutlet weak var thirdPanel: UIView!
    @IBOutlet weak var thirdPanelValue: UILabel!
    @IBOutlet weak var thirdPanelUnit: UILabel!
    @IBOutlet weak var thirdPanelLabel: UILabel!
    
    @IBOutlet weak var firstCenteredPanel: UIView!
    @IBOutlet weak var secondCenteredPanel: UIView!
    @IBOutlet weak var centeredValue: UILabel!
    @IBOutlet weak var centeredDate: UILabel!
    
    var color: UIColor!;
    
    class func instanceFromNib(selection: MetricCard.SelectedPoint, type: MetricsType) -> MetricDetailCard {
        var view = UINib(nibName: "MetricDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricDetailCard;
        view.initWithType(type);
        view.setData(selection);
        return view;
    }
    
    func initWithType(type: MetricsType) {
        color = Utility.colorFromMetricType(type);
        firstPanelValue.textColor = color;
        secondPanelValue.textColor = color;
        thirdPanelValue.textColor = color;
    }
    
    func animateBounce(destination: CGFloat) {
        self.frame.origin.y = UIScreen.mainScreen().bounds.height;
        UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseInOut, animations: {
            self.frame.origin.y = destination - 10;
            }, completion: { complete in
                UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                    self.frame.origin.y = destination;
                    }, completion: nil);
        });
    }
    
    func setData(selection: MetricCard.SelectedPoint) {
        firstPanelValue.text = selection.date;
        secondPanelValue.text = selection.firstPanel.value;
        secondPanelUnit.text = selection.firstPanel.unit;
        secondPanelLabel.text = selection.firstPanel.label;
        thirdPanelValue.text = selection.secondPanel.value;
        thirdPanelUnit.text = selection.secondPanel.unit;
        thirdPanelLabel.text = selection.secondPanel.label;
    }
}