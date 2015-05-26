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
        let color = Utility.colorFromMetricType(type);
        card.title.text = title;
        card.title.textColor = color;
        
        let formatter = NSDateFormatter(), dayFormatter = NSDateFormatter();
        formatter.dateFormat = "MMMM";
        dayFormatter.dateFormat = "dd";
        card.date.text = "\(formatter.stringFromDate(lastCheckin.dateTime)) \(ChallengeUtility.getRankSuffix(dayFormatter.stringFromDate(lastCheckin.dateTime)))";
        
        if (type == MetricsType.BloodPressure) {
            if let map = lastCheckin.map {
                card.firstReadingValue.text = "\(Double(round(map * 10) / 10))";
            } else {
                card.firstReadingValue.text = "--";
            }
            card.firstReadingLabel.text = "mmHg";
            card.firstReadingSubTitle.text = "Mean Arterial Pressure";
            card.firstReadingValue.textColor = color;
            
            card.secondReadingValue.text = "\(Int(lastCheckin.systolic!))/\(Int(lastCheckin.diastolic!))";
            card.secondReadingLabel.text = "mmHg";
            card.secondReadingSubTitle.text = "Blood Pressure";
            card.secondReadingValue.textColor = color;
        } else if (type == MetricsType.Weight) {
            card.firstReadingValue.text = "\(Int(lastCheckin.weightLbs!))";
            card.firstReadingLabel.text = "lbs";
            card.firstReadingSubTitle.text = "Weight";
            
            if let fatRatio = lastCheckin.fatRatio {
                // dirty way round to 2 decimal places
                card.secondReadingValue.text = "\(Double(round(fatRatio * 100) / 100))%";
            } else {
                card.secondReadingValue.text = "--%";
            }
            card.secondReadingLabel.text = "";
            card.secondReadingSubTitle.text = "Body Fat";
        } else if (type == MetricsType.DailySummary) {
            card.firstReadingValue.hidden = true;
            card.firstReadingLabel.hidden = true;
            card.firstReadingSubTitle.hidden = true;
            
            card.secondReadingValue.hidden = true;
            card.secondReadingLabel.hidden = true;
            card.secondReadingSubTitle.hidden = true;
            
            card.singleValue.hidden = false;
            card.singleLabel.hidden = false;
            card.singleSubtitle.hidden = false;
            
            card.singleValue.text = "\(Int(lastCheckin.pulseBpm!))";
            card.singleValue.textColor = color;
            card.singleLabel.text = "pts";
            card.singleSubtitle.text = "Activity Points";
        } else {
            card.firstReadingValue.hidden = true;
            card.firstReadingLabel.hidden = true;
            card.firstReadingSubTitle.hidden = true;
            
            card.secondReadingValue.hidden = true;
            card.secondReadingLabel.hidden = true;
            card.secondReadingSubTitle.hidden = true;
            
            card.singleValue.hidden = false;
            card.singleLabel.hidden = false;
            card.singleSubtitle.hidden = false;
            
            card.singleValue.text = "\(Int(lastCheckin.pulseBpm!))";
            card.singleValue.textColor = color;
            card.singleLabel.text = "bpm";
            card.singleSubtitle.text = "Beats Per Minute";
        }
        
        card.firstReadingValue.textColor = color;
        card.secondReadingValue.textColor = color;
        
        return card;
    }
    
    class func instanceFromNib(title: String, lastActivityDate: NSDate, totalPoints: Int, type: MetricsType) -> MetricsGraphCard {
        let card = UINib(nibName: "MetricGraphCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricsGraphCard;
        let color = Utility.colorFromMetricType(type);
        card.title.text = title;
        card.title.textColor = color;
        
        let formatter = NSDateFormatter(), dayFormatter = NSDateFormatter();
        formatter.dateFormat = "MMMM";
        dayFormatter.dateFormat = "dd";
        card.date.text = "\(formatter.stringFromDate(lastActivityDate)) \(ChallengeUtility.getRankSuffix(dayFormatter.stringFromDate(lastActivityDate)))";
        
        if (type == MetricsType.DailySummary) {
            card.firstReadingValue.hidden = true;
            card.firstReadingLabel.hidden = true;
            card.firstReadingSubTitle.hidden = true;
            
            card.secondReadingValue.hidden = true;
            card.secondReadingLabel.hidden = true;
            card.secondReadingSubTitle.hidden = true;
            
            card.singleValue.hidden = false;
            card.singleLabel.hidden = false;
            card.singleSubtitle.hidden = false;
            
            card.singleValue.text = "\(totalPoints)";
            card.singleValue.textColor = color;
            card.singleLabel.text = "pts";
            card.singleSubtitle.text = "Activity Points";
        }
        
        card.firstReadingValue.textColor = color;
        card.secondReadingValue.textColor = color;
        
        return card;
    }
    
    func graph(points: [GraphPoint], type: MetricsType) {
        let graph = MetricGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: points);
        graph.setupForDashboard(type);
        graph.userInteractionEnabled = false;
        graphView.addSubview(graph);
    }
}