#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GClusterAlgorithm.h"
#import "GClusterRenderer.h"
#import "GQTPointQuadTreeItem.h"
#import "ClusterManagerDelegate.h"

@interface GClusterManager : NSObject <ClusterManagerDelegate>

@property(nonatomic, strong) GMSMapView *mapView;
@property(nonatomic, strong) id<GClusterAlgorithm> clusterAlgorithm;
@property(nonatomic, strong) id<GClusterRenderer> clusterRenderer;
@property id<ClusterManagerDelegate> delegate;

- (void)addItem:(id <GClusterItem>) item;
- (void)removeItems;
- (void)cluster;
- (void)setSelectedMarker:(CLLocationCoordinate2D) position;

//convenience
+ (instancetype)managerWithMapView:(GMSMapView*)googleMap
                         algorithm:(id<GClusterAlgorithm>)algorithm
                          renderer:(id<GClusterRenderer>)renderer;

@end
