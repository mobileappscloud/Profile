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
            } else {
                break;
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint {
        let date = Constants.displayDateFormatter.stringFromDate(selectedCheckin.dateTime);
        let pulse = selectedCheckin.pulseBpm != nil ? "\(Int(selectedCheckin.pulseBpm!))" : "";
        return MetricCard.SelectedPoint(date: date, panelValue: pulse, panelLabel: "Beats Per Minute", panelUnit: "bpm");
    }
}