//
//  NewCPTPlotRange.h
//  higi
//
//  Created by Dan Harms on 6/12/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

#import <CorePlot/CorePlot-CocoaTouch.h>

@interface NewCPTPlotRange : CPTPlotRange

-(id)initWithLocation:(double)loc length:(double)len;

@end