//
//  CPTXYGraph+Utility.swift
//  higi
//
//  Created by Remy Panicker on 2/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension CPTXYGraph {
    
    convenience init(frame: CGRect, padding: Double, plotAreaFramePadding: Double) {
        self.init(frame: frame)
        
        let padding = CGFloat(padding)
        self.paddingLeft = padding
        self.paddingTop = padding
        self.paddingRight = padding
        self.paddingBottom = padding
        
        let plotAreaFramePadding = CGFloat(plotAreaFramePadding)
        self.plotAreaFrame.paddingTop = plotAreaFramePadding
        self.plotAreaFrame.paddingRight = plotAreaFramePadding
        self.plotAreaFrame.paddingLeft = plotAreaFramePadding
        
        self.plotAreaFrame.borderWidth = 0.0
        self.plotAreaFrame.borderLineStyle = nil
        
        self.borderWidth = 0.0
        self.borderLineStyle = nil
    }
}

extension CPTXYGraph {
    
    func getScreenPoint(x: Double, y: Double) -> CGPoint {
        return self.getScreenPoint(CGFloat(x), yPoint: CGFloat(y))
    }
    
    func getScreenPoint(xPoint: CGFloat, yPoint: CGFloat) -> CGPoint {
        guard let plotSpace = self.defaultPlotSpace as? CPTXYPlotSpace else { return .zero }
        
        let xRange = plotSpace.xRange;
        let yRange = plotSpace.yRange;
        
        let frame = self.frame;
        
        let x = ((xPoint - CGFloat(xRange.locationDouble)) / CGFloat(xRange.lengthDouble)) * frame.size.width;
        let y = (1.0 - ((yPoint - CGFloat(yRange.locationDouble)) / CGFloat(yRange.lengthDouble))) * (frame.size.height - 20);
        
        return CGPoint(x: x, y: y);
    }
}
