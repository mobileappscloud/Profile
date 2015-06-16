import Foundation

class WeightMetricCard: MetricCard {
    
    override func getTitle() -> String {
        return MetricsType.Weight.getTitle();
    }
    
    override func getColor() -> UIColor {
        return MetricsType.Weight.getColor();
    }
    
    override func getIcon() -> UIImage {
        return Utility.imageWithColor(UIImage(named: "weighticon")!, color: UIColor.whiteColor());
    }
}