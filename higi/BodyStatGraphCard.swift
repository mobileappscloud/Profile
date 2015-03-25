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
    @IBOutlet weak var firstReadingPanel: UIView!
    @IBOutlet weak var secondReadingPanel: UIView!
    
    class func instanceFromNib(title: String, lastCheckin: HigiCheckin, color: UIColor, type: String) -> BodyStatsGraphCard {
        let card = UINib(nibName: "BodyStatGraphCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as BodyStatsGraphCard;
        card.title.text = title;
        let formatter = NSDateFormatter();
        formatter.dateFormat = "MMMM dd";
        card.date.text = formatter.stringFromDate(lastCheckin.dateTime);
        card.backgroundView.backgroundColor = color;
        
        if (type == "bp") {
            card.firstReadingValue.text = "\(lastCheckin.systolic)/\(lastCheckin.diastolic)";
            card.firstReadingLabel.text = "mmHg";
            card.firstReadingSubTitle.text = "Blood Pressure";
            
            card.secondReadingValue.text = "\(lastCheckin.map)";
            card.secondReadingLabel.text = "mmHg";
            card.secondReadingSubTitle.text = "Mean Arterial Pressure";
        } else if (type == "weight") {
            card.firstReadingValue.text = "\(Int(lastCheckin.weightLbs!))";
            card.firstReadingLabel.text = "lbs";
            card.firstReadingSubTitle.text = "Weight";
            
            card.secondReadingValue.text = "\(lastCheckin.map)";
            card.secondReadingLabel.text = "mmHg";
            card.secondReadingSubTitle.text = "Mean Arterial Pressure";
        } else {
            card.firstReadingValue.text = "\(lastCheckin.pulseBpm)";
            card.firstReadingLabel.text = "bpm";
            card.firstReadingSubTitle.text = "Blood Pressure";
            
            card.secondReadingValue.hidden = true;
            card.secondReadingLabel.hidden = true;
            card.secondReadingSubTitle.hidden = true;
        }
        
        card.firstReadingValue.textColor = color;
        card.secondReadingValue.textColor = color;

        card.firstReadingPanel.layer.borderColor = Utility.colorFromHexString("#EEEEEE").CGColor;
        card.firstReadingPanel.layer.borderWidth = 1;
        card.secondReadingPanel.layer.borderColor = Utility.colorFromHexString("#EEEEEE").CGColor;
        card.secondReadingPanel.layer.borderWidth = 1;
        
        return card;
    }
    
    func graph(points: [GraphPoint]) {
        let graph = BodyStatGraph(frame: CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height), points: points);
        graph.setupForDashboard();
        graphView.addSubview(graph);
    }
}