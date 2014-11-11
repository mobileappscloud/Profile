//
//  NewCPTScatterPlotDelegate.h
//  higi
//
//  Created by Dan Harms on 7/18/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CorePlot/CorePlot-CocoaTouch.h>

@interface NewCPTScatterPlotDelegate : NSObject <CPTScatterPlotDelegate>

-(void) symbolSelected:(CPTScatterPlot *)plot index:(int)index;

@end
