//
//  NewCPTScatterPlotDelegate.m
//  higi
//
//  Created by Dan Harms on 7/18/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

#import "NewCPTScatterPlotDelegate.h"

@implementation NewCPTScatterPlotDelegate

-(void) scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx {
    [self symbolSelected:plot index:(int)idx];
}

-(void) symbolSelected:(CPTScatterPlot *)plot index:(int)index {
    
}
@end
