import Foundation

class WeightMetricCard: MetricCard {
    
    override func getTitle() -> String {
        return "Weight";
    }
    
    override func getColor() -> UIColor {
        return Utility.colorFromMetricType(MetricsType.Weight);
    }
    
    override func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "weighticon")!, color: UIColor.whiteColor());
    }
    
}