//
//  NewCPTPlotRange.m
//  higi
//
//  Created by Dan Harms on 6/12/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewCPTPlotRange.h"

@implementation NewCPTPlotRange

-(id)initWithLocation:(double)loc length:(double)len {
    return [super initWithLocation:CPTDecimalFromDouble(loc) length:CPTDecimalFromDouble(len)];
}

@end
