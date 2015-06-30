import Foundation

class BpMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;

    struct BpRanges {
        static let systolicRanges:[MetricGauge.Range] = [MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (90, 120)), MetricGauge.Range(label: "At risk", color: Utility.colorFromHexString("#fdd835"), interval: (120, 140)), MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (140, 200))];
        
        static let diastolicRanges:[MetricGauge.Range] = [MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (60, 80)), MetricGauge.Range(label: "At risk", color: Utility.colorFromHexString("#fdd835"), interval: (80, 90)), MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (90, 120))];
    }
    
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
        let selectedDate = Double(Constants.dateFormatter.dateFromString(Constants.dateFormatter.stringFromDate(date))!.timeIntervalSince1970);
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
    
    func getSelectedPoint() -> MetricCard.SelectedPoint? {
        if (selectedCheckin == nil) {
            return nil;
        } else {
            let date = Constants.displayDateFormatter.stringFromDate(selectedCheckin.dateTime);
            let bp = selectedCheckin.systolic != nil ? "\(selectedCheckin.systolic!)/\(selectedCheckin.diastolic!)" : "";
            let map = selectedCheckin.map != nil ? "\(Int(selectedCheckin.map!))" : "";
                return MetricCard.SelectedPoint(date: date, firstPanelValue: bp, firstPanelLabel: "Blood Pressure", firstPanelUnit: "mmHg", secondPanelValue: map, secondPanelLabel: "Mean Arterial Pressure", secondPanelUnit: "mmHg");
        }
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
        if (tab == 0) {
            let systolic = selectedCheckin.systolic!;
            let diastolic = selectedCheckin.diastolic!;
            for i in 0...BpRanges.systolicRanges.count - 1 {
                let systolicRange = BpRanges.systolicRanges[i];
                let diastolicRange = BpRanges.diastolicRanges[i];
                let containsSystolic = systolicRange.contains(systolic);
                let containsDiastolic = diastolicRange.contains(diastolic);
                if (containsSystolic && containsDiastolic) {
                    if ((systolic - systolicRange.lowerBound) / (systolicRange.upperBound - systolicRange.lowerBound) >
                        (diastolic - diastolicRange.lowerBound) / (diastolicRange.upperBound - diastolicRange.lowerBound)) {
                            ranges = BpRanges.systolicRanges;
                    } else {
                        ranges = BpRanges.diastolicRanges;
                    }
                } else if (containsSystolic) {
                    ranges = BpRanges.systolicRanges;
                } else if (containsDiastolic) {
                    ranges = BpRanges.diastolicRanges;
                }
            }
        } else if (tab == 1) {
            ranges.append(MetricGauge.Range(label: "Low", color: Utility.colorFromHexString("#44aad8"), interval: (30, 70)));
            ranges.append(MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (70, 110)));
            ranges.append(MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (110, 150)));
        }
        return ranges;
    }
    
    func getSelectedValue(tab: Int) -> String {
        if (tab == 0) {
            return selectedCheckin.systolic != nil ? "\(selectedCheckin.systolic!)/\(selectedCheckin.diastolic!)" : "--";
        } else {
            return selectedCheckin.map != nil ? "\(Int(selectedCheckin.map!))" : "--";
        }
    }
    
    func getSelectedUnit(tab: Int) -> String {
        return "mmHg";
    }
    
    class func valueIsSystolic(systolic: Int, diastolic: Int) -> Bool {
        var isSystolic = true;
        var ranges:[MetricGauge.Range] = [];
        for i in 0...BpRanges.systolicRanges.count - 1 {
            let systolicRange = BpRanges.systolicRanges[i];
            let diastolicRange = BpRanges.diastolicRanges[i];
            let containsSystolic = systolicRange.contains(systolic);
            let containsDiastolic = diastolicRange.contains(diastolic);
            if (containsSystolic && containsDiastolic) {
                if ((systolic - systolicRange.lowerBound) / (systolicRange.upperBound - systolicRange.lowerBound) >
                    (diastolic - diastolicRange.lowerBound) / (diastolicRange.upperBound - diastolicRange.lowerBound)) {
                        isSystolic = true;
                } else {
                    isSystolic = false;
                }
            } else if (containsSystolic) {
                isSystolic = true;
            } else if (containsDiastolic) {
                isSystolic = false;
            }
        }
        return isSystolic;
    }
    
    func shouldShowRegions() -> Bool {
        return true;
    }
}