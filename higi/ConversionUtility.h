//
//  NewCPTAxis.h
//  higi
//
//  Created by Dan Harms on 6/25/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"

@interface ConversionUtility : NSObject

+(void) setMajorIntervalDoubleLength:(double)majorIntervalLength axis:(CPTXYAxis *)axis;
+(void) setMinorTicksPerIntervalDouble:(double)minorTicksPerInterval axis:(CPTXYAxis *)axis;
+(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate;
@end
