import Foundation

class ActivityMetricDelegate: MetricDelegate {
    
    var selectedActivity: (date: String, points: String)!;
    
    func getTitle() -> String {
        return "Activity";
    }
    
    func getColor() -> UIColor {
        return Utility.colorFromMetricType(getType());
    }
    
    func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "workouticon")!, color: UIColor.whiteColor());
    }
    
    func getType() -> MetricsType {
        return MetricsType.DailySummary;
    }
    
    func setSelected(date: NSDate) {
        let selectedDate = Double(date.timeIntervalSince1970);
        var minDifference = DBL_MAX;
        for (activityDate, (total, activities)) in SessionController.Instance.activities {
            let date = Constants.dateFormatter.dateFromString(activityDate)!.timeIntervalSince1970;
            let difference = abs(date - selectedDate);
            if (difference < minDifference) {
                minDifference = difference;
                selectedActivity = (Constants.displayDateFormatter.stringFromDate(NSDate(timeIntervalSince1970: date)), "\(total)");
            } else {
                break;
            }
        }
    }
    
    func getSelectedPoint() -> MetricCard.SelectedPoint {
        let (date, points) = selectedActivity;
        return MetricCard.SelectedPoint(date: date, panelValue: points, panelLabel: "Activity Points", panelUnit: "pts");
    }
    
    func getGraph(frame: CGRect) -> MetricGraph {
        return MetricGraphUtility.createActivityGraph(CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
    }
    
    func getRanges() -> [MetricGauge.Range] {
        return [];
    }
}