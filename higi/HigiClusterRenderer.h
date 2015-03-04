#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GClusterRenderer.h"

@interface HigiClusterRenderer : NSObject <GClusterRenderer>

- (id)initWithMapView:(GMSMapView*)googleMap;

@end
