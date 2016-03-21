import Foundation

protocol MetricDelegate {
    
    func getTitle() -> String;
    
    func getColor() -> UIColor;
    
    func getSecondaryColor() -> UIColor?;
        
    func getType() -> MetricsType;
    
    func setSelected(date: NSDate);
    
    func getRanges(tab: Int) -> [MetricGauge.Range];
    
    func getBlankStateText() -> String;
    
    func getSelectedValue(tab: Int) -> String;
    
    func getSelectedUnit(tab: Int) -> String;
    
    func getSelectedClass(tab: Int) -> String;
    
    func colorFromClass(className: String, tab: Int) -> UIColor;
    
    func shouldShowRegions() -> Bool;
}
