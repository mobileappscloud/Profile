//
//  NewMetricPlotDelegate.swift
//  higi
//
//  Created by Remy Panicker on 2/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class NewMetricPlotDelegate: NSObject {
    
    var metricDelegate: NewMetricDelegate? = nil
    
    var points: [GraphPoint] = []
    
    var selectedIndex: Int = 0
    
    let unselectedPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: UIColor.whiteColor(), lineStyle: CPTMutableLineStyle(color: Theme.Color.Metrics.primary, lineWidth: 2.0), size: 8.0)
    
    let altUnselectedPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: UIColor.whiteColor(), lineStyle: CPTMutableLineStyle(color: Theme.Color.Metrics.secondary, lineWidth: 2.0), size: 8.0)
    
    let selectedPlotSymbol = CPTPlotSymbol.plotSymbol(CPTPlotSymbolTypeEllipse, fillColor: Theme.Color.Metrics.secondary, lineStyle: CPTMutableLineStyle(color: Theme.Color.Metrics.secondary, lineWidth: 2.0), size: 10.0)
}

extension NewMetricPlotDelegate: CPTPlotDataSource {
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return UInt(self.points.count)
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        let index = Int(idx)
        let point = points[index]
        let coordinate = CPTCoordinate(UInt32(fieldEnum))
        let number = (coordinate == CPTCoordinateX) ? point.x : point.y
        return NSNumber(double: number)
    }
}

extension NewMetricPlotDelegate: CPTScatterPlotDataSource {
    
    func symbolForScatterPlot(plot: CPTScatterPlot!, recordIndex idx: UInt) -> CPTPlotSymbol! {
        let index = Int(idx)
        
        if let delegate = metricDelegate as? NewBloodPressureMetricDelegate {
            if plot.identifier.isEqual(delegate.systolicPlotIdentifier) {
                return delegate.selectedIndex == index ? selectedPlotSymbol : unselectedPlotSymbol
            } else if plot.identifier.isEqual(delegate.diastolicPlotIdentifier) {
                return delegate.selectedIndex == index ? selectedPlotSymbol : altUnselectedPlotSymbol
            }
        }
        return metricDelegate?.selectedIndex == index ? selectedPlotSymbol : unselectedPlotSymbol
    }
}

extension NewMetricPlotDelegate: CPTScatterPlotDelegate {
    
    func scatterPlot(plot: CPTScatterPlot!, plotSymbolWasSelectedAtRecordIndex idx: UInt) {
        let index = Int(idx)
        metricDelegate?.selectedIndex = index
        for graphPlot in plot.graph!.allPlots() {
            graphPlot.reloadData()
        }
        metricDelegate?.plotForwardDelegate?.graphHostingView(plot, selectedPointAtIndex: index)
    }
}

extension NewMetricPlotDelegate: CPTPlotSpaceDelegate {
    
    func plotSpace(space: CPTPlotSpace!, willChangePlotRangeTo newRange: CPTPlotRange!, forCoordinate coordinate: CPTCoordinate) -> CPTPlotRange! {
        if (coordinate == CPTCoordinateY) {
            if let space = space as? CPTXYPlotSpace {
                return space.yRange
            }
        }
        return newRange
    }
}
