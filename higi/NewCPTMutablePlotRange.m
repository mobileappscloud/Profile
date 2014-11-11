//
//  NewCPTMutablePlotRange.m
//  higi
//
//  Created by Dan Harms on 6/23/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

#import "NewCPTMutablePlotRange.h"

@implementation NewCPTMutablePlotRange

-(void) setDecimalLocation: (double)location {
    self.location = CPTDecimalFromDouble(location);
}

@end
