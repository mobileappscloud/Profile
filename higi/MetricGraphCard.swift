import Foundation

final class MetricsGraphCard: UIView {
    
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

    class func instanceFromNib(lastCheckin: HigiCheckin?, type: MetricsType) -> MetricsGraphCard {
        let card = UINib(nibName: "MetricGraphCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricsGraphCard;
        card.initCard(type);
        if (lastCheckin != nil) {
            card.setCheckinData(lastCheckin!, type: type);
        } else {
            card.initBlankState(type);
        }
        
        return card;
    }
    
    class func instanceFromNib(activityPoints: Int, type: MetricsType) -> MetricsGraphCard {
        let card = UINib(nibName: "MetricGraphCardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MetricsGraphCard;
        card.initCard(type);
        card.setActivity(activityPoints);
        return card;
    }
    
    func initCard(type: MetricsType) {
        color = type.getColor();
        title.text = type.getTitle();
        title.textColor = color;
    }
    
    func initBlankState(type: MetricsType) {
        date.text = "";
        if (type == MetricsType.BloodPressure) {
            firstReadingValue.hidden = true;
            firstReadingLabel.hidden = true;
            firstReadingSubTitle.hidden = true;
            secondReadingValue.hidden = true;
            secondReadingLabel.hidden = true;
            secondReadingSubTitle.hidden = true;
            singleValue.hidden = false;
            singleLabel.hidden = false;
            singleSubtitle.hidden = false;
            
            singleValue.text = "--";
            singleLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_MILLIMETERS_OF_MERCURY", comment: "General purpose abbreviated label for the units of millimeter of mercury.");
            singleSubtitle.text = NSLocalizedString("METRICS_GRAPH_CARD_BLOOD_PRESSURE_SUBTITLE", comment: "Subtitle text for blood pressure data shown on metrics graph card.");
            singleValue.textColor = color;
            
        } else if (type == MetricsType.Weight) {
            firstReadingValue.text = "--";
            firstReadingLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_WEIGHT_POUNDS", comment: "General purpose abbreviated label for the english units of weight measurement, pounds.");
            firstReadingSubTitle.text = NSLocalizedString("METRICS_GRAPH_CARD_WEIGHT_SUBTITLE", comment: "Subtitle text for body weight data shown on metrics graph card.");
            secondReadingValue.text = "--%";
            secondReadingLabel.text = "";
            secondReadingSubTitle.text = NSLocalizedString("METRICS_GRAPH_CARD_BODY_FAT_SUBTITLE", comment: "Subtitle text for body fat data shown on metrics graph card.");
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
            singleValue.text = "--";
            singleValue.textColor = color;
            singleLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_POINTS", comment: "General purpose abbreviated label for points.");
            singleSubtitle.text = NSLocalizedString("METRICS_GRAPH_CARD_ACTIVITY_POINTS_SUBTITLE", comment: "Subtitle text for activity points data shown on metrics graph card.");
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
            singleValue.text = "--";
            singleValue.textColor = color;
            singleLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_BEATS_PER_MINUTE", comment: "General purpose abbreviated label for beats per minute.");
            singleSubtitle.text = NSLocalizedString("METRICS_GRAPH_CARD_BEATS_PER_MINUTE_SUBTITLE", comment: "Subtitle text for beats per minute data shown on metrics graph card.");
        }
        
        firstReadingValue.textColor = color;
        secondReadingValue.textColor = color;
    }
    
    func setCheckinData(checkin: HigiCheckin, type: MetricsType) {
        let formatter = NSDateFormatter(), dayFormatter = NSDateFormatter();
        formatter.dateFormat = "MMMM";
        dayFormatter.dateFormat = "d";
        date.text = "\(formatter.stringFromDate(checkin.dateTime)) \(ChallengeUtility.getRankSuffix(dayFormatter.stringFromDate(checkin.dateTime)))";
        
        if (type == MetricsType.BloodPressure) {
            firstReadingValue.hidden = true;
            firstReadingLabel.hidden = true;
            firstReadingSubTitle.hidden = true;
            
            secondReadingValue.hidden = true;
            secondReadingLabel.hidden = true;
            secondReadingSubTitle.hidden = true;
            
            singleValue.hidden = false;
            singleLabel.hidden = false;
            singleSubtitle.hidden = false;
            
            singleValue.text = checkin.systolic != nil ? "\(Int(checkin.systolic!))/\(Int(checkin.diastolic!))" : "--";
            singleLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_MILLIMETERS_OF_MERCURY", comment: "General purpose abbreviated label for the units of millimeter of mercury.");
            singleSubtitle.text = NSLocalizedString("METRICS_GRAPH_CARD_BLOOD_PRESSURE_SUBTITLE", comment: "Subtitle text for blood pressure data shown on metrics graph card.");
            singleValue.textColor = color;
        } else if (type == MetricsType.Weight) {
            firstReadingValue.text = checkin.weightLbs != nil ? "\(Int(checkin.weightLbs!))" : "--";
            firstReadingLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_WEIGHT_POUNDS", comment: "General purpose abbreviated label for the english units of weight measurement, pounds.");
            firstReadingSubTitle.text = NSLocalizedString("METRICS_GRAPH_CARD_WEIGHT_SUBTITLE", comment: "Subtitle text for body weight data shown on metrics graph card.");
            
            if let fatRatio = checkin.fatRatio {
                // dirty way round to 2 decimal places
                secondReadingValue.text = "\(Double(round(fatRatio * 100) / 100))%";
            } else {
                secondReadingValue.text = "--%";
            }
            secondReadingLabel.text = "";
            secondReadingSubTitle.text = NSLocalizedString("METRICS_GRAPH_CARD_BODY_FAT_SUBTITLE", comment: "Subtitle text for body fat data shown on metrics graph card.");
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
            
            singleValue.text = checkin.pulseBpm != nil ? "\(Int(checkin.pulseBpm!))" : "--";
            singleValue.textColor = color;
            singleLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_POINTS", comment: "General purpose abbreviated label for points.");
            singleSubtitle.text = NSLocalizedString("METRICS_GRAPH_CARD_ACTIVITY_POINTS_SUBTITLE", comment: "Subtitle text for activity points data shown on metrics graph card.");
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
            
            singleValue.text = checkin.pulseBpm != nil ? "\(Int(checkin.pulseBpm!))" : "--";
            singleValue.textColor = color;
            singleLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_BEATS_PER_MINUTE", comment: "General purpose abbreviated label for beats per minute.");
            singleSubtitle.text = NSLocalizedString("METRICS_GRAPH_CARD_BEATS_PER_MINUTE_SUBTITLE", comment: "Subtitle text for beats per minute data shown on metrics graph card.");
        }
        
        firstReadingValue.textColor = color;
        secondReadingValue.textColor = color;
    }
    
    func setActivity(activityPoints: Int) {
        date.text = "";
        firstReadingValue.hidden = true;
        firstReadingLabel.hidden = true;
        firstReadingSubTitle.hidden = true;
        
        secondReadingValue.hidden = true;
        secondReadingLabel.hidden = true;
        secondReadingSubTitle.hidden = true;
        
        singleValue.hidden = false;
        singleLabel.hidden = false;
        singleSubtitle.hidden = false;
        
        singleValue.text = "\(activityPoints)";
        singleValue.textColor = color;
        singleLabel.text = NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_POINTS", comment: "General purpose abbreviated label for points.");
        singleSubtitle.text = NSLocalizedString("METRICS_GRAPH_CARD_ACTIVITY_POINTS_SUBTITLE", comment: "Subtitle text for activity points data shown on metrics graph card.");
        
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