import Foundation

final class PulseMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;
    
    func getTitle() -> String {
        return getType().getTitle();
    }
    
    func getColor() -> UIColor {
        return getType().getColor();
    }
    
    func getSecondaryColor() -> UIColor? {
        return nil;
    }

    func getType() -> MetricsType {
        return MetricsType.Pulse;
    }

    func getBlankStateText() -> String {
        return NSLocalizedString("PULSE_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display on pulse metrics view if there is no pulse data to display.");
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = date.timeIntervalSince1970;
        var minDifference = DBL_MAX;
        for checkin in Array(SessionController.Instance.checkins.reverse()) {
            let checkinTime = checkin.dateTime.timeIntervalSince1970;
            let difference = abs(checkinTime - selectedDate);
            if (difference < minDifference && checkin.pulseBpm != nil) {
                minDifference = difference;
                selectedCheckin = checkin;
            } else if (difference > minDifference) {
                break;
            }
        }
    }

    func getRanges(tab:Int) -> [MetricGauge.Range] {
        var ranges:[MetricGauge.Range] = [];
        ranges.append(MetricGauge.Range(label: NSLocalizedString("PULSE_RANGE_LOW_TITLE", comment: "Title for pulse reading which falls within a low range."), color: Utility.colorFromHexString("#44aad8"), interval: (40, 60)));
        ranges.append(MetricGauge.Range(label: NSLocalizedString("PULSE_RANGE_NORMAL_TITLE", comment: "Title for pulse reading which falls within a normal range."), color: Utility.colorFromHexString("#88c681"), interval: (60, 100)));
        ranges.append(MetricGauge.Range(label: NSLocalizedString("PULSE_RANGE_HIGH_TITLE", comment: "Title for pulse reading which falls within a high range."), color: Utility.colorFromHexString("#ef535a"), interval: (100, 120)));
        return ranges;
    }
    
    func getSelectedValue(tab:Int) -> String {
        if selectedCheckin == nil {
            return "--";
        }
        return selectedCheckin.pulseBpm != nil ? "\(selectedCheckin.pulseBpm!)" : "--";
    }
    
    func getSelectedUnit(tab: Int) -> String {
        return NSLocalizedString("GENERAL_PURPOSE_UNIT_LABEL_ABBR_BEATS_PER_MINUTE", comment: "General purpose abbreviated label for beats per minute.")
    }
    
    func getSelectedClass(tab: Int) -> String {
        if selectedCheckin != nil && selectedCheckin.pulseClass != nil {
            return selectedCheckin.pulseClass as! String;
        }
        return "";
    }

    // TODO: l10n make sure we're not switching on a string
    func colorFromClass(className: String, tab: Int) -> UIColor {
        var color: UIColor;
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
        return color;
    }
    
    func shouldShowRegions() -> Bool {
        return true;
    }
}