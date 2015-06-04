import Foundation

class ActivityGraphDelegate : GraphDelegate {
    
    func getColor() -> UIColor {
        return Utility.colorFromMetricType(MetricsType.DailySummary);
    }
    
    func getTitle() -> String {
        return "Activity";
    }
    
    func createGraphWithCheckins(frame: CGRect, checkins: [HigiCheckin]) -> BaseGraphHostingView? {
        return nil;
    }
    
    func createGraphWithActivities(frame: CGRect, activities: [HigiActivity]) -> BaseGraphHostingView? {
        var points:[GraphPoint] = [];
        for activity in activities {
            points.append(GraphPoint(x: Double(activity.startTime.timeIntervalSince1970), y: Double(activity.points)));
        }
        return BaseGraphHostingView(frame: frame, points: points);
    }
}