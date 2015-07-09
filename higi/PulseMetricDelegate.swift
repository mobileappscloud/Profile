import Foundation

class PulseMetricDelegate: MetricDelegate {
    
    var selectedCheckin: HigiCheckin!;
    
    func getTitle() -> String {
        return getType().getTitle();
    }
    
    func getColor() -> UIColor {
        return getType().getColor();
    }
    
    func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "pulseicon")!, color: UIColor.whiteColor());
    }
    
    func getType() -> MetricsType {
        return MetricsType.Pulse;
    }
    
    func getCopyImage(tab: Int) -> UIImage? {
        return UIImage(named: "pulse_overlay")!;
    }
    
    func getBlankStateImage() -> UIImage {
        return UIImage(named: "pulse_overlay")!;
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = Utility.dateWithDateComponentOnly(date).timeIntervalSince1970;
        var minDifference = DBL_MAX;
        for checkin in SessionController.Instance.checkins.reverse() {
            let checkinDate = Utility.dateWithDateComponentOnly(checkin.dateTime).timeIntervalSince1970;
            let difference = abs(checkinDate - selectedDate);
            if (difference < minDifference && checkin.pulseBpm != nil) {
                minDifference = difference;
                selectedCheckin = checkin;
            } else if (difference > minDifference) {
                break;
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint? {
        if (selectedCheckin == nil) {
            return nil;
        } else {
            let date = Constants.displayDateFormatter.stringFromDate(selectedCheckin.dateTime);
            let pulse = selectedCheckin.pulseBpm != nil ? "\(Int(selectedCheckin.pulseBpm!))" : "";
            return MetricCard.SelectedPoint(date: date, panelValue: pulse, panelLabel: "Beats Per Minute", panelUnit: "bpm");
        }
    }
    
    func getGraph(frame: CGRect) -> MetricGraph {
        return MetricGraphUtility.createPulseGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
    }
    
    func getRanges(tab:Int) -> [MetricGauge.Range] {
        var ranges:[MetricGauge.Range] = [];
        ranges.append(MetricGauge.Range(label: "Low", color: Utility.colorFromHexString("#44aad8"), interval: (40, 60)));
        ranges.append(MetricGauge.Range(label: "Normal", color: Utility.colorFromHexString("#88c681"), interval: (60, 100)));
        ranges.append(MetricGauge.Range(label: "High", color: Utility.colorFromHexString("#ef535a"), interval: (100, 120)));
        return ranges;
    }
    
    func getSelectedValue(tab:Int) -> String {
        return selectedCheckin.pulseBpm != nil ? "\(selectedCheckin.pulseBpm!)" : "--";
    }
    
    func getSelectedUnit(tab: Int) -> String {
        return "bpm";
    }
    
    func getSelectedClass(tab: Int) -> String {
        if selectedCheckin != nil && selectedCheckin.pulseClass != nil {
            return selectedCheckin.pulseClass as! String;
        }
        return "";
    }

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