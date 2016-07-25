import Foundation

final class ActivityMetricDelegate: MetricDelegate {
    
    var selectedActivity: (date: String, points: String)!;
    
    var sortedDates:[String] = [];
    
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
        return MetricsType.DailySummary;
    }
    
    func getBlankStateText() -> String {
        return NSLocalizedString("ACTIVITY_METRICS_VIEW_BLANK_STATE_TEXT", comment: "Text to display if a user does not have any higi points.");
    }
    
    func setSelected(date: NSDate) {
        if sortedDates.count == 0 {
            sortedDates = Array(SessionController.Instance.activities.keys);
            sortedDates.sortInPlace({$0 > $1});
        }
        var lastDate = "";
        let selectedDate = date.timeIntervalSince1970;
        var minDifference = DBL_MAX;
        for activityDate in sortedDates {
            let interval = NSDateFormatter.activityDateFormatter.dateFromString(activityDate)!.timeIntervalSince1970;
            let difference = abs(interval - selectedDate);
            if (difference < minDifference) {
                minDifference = difference;
                lastDate = activityDate;
            } else {
                break;
            }
        }
        if let (points, _) = SessionController.Instance.activities[lastDate] {
            selectedActivity = (lastDate, "\(points)");
        }
    }
    
    func getRanges(tab:Int) -> [MetricGauge.Range] {
        return [];
    }
    
    func getSelectedValue(tab: Int) -> String {
        return "";
    }
    
    func getSelectedUnit(tab: Int) -> String {
        return "";
    }
    
    
    func getSelectedClass(tab: Int) -> String {
        return "";
    }
    
    func colorFromClass(className: String, tab: Int) -> UIColor {
        return UIColor.clearColor();
    }
    
    func shouldShowRegions() -> Bool {
        return false;
    }

}