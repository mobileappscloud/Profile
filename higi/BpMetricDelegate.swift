import Foundation

class BpMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;

    func getTitle() -> String {
        return "Blood Pressure";
    }
    
    func getColor() -> UIColor {
        return Utility.colorFromMetricType(getType());
    }
    
    func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "bloodpressureicon")!, color: UIColor.whiteColor());
    }
    
    func getType() -> MetricsType {
        return MetricsType.BloodPressure;
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = Double(date.timeIntervalSince1970);
        var minDifference = DBL_MAX;
        for i in 0...SessionController.Instance.checkins.count - 1 {
            let checkin = SessionController.Instance.checkins[SessionController.Instance.checkins.count - i - 1];
            let checkinDate = Double(checkin.dateTime.timeIntervalSince1970);
            let difference = abs(checkinDate - selectedDate);
            if (difference < minDifference && checkin.systolic != nil) {
                minDifference = difference;
                selectedCheckin = checkin;
            } else {
                break;
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint {
        let date = Constants.displayDateFormatter.stringFromDate(selectedCheckin.dateTime);
        let bp = selectedCheckin.systolic != nil ? "\(selectedCheckin.systolic!)/\(selectedCheckin.diastolic!)" : "";
        let map = selectedCheckin.map != nil ? "\(Int(selectedCheckin.map!))" : "";
        return MetricCard.SelectedPoint(date: date, firstPanelValue: bp, firstPanelLabel: "Blood Pressure", firstPanelUnit: "mmHg", secondPanelValue: map, secondPanelLabel: "Mean Arterial Pressure", secondPanelUnit: "mmHg")
    }
}