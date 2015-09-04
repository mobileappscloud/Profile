import Foundation

class ActivityMetricDelegate: MetricDelegate {
    
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
    
    func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "workouticon")!, color: UIColor.whiteColor());
    }
    
    func getType() -> MetricsType {
        return MetricsType.DailySummary;
    }
    
    func getCopyImage(tab: Int) -> UIImage {
        return UIImage(named: "activities_copy")!;
    }
    
    func getBlankStateImage() -> UIImage {
        return UIImage(named: "fitnessband")!;
    }
    
    func getBlankStateText() -> String {
        return "Welcome! It looks like you don’t have any higi points. Be it checking your vitals at a higi Station or counting steps with an activity tracker, higi wants to reward you for keeping tabs on your health. ";
    }
    
    func setSelected(date: NSDate) {
        if sortedDates.count == 0 {
            sortedDates = SessionController.Instance.activities.keys.array;
            sortedDates.sort({$0 > $1});
        }
        var lastDate = "";
        let selectedDate = date.timeIntervalSince1970;
        var minDifference = DBL_MAX;
        for activityDate in sortedDates {
            let interval = Constants.dateFormatter.dateFromString(activityDate)!.timeIntervalSince1970;
            let difference = abs(interval - selectedDate);
            if (difference < minDifference) {
                minDifference = difference;
                lastDate = activityDate;
            } else {
                break;
            }
        }
        if let (points, list) = SessionController.Instance.activities[lastDate] {
            selectedActivity = (lastDate, "\(points)");
        }
    }
    
    func getSelectedPoint() -> SelectedPoint? {
        if (selectedActivity == nil) {
            return nil;
        } else {
            let (date, points) = selectedActivity;
            return SelectedPoint(date: date, panelValue: points, panelLabel: "Activity Points", panelUnit: "pts", device: "");
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