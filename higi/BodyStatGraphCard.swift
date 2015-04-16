import Foundation

class BodyStatsGraphCard: UIView {
    
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
    
    @IBOutlet weak var pulseSubtitle: UILabel!
    @IBOutlet weak var pulseLabel: UILabel!
    @IBOutlet weak var pulseValue: UILabel!
    var color: UIColor!;

    class func instanceFromNib(title: String, lastCheckin: HigiCheckin, type: BodyStatsType) -> BodyStatsGraphCard {
        let card = UINib(nibName: "BodyStatGraphCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! BodyStatsGraphCard;
        let color = Utility.colorFromBodyStatType(type);
        card.title.text = title;
        card.title.textColor = color;
        
        let formatter = NSDateFormatter(), dayFormatter = NSDateFormatter();
        formatter.dateFormat = "MMMM";
        dayFormatter.dateFormat = "dd";
        card.date.text = "\(formatter.stringFromDate(lastCheckin.dateTime)) \(Utility.getRankSuffix(dayFormatter.stringFromDate(lastCheckin.dateTime)))";
        
        if (type == BodyStatsType.BloodPressure) {
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
        } else if (type == BodyStatsType.Weight) {
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
        } else {
            card.firstReadingValue.hidden = true;
            card.firstReadingLabel.hidden = true;
            card.firstReadingSubTitle.hidden = true;
            
            card.secondReadingValue.hidden = true;
            card.secondReadingLabel.hidden = true;
            card.secondReadingSubTitle.hidden = true;
            
            card.pulseValue.hidden = false;
            card.pulseLabel.hidden = false;
            card.pulseSubtitle.hidden = false;
            
            card.pulseValue.text = "\(Int(lastCheckin.pulseBpm!))";
            card.pulseValue.textColor = color;
            card.pulseLabel.text = "bpm";
            card.pulseSubtitle.text = "Beats Per Minute";
        }
        
        card.firstReadingValue.textColor = color;
        card.secondReadingValue.textColor = color;
        
        return card;
    }
    
    func graph(points: [GraphPoint], color: UIColor) {
        let graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: points);
        graph.setupForDashboard(color);
        graphView.addSubview(graph);
    }
}