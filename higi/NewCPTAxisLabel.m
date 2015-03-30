#import "NewCPTAxisLabel.h"

@implementation NewCPTAxisLabel

-(void) setTickIndex: (double)loc {
    self.tickLocation = CPTDecimalFromDouble(loc);
}

@end
