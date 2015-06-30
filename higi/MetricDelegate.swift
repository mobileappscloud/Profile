import Foundation

protocol MetricDelegate {
    
    func getTitle() -> String;
    
    func getColor() -> UIColor;
    
    func getIcon() -> UIImage;
    
    func getType() -> MetricsType;
    
    func setSelected(date: NSDate);
    
    func getSelectedPoint() -> MetricCard.SelectedPoint?;
    
    func getGraph(frame: CGRect) -> MetricGraph;
    
    func getRanges(tab: Int) -> [MetricGauge.Range];
    
    func getCopyImage(tab: Int) -> UIImage?;
    
    func getBlankStateImage() -> UIImage;
    
    func getSelectedValue(tab: Int) -> String;
    
    func getSelectedUnit(tab: Int) -> String;
    
    func shouldShowRegions() -> Bool;
}