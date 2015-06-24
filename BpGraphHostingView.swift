import Foundation

class BPGraphHostingView: BaseGraphHostingView {
    
    var altPoints: [GraphPoint];
    
    var altPlot: NewCPTScatterPlot;
    
    init(frame: CGRect, points: [GraphPoint], altPoints: [GraphPoint]) {
        self.altPoints = altPoints;
        //        self.altPoints.append(GraphPoint(x: Double(NSDate().timeIntervalSince1970), y: altPoints.last!.y));
        altPlot = NewCPTScatterPlot(frame: CGRectZero);
        super.init(frame: frame, points: points);
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}