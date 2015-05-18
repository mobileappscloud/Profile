import Foundation

class BodyStatDetailCard: UIView {
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
    
    @IBOutlet weak var firstPulsePanel: UIView!
    @IBOutlet weak var secondPulsePanel: UIView!
    @IBOutlet weak var pulseValue: UILabel!
    @IBOutlet weak var pulseDate: UILabel!
    
    class func instanceFromNib(checkin: HigiCheckin, type: BodyStatsType) -> BodyStatDetailCard {
        var view = UINib(nibName: "BodyStatDetailCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BodyStatDetailCard;
        
        let color = Utility.colorFromBodyStatType(type);
        view.firstPanelValue.textColor = color;
        view.secondPanelValue.textColor = color;
        view.thirdPanelValue.textColor = color;
        
        view = initCheckinData(view, checkin: checkin, type: type);
        
        return view;
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
    
    class func initCheckinData(view: BodyStatDetailCard, checkin: HigiCheckin, type: BodyStatsType) -> BodyStatDetailCard {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "MM/dd/yyyy";
        view.firstPanelValue.text = "\(formatter.stringFromDate(checkin.dateTime))";
        if (type == BodyStatsType.BloodPressure) {
            view.secondPanelValue.text = checkin.systolic != nil ? "\(checkin.systolic!)/\(checkin.diastolic!)" : "";
            view.secondPanelUnit.text = "mmHg";
            view.secondPanelLabel.text = "Blood Pressure";
            view.thirdPanelValue.text = checkin.map != nil ? "\(Int(checkin.map!))" : "";
            view.thirdPanelUnit.text = "mmHg";
            view.thirdPanelLabel.text = "Mean Arterial Pressure";
        } else if (type == BodyStatsType.Weight) {
            view.secondPanelValue.text = checkin.weightLbs != nil ? "\(Int(checkin.weightLbs!))" : "";
            view.secondPanelUnit.text = "lbs";
            view.secondPanelLabel.text = "Weight";
            view.thirdPanelValue.text = checkin.bmi != nil ? "\(Int(checkin.bmi!))" : "";
            view.thirdPanelUnit.text = "";
            view.thirdPanelLabel.text = "Body Mass Index";
        } else {
            view.firstPanel.hidden = true;
            view.secondPanel.hidden = true;
            view.thirdPanel.hidden = true;
            
            view.firstPulsePanel.hidden = false;
            view.secondPulsePanel.hidden = false;
            
            view.secondPanelValue.text = "\(checkin.pulseBpm!)";
            view.secondPanelUnit.text = "mmHg";
            view.secondPanelLabel.text = "Beats Per Minute";
            let color = Utility.colorFromBodyStatType(type);
            view.pulseDate.textColor = color;
            view.pulseValue.textColor = color;
        }
        return view;
    }
    
    func setCheckin(checkin: HigiCheckin, type: BodyStatsType) {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "MM/dd/yyyy";
        firstPanelValue.text = "\(formatter.stringFromDate(checkin.dateTime))";
        if (type == BodyStatsType.BloodPressure) {
            secondPanelValue.text = "\(checkin.systolic!)/\(checkin.diastolic!)";
            secondPanelUnit.text = "mmHg";
            secondPanelLabel.text = "Blood Pressure";
            thirdPanelValue.text = "\(Int(checkin.map!))";
            thirdPanelUnit.text = "mmHg";
            thirdPanelLabel.text = "Mean Arterial Pressure";
        } else if (type == BodyStatsType.Weight) {
            secondPanelValue.text = "\(Int(checkin.weightLbs!))";
            secondPanelUnit.text = "lbs";
            secondPanelLabel.text = "Weight";
            thirdPanelValue.text = "\(Int(checkin.bmi!))";
            thirdPanelUnit.text = "";
            thirdPanelLabel.text = "Body Mass Index";
        } else {
            firstPanel.hidden = true;
            secondPanel.hidden = true;
            thirdPanel.hidden = true;
            
            firstPulsePanel.hidden = false;
            secondPulsePanel.hidden = false;
            
            secondPanelValue.text = "\(checkin.pulseBpm!)";
            secondPanelUnit.text = "mmHg";
            secondPanelLabel.text = "Beats Per Minute";
            let color = Utility.colorFromBodyStatType(type);
            pulseDate.textColor = color;
            pulseValue.textColor = color;
        }
    }
    
}