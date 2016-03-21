//
//  HigiScatterPlot+Utility.swift
//  higi
//
//  Created by Remy Panicker on 2/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension HIGIScatterPlot {
    
    convenience init(color: UIColor, hitMargin: Double, plotSymbol: CPTPlotSymbol, dataSource: CPTPlotDataSource, delegate: CPTPlotDelegate) {
        self.init(frame: CGRectZero)
        
        self.dataSource = dataSource
        self.delegate = delegate
        
        self.interpolation = CPTScatterPlotInterpolationCurved
        self.setAreaBaseDecimalValue(0.0)
        self.plotSymbolMarginForHitDetection = CGFloat(hitMargin)
        
        self.plotSymbol = plotSymbol
        
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor)
        lineStyle.lineWidth = 2.0
        self.dataLineStyle = lineStyle
    }
    
    
    convenience init(secondaryPlotWithPoints altPoints: [GraphPoint], color: UIColor?, hitMargin: Double, dataSource: CPTPlotDataSource, delegate: CPTPlotDelegate) {
        self.init(frame: CGRectZero)
        
        self.dataSource = dataSource
        self.delegate = delegate
        
        self.setAreaBaseDecimalValue(0)
        self.plotSymbolMarginForHitDetection = CGFloat(hitMargin)
        
        if (altPoints[0].x == altPoints[1].x) {
            self.interpolation = CPTScatterPlotInterpolationLinear
            
            let unselectedAltPlotLineStyle = CPTMutableLineStyle()
            if let color = color {
                unselectedAltPlotLineStyle.lineColor = CPTColor(CGColor: color.CGColor)
            }
            self.dataLineStyle = unselectedAltPlotLineStyle
            
        } else if (altPoints[0].y == altPoints[1].y) {
            self.interpolation = CPTScatterPlotInterpolationCurved
            
            let lineStyle = CPTMutableLineStyle()
            if let color = color {
                lineStyle.lineColor = CPTColor(CGColor: color.CGColor)
            }
            lineStyle.lineWidth = 2.0
            self.dataLineStyle = lineStyle
            
            self.plotSymbol = nil
            
        } else {
            self.interpolation = CPTScatterPlotInterpolationCurved
            
            let altSymbolLineStyle = CPTMutableLineStyle()
            altSymbolLineStyle.lineWidth = 2
            if let color = color {
                altSymbolLineStyle.lineColor = CPTColor(CGColor: color.CGColor)
            }
            self.dataLineStyle = altSymbolLineStyle
            
            let noSymbol = CPTPlotSymbol.ellipsePlotSymbol()
            noSymbol.size = CGSize(width: 0, height: 0)
            self.plotSymbol = noSymbol
        }
    }
}
