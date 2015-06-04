import Foundation

protocol MetricDelegate {
    
    func getTitle() -> String;
    
    func getColor() -> UIColor;
    
    func getIcon() -> UIImage;
    
    func getType() -> MetricsType;
    
    func setSelected(date: NSDate);
    
    func getSelectedPoint() -> MetricCard.SelectedPoint;
}