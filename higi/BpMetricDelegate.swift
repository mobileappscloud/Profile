import Foundation

class BpMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;

    var systolicRanges:[MetricGauge.Range] = [MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (90, 120)), MetricGauge.Range(label: "At risk", color: Utility.colorFromHexString("#fdd835"), interval: (120, 140)), MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (140, 200))];
    
    var diastolicRanges:[MetricGauge.Range] = [MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (60, 80)), MetricGauge.Range(label: "At risk", color: Utility.colorFromHexString("#fdd835"), interval: (80, 90)), MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (90, 120))];
    
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
    
    func getRanges(tab: Int) -> [MetricGauge.Range] {
        var ranges:[MetricGauge.Range] = [];
        var value = 0;
        if (tab == 0) {
            let systolic = selectedCheckin.systolic!;
            let diastolic = selectedCheckin.diastolic!;
            for i in 0...systolicRanges.count - 1 {
                let systolicRange = systolicRanges[i];
                let diastolicRange = diastolicRanges[i];
                let containsSystolic = systolicRange.contains(systolic);
                let containsDiastolic = diastolicRange.contains(diastolic);
                if (containsSystolic && containsDiastolic) {
                    if ((systolic - systolicRange.lowerBound) / (systolicRange.upperBound - systolicRange.lowerBound) >
                        (diastolic - diastolicRange.lowerBound) / (diastolicRange.upperBound - diastolicRange.lowerBound)) {
                            ranges = systolicRanges;
                            value = systolic;
                    } else {
                        ranges = diastolicRanges;
                        value = diastolic;
                    }
                } else if (containsSystolic) {
                    ranges = systolicRanges;
                    break;
                } else if (containsDiastolic) {
                    ranges = diastolicRanges;
                    break;
                }
            }
            if (ranges.count == 0) {
                
            }
        } else if (tab == 1) {
            ranges.append(MetricGauge.Range(label: "Low", color: Utility.colorFromHexString("#44aad8"), interval: (30, 70)));
            ranges.append(MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (70, 110)));
            ranges.append(MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (110, 150)));
        }
        return ranges;
    }
}