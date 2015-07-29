import Foundation

class MetricGraphUtility {
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], color: UIColor) -> MetricGraph {
        let graph = MetricGraph(frame: frame, points: points);
        graph.setupForMetric(color);
        return graph;
    }
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint], color: UIColor) -> MetricGraph {
        let graph = MetricGraph(frame: frame, points: points, altPoints: altPoints);
        graph.setupForMetric(color);
        return graph;
    }
}