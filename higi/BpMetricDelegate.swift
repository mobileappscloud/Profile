import Foundation

final class BpMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;
    
    struct BpRanges {
        static let systolicRanges:[MetricGauge.Range] =
        [MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_NORMAL_TITLE", comment: "Title for blood pressure within a normal range."), color: Utility.colorFromHexString("#88c681"), interval: (90, 120)),
            MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_AT_RISK_TITLE", comment: "Title for blood pressure within an at-risk range."), color: Utility.colorFromHexString("#fdd835"), interval: (120, 140)),
            MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_HIGH_TITLE", comment: "Title for blood pressure within a high range."), color: Utility.colorFromHexString("#ef535a"), interval: (140, 200))];
        
        static let diastolicRanges:[MetricGauge.Range] =
        [MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_NORMAL_TITLE", comment: "Title for blood pressure within a normal range."), color: Utility.colorFromHexString("#88c681"), interval: (60, 80)), MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_AT_RISK_TITLE", comment: "Title for blood pressure within an at-risk range."), color: Utility.colorFromHexString("#fdd835"), interval: (80, 90)),
            MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_HIGH_TITLE", comment: "Title for blood pressure within a high range."), color: Utility.colorFromHexString("#ef535a"), interval: (90, 120))];
    }
    
    func getTitle() -> String {
        return getType().getTitle();
    }
    
    func getColor() -> UIColor {
        return getType().getColor();
    }
    
    func getSecondaryColor() -> UIColor? {
        return Utility.colorFromHexString("#b4a6c2")
    }

    func getType() -> MetricsType {
        return MetricsType.BloodPressure;
    }

    func getBlankStateText() -> String {
        return NSLocalizedString("BLOOD_PRESSURE_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display on blood pressure metrics view when there is no blood pressure data to display.");
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = date.timeIntervalSince1970;
        var minDifference = DBL_MAX;
        for checkin in Array(SessionController.Instance.checkins.reverse()) {
            let checkinTime = checkin.dateTime.timeIntervalSince1970;
            let difference = abs(checkinTime - selectedDate);
            if (difference < minDifference && checkin.systolic != nil) {
                minDifference = difference;
                selectedCheckin = checkin;
            } else if (difference > minDifference) {
                break;
            }
        }
    }

    func getRanges() -> [MetricGauge.Range] {
        var ranges:[MetricGauge.Range] = [];
        ranges.append(MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_AT_RISK_TITLE", comment: "Title for blood pressure within an at-risk range."), color: Utility.colorFromHexString("#fdd835"), interval: (30, 70)));
        ranges.append(MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_NORMAL_TITLE", comment: "Title for blood pressure within a normal range."), color: Utility.colorFromHexString("#88c681"), interval: (70, 110)));
        ranges.append(MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_HIGH_TITLE", comment: "Title for blood pressure within a high range."), color: Utility.colorFromHexString("#ef535a"), interval: (110, 150)));
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
                let containsSystolic = systolicRange.contains(Double(systolic));
                let containsDiastolic = diastolicRange.contains(Double(diastolic));
                if (containsSystolic && containsDiastolic) {
                    let value1 = (Double(systolic) - systolicRange.lowerBound) / (systolicRange.upperBound - systolicRange.lowerBound)
                    let value2 = (Double(diastolic) - diastolicRange.lowerBound) / (diastolicRange.upperBound - diastolicRange.lowerBound)
                    if (value1 > value2) {
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
            ranges.append(MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_LOW_TITLE", comment: "Title for blood pressure within a low range."), color: Utility.colorFromHexString("#44aad8"), interval: (30, 70)));
            ranges.append(MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_NORMAL_TITLE", comment: "Title for blood pressure within a normal range."), color: Utility.colorFromHexString("#88c681"), interval: (70, 110)));
            ranges.append(MetricGauge.Range(label: NSLocalizedString("BLOOD_PRESSURE_RANGE_HIGH_TITLE", comment: "Title for blood pressure within a high range."), color: Utility.colorFromHexString("#ef535a"), interval: (110, 150)));
        }
        return ranges;
    }
    
    func getSelectedValue(tab: Int) -> String {
        if selectedCheckin == nil {
            return "--";
        }
        if (tab == 0) {
            return selectedCheckin.systolic != nil ? "\(selectedCheckin.systolic!)/\(selectedCheckin.diastolic!)" : "--";
        } else {
            return selectedCheckin.map != nil ? String(format: "%.1f", arguments: [selectedCheckin.map!]) : "--";
        }
    }
    
    func getSelectedUnit(tab: Int) -> String {
        return NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_MILLIMETERS_OF_MERCURY", comment: "General purpose abbreviated label for the units of millimeter of mercury.");
    }
    
    func getSelectedClass(tab: Int) -> String {
        if tab == 0 {
            if selectedCheckin != nil && selectedCheckin.pulseClass != nil {
                return selectedCheckin.bpClass as! String;
            }
        } else {
            if selectedCheckin != nil && selectedCheckin.mapClass != nil {
                return selectedCheckin.mapClass as! String;
            }
        }
        return "";
    }
    
    // TODO: Verify this isn't grabbing localized strings....
    func colorFromClass(className: String, tab: Int) -> UIColor {
        var color: UIColor;
        if tab == 0 {
            switch (className) {
                case "Normal":
                    color = Utility.colorFromHexString("#88c681");
                case "At risk":
                    color = Utility.colorFromHexString("#fdd835");
                case "High":
                    color = Utility.colorFromHexString("#ef535a");
                default:
                    color = UIColor.whiteColor();
            }
        } else {
            switch (className) {
                case "Normal":
                    color = Utility.colorFromHexString("#88c681");
                case "Low":
                    color = Utility.colorFromHexString("#44aad8");
                case "High":
                    color = Utility.colorFromHexString("#ef535a");
                default:
                    color = UIColor.whiteColor();
            }
        }
        return color;
    }
    
    class func valueIsSystolic(systolic: Int, diastolic: Int) -> Bool {
        var isSystolic = true;

        for i in 0...BpRanges.systolicRanges.count - 1 {
            let systolicRange = BpRanges.systolicRanges[i];
            let diastolicRange = BpRanges.diastolicRanges[i];
            let containsSystolic = systolicRange.contains(Double(systolic));
            let containsDiastolic = diastolicRange.contains(Double(diastolic));
            if (containsSystolic && containsDiastolic) {
                let value1 = (Double(systolic) - systolicRange.lowerBound) / (systolicRange.upperBound - systolicRange.lowerBound)
                let value2 = (Double(diastolic) - diastolicRange.lowerBound) / (diastolicRange.upperBound - diastolicRange.lowerBound)
                if (value1 > value2) {
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