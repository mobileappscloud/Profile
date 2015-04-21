#import "CoreLocation/CoreLocation.h"
#import "GClusterItem.h"

@interface ClusterKiosk : NSObject<GClusterItem> {
    CLLocationCoordinate2D location;
    NSObject *data;
}

- (CLLocationCoordinate2D)position;

- (void)setPosition:(CLLocationCoordinate2D)pos;

- (NSObject*)data;

- (void)setData:(NSObject*)data;

@end