import Foundation

class PulseMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;
    
    func getTitle() -> String {
        return "Pulse";
    }
    
    func getColor() -> UIColor {
        return Utility.colorFromMetricType(getType());
    }
    
    func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "pulseicon")!, color: UIColor.whiteColor());
    }
    
    func getType() -> MetricsType {
        return MetricsType.Pulse;
    }
    
    func getCopyImage() -> UIImage? {
        return UIImage(named: "pulse_overlay")!;
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = Double(date.timeIntervalSince1970);
        var minDifference = DBL_MAX;
        for i in 0...SessionController.Instance.checkins.count - 1 {
            let checkin = SessionController.Instance.checkins[SessionController.Instance.checkins.count - i - 1];
            let checkinDate = Double(checkin.dateTime.timeIntervalSince1970);
            let difference = abs(checkinDate - selectedDate);
            if (difference < minDifference && checkin.pulseBpm != nil) {
                minDifference = difference;
                selectedCheckin = checkin;
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint {
        let date = Constants.displayDateFormatter.stringFromDate(selectedCheckin.dateTime);
        let pulse = selectedCheckin.pulseBpm != nil ? "\(Int(selectedCheckin.pulseBpm!))" : "";
        return MetricCard.SelectedPoint(date: date, panelValue: pulse, panelLabel: "Beats Per Minute", panelUnit: "bpm");
    }
    
    func getGraph(frame: CGRect) -> MetricGraph {
        return MetricGraphUtility.createPulseGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
    }
    
    func getRanges() -> [MetricGauge.Range] {
        var ranges:[MetricGauge.Range] = [];
        ranges.append(MetricGauge.Range(label: "Low", color: Utility.colorFromHexString("#44aad8"), interval: (40, 60)));
        ranges.append(MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (60, 100)));
        ranges.append(MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (100, 120)));
        return ranges;
    }
}