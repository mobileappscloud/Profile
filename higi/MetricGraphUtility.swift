import Foundation

class MetricGraphUtility {
    
    class func createActivityGraph(frame: CGRect) -> MetricGraph {
        var points:[GraphPoint] = [];
        let dateString = Constants.dateFormatter.stringFromDate(NSDate());
        var totalPoints = 0;
        for (date, (total, activityList)) in SessionController.Instance.activities {
            if (date == dateString) {
                totalPoints = total;
            }
            if (activityList.count > 0) {
                let activityDate = Double(activityList[0].startTime.timeIntervalSince1970);
                points.append(GraphPoint(x: activityDate, y: Double(total)));
            }
        }
        return graphWithPoints(frame, points: points, color: MetricsType.DailySummary.getColor());
    }

    class func createBpGraph(frame: CGRect) -> MetricGraph {
        var points:[GraphPoint] = [], altPoints:[GraphPoint] = [];
        var lastBpDate = "";
        for checkin in SessionController.Instance.checkins.reverse() {
            let dateString = Constants.dateFormatter.stringFromDate(checkin.dateTime);
            if (dateString != lastBpDate) {
                let checkinTime = Utility.dateWithDateComponentOnly(checkin.dateTime).timeIntervalSince1970;
                if (checkin.map != nil && checkin.map > 0) {
                    points.append(GraphPoint(x: checkinTime, y: checkin.map));
                    if (checkin.diastolic != nil && checkin.diastolic > 0) {
                        altPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.diastolic!)));
                        altPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.systolic!)));
                    } else {
                        altPoints.append(GraphPoint(x: checkinTime, y: 0));
                        altPoints.append(GraphPoint(x: checkinTime, y: 0));
                    }
                    lastBpDate = dateString;
                }
            }
        }
        return graphWithPoints(frame, points: points, altPoints: altPoints, color: MetricsType.BloodPressure.getColor());
    }
    
    class func createWeightGraph(frame: CGRect) -> MetricGraph {
        var points:[GraphPoint] = [];
        var lastWeightDate = "";
        for checkin in SessionController.Instance.checkins.reverse() {
            let dateString = Constants.dateFormatter.stringFromDate(checkin.dateTime);
            if (dateString != lastWeightDate) {
                let checkinTime = Utility.dateWithDateComponentOnly(checkin.dateTime).timeIntervalSince1970;
                if (checkin.weightLbs != nil && checkin.weightLbs > 0) {
                    points.append(GraphPoint(x: checkinTime, y: checkin.weightLbs));
                    lastWeightDate = dateString;
                }
            }
        }
        return graphWithPoints(frame, points: points, color: MetricsType.Weight.getColor());
    }
    
    class func createBodyFatGraph(frame: CGRect) -> MetricGraph? {
        var points:[GraphPoint] = [], altPoints:[GraphPoint] = [];
        var lastFatDate = "", lastWeightDate = "";
        
        var heaviest = 1.0, thinnest = 100.0, fattest = 1.0;
        for checkin in SessionController.Instance.checkins.reverse() {
            if (checkin.weightLbs != nil && checkin.weightLbs > heaviest) {
                heaviest = checkin.weightLbs!;
            }
            if (checkin.fatRatio != nil && checkin.fatRatio > fattest) {
                fattest = checkin.fatRatio!;
            }
            if (checkin.fatRatio != nil && checkin.fatRatio < thinnest) {
                thinnest = checkin.fatRatio!;
            }
        }
        
        for checkin in SessionController.Instance.checkins.reverse() {
            let dateString = Constants.dateFormatter.stringFromDate(checkin.dateTime);
            if (dateString != lastFatDate) {
                let checkinTime = Utility.dateWithDateComponentOnly(checkin.dateTime).timeIntervalSince1970;
                if (checkin.fatRatio != nil && checkin.fatRatio > 0) {
                    points.append(GraphPoint(x: checkinTime, y: checkin.fatRatio));
                    lastFatDate = dateString;
                }
                if (checkin.weightLbs != nil && checkin.weightLbs > 0) {
                    altPoints.append(GraphPoint(x: checkinTime, y: 10 + (checkin.weightLbs! / heaviest) * fattest * (1 + (fattest - thinnest) / 150.0)));
                    lastWeightDate = dateString;
                }
            }
        }
        if (points.count > 0) {
            return graphWithPoints(frame, points: points, altPoints: altPoints, color: MetricsType.Weight.getColor());
        } else {
            return nil;
        }
    }
    
    class func createPulseGraph(frame: CGRect) -> MetricGraph {
        var points:[GraphPoint] = [];
        var lastPulseDate = "";
        for checkin in SessionController.Instance.checkins.reverse() {
            let dateString = Constants.dateFormatter.stringFromDate(checkin.dateTime);
            if (dateString != lastPulseDate) {
                let checkinTime = Utility.dateWithDateComponentOnly(checkin.dateTime).timeIntervalSince1970;
                if (checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                    points.append(GraphPoint(x: checkinTime, y: Double(checkin.pulseBpm!)));
                    lastPulseDate = dateString;
                }
            }
        }
        return graphWithPoints(frame, points: points, color: MetricsType.Pulse.getColor());
    }
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], color: UIColor) -> MetricGraph {
        var graphPoints = points;
        graphPoints.sort({$0.x < $1.x});
        let graph = MetricGraph(frame: frame, points: graphPoints);
        graph.setupForMetric(color);
        return graph;
    }
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint], color: UIColor) -> MetricGraph {
        var graphPoints = points;
        var graphAltPoints = altPoints;
        graphPoints.sort({$0.x < $1.x});
        graphAltPoints.sort({$0.x < $1.x});
        let graph = MetricGraph(frame: frame, points: graphPoints, altPoints: graphAltPoints);
        graph.setupForMetric(color);
        return graph;
    }
}