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
//    
//    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
//        if (plot.isEqual(self.plot)) {
//            return selectedPointIndex == Int(idx) ? selectedPlotSymbol : plotSymbol;
//        } else {
//            if (idx % 2 == 1) {
//                if (Int(idx) == ((selectedPointIndex * 2) + 1)) {
//                    return selectedAltPlotSymbol;
//                }
//            } else {
//                if (altPoints.count > 0 && !altPlotLinesAdded) {
//                    let systolicPoint = altPoints[Int(idx)];
//                    let diastolicPoint = altPoints[Int(idx) + 1];
//                    let screenSystolicPoint = getScreenPoint(self, xPoint: CGFloat(systolicPoint.x), yPoint: CGFloat(systolicPoint.y));
//                    let screenDiastolicPoint = getScreenPoint(self, xPoint: CGFloat(diastolicPoint.x), yPoint: CGFloat(diastolicPoint.y));
//                    
//                    let view = UIView(frame: CGRect(x: screenSystolicPoint.x - 0.5, y: self.frame.size.height - CGFloat(screenSystolicPoint.y) - 24, width: 1, height: CGFloat(screenSystolicPoint.y - screenDiastolicPoint.y)));
//                    view.backgroundColor = plotSymbol.lineStyle.lineColor.uiColor;
//                    addSubview(view);
//                    if (Int(idx) == altPoints.count - 2) {
//                        altPlotLinesAdded = true;
//                    }
//                }
//                if (Int(idx) == (selectedPointIndex * 2)) {
//                    return selectedAltPlotSymbol;
//                }
//            }
//            return unselectedAltPlotSymbol;
//        }
//    }
}