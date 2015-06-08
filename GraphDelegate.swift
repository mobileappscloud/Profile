import Foundation

protocol GraphDelegate {
    
    func getColor() -> UIColor;
    
    func getTitle() -> String;
    
    func createGraphWithCheckins(frame: CGRect, checkins: [HigiCheckin]) -> BaseGraphHostingView?;
    
    func createGraphWithActivities(frame: CGRect, activities: [HigiActivity]) -> BaseGraphHostingView?;
}