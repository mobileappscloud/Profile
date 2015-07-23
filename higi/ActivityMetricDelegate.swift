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
        return UIImage(named: "activities_copy")!;
    }
    
    func setSelected(date: NSDate) {
        if sortedDates.count == 0 {
            sortedDates = SessionController.Instance.activities.keys.array;
            sortedDates.sort(sortByDate);
        }
        var lastDate = "";
        let selectedDate = Double(Constants.dateFormatter.dateFromString(Constants.dateFormatter.stringFromDate(date))!.timeIntervalSince1970);
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
            selectedActivity = (Constants.displayDateFormatter.stringFromDate(Constants.dateFormatter.dateFromString(lastDate)!), "\(points)");
        }
    }
    
    func getSelectedPoint() -> SelectedPoint? {
        if (selectedActivity == nil) {
            return nil;
        } else {
            let (date, points) = selectedActivity;
            return SelectedPoint(date: date, panelValue: points, panelLabel: "Activity Points", panelUnit: "pts", kioskInfo: nil);
        }
    }
    
    func getGraph(frame: CGRect) -> MetricGraph {
        return MetricGraphUtility.createActivityGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
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
    
    func sortByDate(this: String, that: String) -> Bool {
        return Constants.dateFormatter.dateFromString(this)?.timeIntervalSince1970 >= Constants.dateFormatter.dateFromString(that)?.timeIntervalSince1970;
    }
}