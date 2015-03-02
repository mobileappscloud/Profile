#import "CoreLocation/CoreLocation.h"
#import "GClusterItem.h"

@interface GClusterKiosk : NSObject<GClusterItem> {
    CLLocationCoordinate2D location;
}


- (CLLocationCoordinate2D)position;

- (void)setPosition:(CLLocationCoordinate2D)pos;
@end