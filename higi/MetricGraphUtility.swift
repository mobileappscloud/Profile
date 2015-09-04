import Foundation

class MetricGraphUtility {
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], color: UIColor) -> MetricGraph {
        let graph = MetricGraph(frame: frame, points: points);
        graph.setupForMetric(color, secondaryColor: nil);
        return graph;
    }
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint], color: UIColor) -> MetricGraph {
        let graph = MetricGraph(frame: frame, points: points, altPoints: altPoints);
        graph.setupForMetric(color, secondaryColor: nil);
        return graph;
    }
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], color: UIColor, secondaryColor: UIColor?) -> MetricGraph {
        let graph = MetricGraph(frame: frame, points: points);
        graph.setupForMetric(color, secondaryColor: secondaryColor);
        return graph;
    }
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint], color: UIColor, secondaryColor: UIColor?) -> MetricGraph {
        let graph = MetricGraph(frame: frame, points: points, altPoints: altPoints);
        graph.setupForMetric(color, secondaryColor: secondaryColor);
        return graph;
    }
}