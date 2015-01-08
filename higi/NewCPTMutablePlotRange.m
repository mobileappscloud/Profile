#import "NewCPTMutablePlotRange.h"

@implementation NewCPTMutablePlotRange

-(void) setDecimalLocation: (double)location {
    self.location = CPTDecimalFromDouble(location);
}

@end
