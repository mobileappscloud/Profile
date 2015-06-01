import Foundation

class MetricsGraphCard: UIView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var firstReadingValue: UILabel!
    @IBOutlet weak var firstReadingLabel: UILabel!
    @IBOutlet weak var firstReadingSubTitle: UILabel!
    @IBOutlet weak var secondReadingValue: UILabel!
    @IBOutlet weak var secondReadingLabel: UILabel!
    @IBOutlet weak var secondReadingSubTitle: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var singleSubtitle: UILabel!
    @IBOutlet weak var singleLabel: UILabel!
    @IBOutlet weak var singleValue: UILabel!
    
    var color: UIColor!;

    class func instanceFromNib(title: String, lastCheckin: HigiCheckin, type: MetricsType) -> MetricsGraphCard {
        let card = UINib(nibName: "MetricGraphCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricsGraphCard;
        card.initCard(title, type: type);
        card.setCheckinData(title, checkin: lastCheckin, type: type);
        return card;
    }
    
    class func instanceFromNib(title: String, activity: (NSDate, Int), type: MetricsType) -> MetricsGraphCard {
        let card = UINib(nibName: "MetricGraphCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricsGraphCard;
        card.initCard(title, type: type);
        card.setActivity(activity);
        return card;
    }
    
    func initCard(titleString: String, type: MetricsType) {
        color = Utility.colorFromMetricType(type);
        title.text = titleString;
        title.textColor = color;
    }
    
    func setCheckinData(titleString: String, checkin: HigiCheckin, type: MetricsType) {
        title.text = titleString;
        title.textColor = color;
        
        let formatter = NSDateFormatter(), dayFormatter = NSDateFormatter();
        formatter.dateFormat = "MMMM";
        dayFormatter.dateFormat = "dd";
        date.text = "\(formatter.stringFromDate(checkin.dateTime)) \(ChallengeUtility.getRankSuffix(dayFormatter.stringFromDate(checkin.dateTime)))";
        
        if (type == MetricsType.BloodPressure) {
            if let map = checkin.map {
                firstReadingValue.text = "\(Double(round(map * 10) / 10))";
            } else {
                firstReadingValue.text = "--";
            }
            firstReadingLabel.text = "mmHg";
            firstReadingSubTitle.text = "Mean Arterial Pressure";
            firstReadingValue.textColor = color;
            
            secondReadingValue.text = checkin.systolic != nil ? "\(Int(checkin.systolic!))/\(Int(checkin.diastolic!))" : "";
            secondReadingLabel.text = "mmHg";
            secondReadingSubTitle.text = "Blood Pressure";
            secondReadingValue.textColor = color;
        } else if (type == MetricsType.Weight) {
            firstReadingValue.text = checkin.weightLbs != nil ? "\(Int(checkin.weightLbs!))" : "";
            firstReadingLabel.text = "lbs";
            firstReadingSubTitle.text = "Weight";
            
            if let fatRatio = checkin.fatRatio {
                // dirty way round to 2 decimal places
                secondReadingValue.text = "\(Double(round(fatRatio * 100) / 100))%";
            } else {
                secondReadingValue.text = "--%";
            }
            secondReadingLabel.text = "";
            secondReadingSubTitle.text = "Body Fat";
        } else if (type == MetricsType.DailySummary) {
            firstReadingValue.hidden = true;
            firstReadingLabel.hidden = true;
            firstReadingSubTitle.hidden = true;
            
            secondReadingValue.hidden = true;
            secondReadingLabel.hidden = true;
            secondReadingSubTitle.hidden = true;
            
            singleValue.hidden = false;
            singleLabel.hidden = false;
            singleSubtitle.hidden = false;
            
            singleValue.text = checkin.pulseBpm != nil ? "\(Int(checkin.pulseBpm!))" : "";
            singleValue.textColor = color;
            singleLabel.text = "pts";
            singleSubtitle.text = "Activity Points";
        } else {
            firstReadingValue.hidden = true;
            firstReadingLabel.hidden = true;
            firstReadingSubTitle.hidden = true;
            
            secondReadingValue.hidden = true;
            secondReadingLabel.hidden = true;
            secondReadingSubTitle.hidden = true;
            
            singleValue.hidden = false;
            singleLabel.hidden = false;
            singleSubtitle.hidden = false;
            
            singleValue.text = checkin.pulseBpm != nil ? "\(Int(checkin.pulseBpm!))" : "";
            singleValue.textColor = color;
            singleLabel.text = "bpm";
            singleSubtitle.text = "Beats Per Minute";
        }
        
        firstReadingValue.textColor = color;
        secondReadingValue.textColor = color;
    }
    
    func setActivity(activity: (NSDate, Int)) {
        let activityDate = activity.0;
        let totalPoints = activity.1;
        let formatter = NSDateFormatter(), dayFormatter = NSDateFormatter();
        formatter.dateFormat = "MMMM";
        dayFormatter.dateFormat = "dd";
        date.text = "\(formatter.stringFromDate(activityDate)) \(ChallengeUtility.getRankSuffix(dayFormatter.stringFromDate(activityDate)))";

        firstReadingValue.hidden = true;
        firstReadingLabel.hidden = true;
        firstReadingSubTitle.hidden = true;
        
        secondReadingValue.hidden = true;
        secondReadingLabel.hidden = true;
        secondReadingSubTitle.hidden = true;
        
        singleValue.hidden = false;
        singleLabel.hidden = false;
        singleSubtitle.hidden = false;
        
        singleValue.text = "\(totalPoints)";
        singleValue.textColor = color;
        singleLabel.text = "pts";
        singleSubtitle.text = "Activity Points";
        
        firstReadingValue.textColor = color;
        secondReadingValue.textColor = color;
    }
    
    func graph(points: [GraphPoint], type: MetricsType) {
        let graph = MetricGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: points);
        graph.setupForDashboard(type);
        graph.userInteractionEnabled = false;
        graphView.addSubview(graph);
    }
}