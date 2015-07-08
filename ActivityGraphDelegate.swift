import Foundation

class ActivityGraphDelegate : GraphDelegate {
    
    func getColor() -> UIColor {
        return MetricsType.DailySummary.getColor();
    }
    
    func getTitle() -> String {
        return MetricsType.DailySummary.getTitle();
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