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
    
    class func instanceFromNib(checkin: HigiCheckin, type: MetricsType) -> MetricDetailCard {
        var view = UINib(nibName: "MetricDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricDetailCard;
        view.initWithType(type);
        view.setCheckinData(checkin, type: type);
        return view;
    }
    
    class func instanceFromNib(activity: (Double, Int), type: MetricsType) -> MetricDetailCard {
        var view = UINib(nibName: "MetricDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricDetailCard;
        view.initWithType(type);
        view.setActivity(activity, type: type);
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
    
    func setCheckinData(checkin: HigiCheckin, type: MetricsType) {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "MM/dd/yyyy";
        firstPanelValue.text = "\(formatter.stringFromDate(checkin.dateTime))";
        if (type == MetricsType.BloodPressure) {
            secondPanelValue.text = checkin.systolic != nil ? "\(checkin.systolic!)/\(checkin.diastolic!)" : "";
            secondPanelUnit.text = "mmHg";
            secondPanelLabel.text = "Blood Pressure";
            thirdPanelValue.text = checkin.map != nil ? "\(Int(checkin.map!))" : "";
            thirdPanelUnit.text = "mmHg";
            thirdPanelLabel.text = "Mean Arterial Pressure";
        } else if (type == MetricsType.Weight) {
            secondPanelValue.text = checkin.weightLbs != nil ? "\(Int(checkin.weightLbs!))" : "";
            secondPanelUnit.text = "lbs";
            secondPanelLabel.text = "Weight";
            thirdPanelValue.text = checkin.bmi != nil ? "\(Int(checkin.bmi!))" : "";
            thirdPanelUnit.text = "";
            thirdPanelLabel.text = "Body Mass Index";
        } else {
            firstPanel.hidden = true;
            secondPanel.hidden = true;
            thirdPanel.hidden = true;
            firstCenteredPanel.hidden = false;
            secondCenteredPanel.hidden = false;
            centeredDate.text = "\(formatter.stringFromDate(checkin.dateTime))";
            if (checkin.pulseBpm != nil) {
                centeredValue.text = checkin.pulseBpm != nil ? "\(checkin.pulseBpm!)" : "";
            } else {
                centeredValue.text = "";
            }
            centeredDate.textColor = color;
            centeredValue.textColor = color;
            secondPanelUnit.text = "mmHg";
            secondPanelLabel.text = "Beats Per Minute";
        }
    }
    
    func setActivity(activity: (Double, Int), type: MetricsType) {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "MM/dd/yyyy";
        let date = activity.0;
        let total = activity.1;
        firstPanel.hidden = true;
        secondPanel.hidden = true;
        thirdPanel.hidden = true;
        
        firstCenteredPanel.hidden = false;
        secondCenteredPanel.hidden = false;
        
        centeredDate.text = "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: date)))";
        centeredValue.text = "\(total)";
        centeredDate.textColor = color;
        centeredValue.textColor = color;
        
        secondPanelUnit.text = "pts";
        secondPanelLabel.text = "Activity Points";
    }
    
}