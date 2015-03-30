#import <Foundation/Foundation.h>
#import "NewCPTPlotRange.h"

@implementation NewCPTPlotRange

-(id)initWithLocation:(double)loc length:(double)len {
    return [super initWithLocation:CPTDecimalFromDouble(loc) length:CPTDecimalFromDouble(len)];
}

@end
