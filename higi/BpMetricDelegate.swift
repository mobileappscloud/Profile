import Foundation

class BpMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;

    func getTitle() -> String {
        return getType().getTitle();
    }
    
    func getColor() -> UIColor {
        return getType().getColor();
    }
    
    func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "bloodpressureicon")!, color: UIColor.whiteColor());
    }
    
    func getType() -> MetricsType {
        return MetricsType.BloodPressure;
    }
    
    func getCopyImage() -> UIImage? {
        return UIImage(named: "bp_overlay")!;
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
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint {
        let date = Constants.displayDateFormatter.stringFromDate(selectedCheckin.dateTime);
        let bp = selectedCheckin.systolic != nil ? "\(selectedCheckin.systolic!)/\(selectedCheckin.diastolic!)" : "";
        let map = selectedCheckin.map != nil ? "\(Int(selectedCheckin.map!))" : "";
        return MetricCard.SelectedPoint(date: date, firstPanelValue: bp, firstPanelLabel: "Blood Pressure", firstPanelUnit: "mmHg", secondPanelValue: map, secondPanelLabel: "Mean Arterial Pressure", secondPanelUnit: "mmHg")
    }
    
    func getGraph(frame: CGRect) -> MetricGraph {
        return MetricGraphUtility.createBpGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
    }
    
    func getRanges() -> [MetricGauge.Range] {
        var ranges:[MetricGauge.Range] = [];
        ranges.append(MetricGauge.Range(label: "At risk", color: Utility.colorFromHexString("#fdd835"), interval: (30, 70)));
        ranges.append(MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (70, 110)));
        ranges.append(MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (110, 150)));
        return ranges;
    }
}