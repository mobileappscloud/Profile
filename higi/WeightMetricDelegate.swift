import Foundation

class WeightMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;

    func getTitle() -> String {
        return "Weight";
    }
    
    func getColor() -> UIColor {
        return Utility.colorFromMetricType(getType());
    }
    
    func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "weighticon")!, color: UIColor.whiteColor());
    }
    
    func getType() -> MetricsType {
        return MetricsType.Weight;
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = Double(date.timeIntervalSince1970);
        var minDifference = DBL_MAX;
        for i in 0...SessionController.Instance.checkins.count - 1 {
            let checkin = SessionController.Instance.checkins[SessionController.Instance.checkins.count - i - 1];
            let checkinDate = Double(checkin.dateTime.timeIntervalSince1970);
            let difference = abs(checkinDate - selectedDate);
            if (difference < minDifference && checkin.weightLbs != nil || checkin.fatRatio != nil) {
                minDifference = difference;
                selectedCheckin = checkin;
            } else {
                break;
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint {
        let date = Constants.displayDateFormatter.stringFromDate(selectedCheckin.dateTime);
        let weight = selectedCheckin.weightLbs != nil ? "\(Int(selectedCheckin.weightLbs!))" : "";
        let bodyFat = selectedCheckin.fatRatio != nil ? "\(Int(selectedCheckin.fatRatio!))%" : "--%";
        return MetricCard.SelectedPoint(date: date, firstPanelValue: weight, firstPanelLabel: "Weight", firstPanelUnit: "lbs", secondPanelValue: bodyFat, secondPanelLabel: "Body Fat", secondPanelUnit: "")
    }
}