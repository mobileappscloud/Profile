//
//  CPTXYAxis+Utility.swift
//  higi
//
//  Created by Remy Panicker on 2/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension CPTXYAxis {
    
    func configureAxisX(visibleRange: CPTPlotRange) {
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.grayColor()
        axisTextStyle.fontSize = 8.0
        self.labelTextStyle = axisTextStyle
        
        self.majorTickLineStyle = nil
        self.minorTickLineStyle = nil
        
        self.visibleRange = visibleRange
        
        self.axisConstraints = CPTConstraints(lowerOffset: 0.0)
        self.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions
        self.preferredNumberOfMajorTicks = 5
        self.axisLineStyle = nil
        self.labelOffset = 0.0
        self.tickDirection = CPTSignPositive
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        self.labelFormatter = CustomFormatter(dateFormatter: dateFormatter)
    }
    
    func configureAxisY(visibleRange: CPTPlotRange, gridLinesRange: CPTPlotRange, labelExclusionRanges: [CPTPlotRange]) {
        
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.grayColor()
        axisTextStyle.fontSize = 8.0
        self.labelTextStyle = axisTextStyle
        
        self.majorTickLineStyle = nil
        self.minorTickLineStyle = nil
        
        self.visibleRange = visibleRange
        
        self.axisConstraints = CPTConstraints(lowerOffset: 0.0)
        self.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions
        self.preferredNumberOfMajorTicks = 5
        self.axisLineStyle = nil
        self.labelOffset = 0.0
        self.tickDirection = CPTSignPositive
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = 0
        self.labelFormatter = numberFormatter
        
        self.gridLinesRange = gridLinesRange
        
        self.labelExclusionRanges = labelExclusionRanges
    }
}
