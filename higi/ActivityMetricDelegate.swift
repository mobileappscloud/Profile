import Foundation

class ActivityMetricDelegate: MetricDelegate {
    
    var selectedActivity: (date: String, points: String)!;
    
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
    
    func getCopyImage() -> UIImage? {
//        return UIImage(named: "pulse_overlay")!;
        return nil;
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = Double(date.timeIntervalSince1970);
        var minDifference = DBL_MAX;
        for (activityDate, (total, activities)) in SessionController.Instance.activities {
            let interval = Constants.dateFormatter.dateFromString(activityDate)!.timeIntervalSince1970;
            let difference = abs(interval - selectedDate);
            if (difference < minDifference) {
                minDifference = difference;
                selectedActivity = (Constants.displayDateFormatter.stringFromDate(NSDate(timeIntervalSince1970: interval)), "\(total)");
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint? {
        if (selectedActivity == nil) {
            return nil;
        } else {
            let (date, points) = selectedActivity;
            return MetricCard.SelectedPoint(date: date, panelValue: points, panelLabel: "Activity Points", panelUnit: "pts");
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
}