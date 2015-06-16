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
                let activityDate =  Double(activityList[0].startTime.timeIntervalSince1970);
                points.append(GraphPoint(x: activityDate, y: Double(total)));
            }
        }
        return graphWithPoints(frame, points: points, color: MetricsType.DailySummary.getColor());
    }

    class func createBpGraph(frame: CGRect) -> MetricGraph {
        var points:[GraphPoint] = [], altPoints:[GraphPoint] = [];
        for checkin in SessionController.Instance.checkins {
            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
            if (checkin.map != nil && checkin.map > 0) {
                points.append(GraphPoint(x: checkinTime, y: checkin.map));
                if (checkin.diastolic != nil && checkin.diastolic > 0) {
                    altPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.diastolic!)));
                    altPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.systolic!)));
                } else {
                    altPoints.append(GraphPoint(x: checkinTime, y: 0));
                    altPoints.append(GraphPoint(x: checkinTime, y: 0));
                }
            }

        }
        return graphWithPoints(frame, points: points, altPoints: altPoints, color: MetricsType.BloodPressure.getColor());
    }
    
    class func createWeightGraph(frame: CGRect) -> MetricGraph {
        var points:[GraphPoint] = [];
        for checkin in SessionController.Instance.checkins {
            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
            if (checkin.weightLbs != nil && checkin.weightLbs > 0) {
//                if (checkin.fatRatio > 0) {
//                    bodyFatPoints.append(GraphPoint(x: checkinTime, y: checkin.fatRatio));
//                }
                points.append(GraphPoint(x: checkinTime, y: checkin.weightLbs));
            }
        }
        return graphWithPoints(frame, points: points, color: MetricsType.Weight.getColor());
    }
    
    class func createBodyFatGraph(frame: CGRect) -> MetricGraph {
        var points:[GraphPoint] = [];
        for checkin in SessionController.Instance.checkins {
            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
            if (checkin.fatRatio != nil && checkin.fatRatio > 0) {
                points.append(GraphPoint(x: checkinTime, y: checkin.fatRatio));
            }
        }
        return graphWithPoints(frame, points: points, color: MetricsType.Weight.getColor());
    }
    
    class func createPulseGraph(frame: CGRect) -> MetricGraph {
        var points:[GraphPoint] = [];
        for checkin in SessionController.Instance.checkins {
            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
            if (checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
                points.append(GraphPoint(x: checkinTime, y: Double(checkin.pulseBpm!)));
            }
        }
        return graphWithPoints(frame, points: points, color: MetricsType.Pulse.getColor());
    }
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], color: UIColor) -> MetricGraph {
        var graphPoints = points;
        graphPoints.sort({$0.x < $1.x});
        let graph = MetricGraph(frame: frame, points: graphPoints);
        graph.setupBareBones(color);
        return graph;
    }
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint], color: UIColor) -> MetricGraph {
        var graphPoints = points;
        var graphAltPoints = altPoints;
        graphPoints.sort({$0.x < $1.x});
        graphAltPoints.sort({$0.x < $1.x});
        let graph = MetricGraph(frame: frame, points: graphPoints, altPoints: graphAltPoints);
        graph.setupBareBones(color);
        return graph;
    }
//    func doAGraph() {
//        var graphPoints: [GraphPoint] = [], diastolicPoints: [GraphPoint] = [], systolicPoints: [GraphPoint] = [], bodyFatPoints: [GraphPoint] = [];
//        for checkin in checkins {
//            let checkinTime = Double(checkin.dateTime.timeIntervalSince1970);
//            if (type == MetricsType.BloodPressure && checkin.map != nil && checkin.map > 0) {
//                graphPoints.append(GraphPoint(x: checkinTime, y: checkin.map));
//                plottedCheckins.append(checkin);
//                if (checkin.diastolic != nil && checkin.diastolic > 0) {
//                    diastolicPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.diastolic!)));
//                } else {
//                    diastolicPoints.append(GraphPoint(x: checkinTime, y: 0));
//                }
//                if (checkin.systolic != nil && checkin.systolic > 0) {
//                    systolicPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.systolic!)));
//                } else {
//                    systolicPoints.append(GraphPoint(x: checkinTime, y: 0));
//                }
//            }
//            if (type == MetricsType.Weight && checkin.weightLbs != nil && checkin.weightLbs > 0) {
//                if (checkin.fatRatio > 0) {
//                    bodyFatPoints.append(GraphPoint(x: checkinTime, y: checkin.fatRatio));
//                }
//                graphPoints.append(GraphPoint(x: checkinTime, y: checkin.weightLbs));
//                plottedCheckins.append(checkin);
//            }
//            if (type == MetricsType.Pulse && checkin.pulseBpm != nil && checkin.pulseBpm > 0) {
//                graphPoints.append(GraphPoint(x: checkinTime, y: Double(checkin.pulseBpm!)));
//                plottedCheckins.append(checkin);
//            }
//        }
//        
//        if (type == MetricsType.DailySummary) {
//            var activityPoints:[GraphPoint] = [];
//            let dateString = Constants.dateFormatter.stringFromDate(NSDate());
//            var totalPoints = 0;
//            for (date, (total, activityList)) in SessionController.Instance.activities {
//                if (date == dateString) {
//                    totalPoints = total;
//                }
//                if (activityList.count > 0) {
//                    let activityDate =  Double(activityList[0].startTime.timeIntervalSince1970);
//                    plottedActivities.append((activityDate, total));
//                    graphPoints.append(GraphPoint(x: activityDate, y: Double(total)));
//                }
//            }
//            plottedActivities.sort({$0.0 < $1.0});
//            graphPoints.sort({$0.x < $1.x});
//        }
//        
//        //        let graphY = headerView.frame.size.height;
//        let graphY:CGFloat = 0;
//        let graphWidth = UIScreen.mainScreen().bounds.size.width;
//        let graphHeight:CGFloat = frame.size.height - headerView.frame.size.height - (frame.size.height - 267);
//        if (type == MetricsType.BloodPressure) {
//            graph = MetricGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints, diastolicPoints: diastolicPoints, systolicPoints: systolicPoints);
//        } else if (type == MetricsType.Weight) {
//            graph = MetricGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints);
//            secondaryGraph = MetricGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: bodyFatPoints);
//            secondaryGraph.setupForMetric(type, isBodyFat: true);
//            secondaryGraph.backgroundColor = UIColor.whiteColor();
//            self.graphContainer.addSubview(secondaryGraph);
//        } else {
//            graph = MetricGraph(frame: CGRect(x: 0, y: graphY, width: graphWidth, height: graphHeight), points: graphPoints);
//        }
//        graph.setupForMetric(type, isBodyFat: false);
//        graph.backgroundColor = UIColor.whiteColor();
//        graph.userInteractionEnabled = true;
//        self.graphContainer.addSubview(graph);
//        
//        setSelected(graphPoints.count - 1);
//    }
   
}