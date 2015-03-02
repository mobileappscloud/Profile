#import "GClusterKiosk.h"

@implementation GClusterKiosk : NSObject

- (CLLocationCoordinate2D)position {
    return location;
}

- (void)setPosition:(CLLocationCoordinate2D)pos {
    location = pos;
}

@end