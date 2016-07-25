import Foundation

final class MetricGraphUtility {
    
    class func graphWithPoints(frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint], color: UIColor, secondaryColor: UIColor?) -> MetricGraph {
        let graph = MetricGraph(frame: frame, points: points, altPoints: altPoints);
        graph.setupForMetric(color, secondaryColor: secondaryColor);
        return graph;
    }
}