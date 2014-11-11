//
//  NewCPTAxis.m
//  higi
//
//  Created by Dan Harms on 6/25/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

#import "ConversionUtility.h"

@implementation ConversionUtility

+(void) setMajorIntervalDoubleLength:(double)majorIntervalLength axis:(CPTXYAxis *)axis {
    axis.majorIntervalLength = CPTDecimalFromDouble(majorIntervalLength);
}

+(void) setMinorTicksPerIntervalDouble:(double)minorTicksPerInterval axis:(CPTXYAxis *)axis {
    axis.minorTicksPerInterval = minorTicksPerInterval;
}

+(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate {
    
    CPTPlotRange *updatedRange = nil;
    
    switch (coordinate) {
        case CPTCoordinateX:
            if (newRange.locationDouble < 0.0F) {
                CPTMutablePlotRange *mutableRange = [newRange mutableCopy];
                mutableRange.location = CPTDecimalFromFloat(0.0);
                updatedRange = mutableRange;
            }
            else {
                updatedRange = newRange;
            }
            break;
        case CPTCoordinateY:
            updatedRange = ((CPTXYPlotSpace *)space).yRange;
            break;
        default:
            break;
    }
    return updatedRange;
}

@end
