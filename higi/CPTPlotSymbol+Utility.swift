//
//  CPTPlotSymbol+Utility.swift
//  higi
//
//  Created by Remy Panicker on 2/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension CPTPlotSymbol {
    
    class func plotSymbol(type: _CPTPlotSymbolType, fillColor: UIColor, lineStyle: CPTLineStyle, size: Double) -> CPTPlotSymbol {
        var plotSymbol: CPTPlotSymbol!
        switch type {
        case CPTPlotSymbolTypeDash:
            plotSymbol = CPTPlotSymbol.dashPlotSymbol()
        case CPTPlotSymbolTypeEllipse:
            fallthrough
        default:
            plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        }
        plotSymbol.fill = CPTFill(color: CPTColor(CGColor: fillColor.CGColor))
        plotSymbol.lineStyle = lineStyle
        plotSymbol.size = CGSize(width: size, height: size)
        return plotSymbol
    }
}
