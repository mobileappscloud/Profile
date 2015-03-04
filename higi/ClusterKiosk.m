#import "ClusterKiosk.h"

@implementation ClusterKiosk : NSObject

- (CLLocationCoordinate2D)position {
    return location;
}

- (void)setPosition:(CLLocationCoordinate2D)pos {
    location = pos;
}

-(NSObject*)data {
    return data;
}

-(void)setData:(NSObject*)obj {
    data = obj;
}

@end