#import "GClusterManager.h"

@implementation GClusterManager {
    GMSCameraPosition *previousCameraPosition;
    GMSMarker *selectedMarker;
    UIImage *selectedIcon;
}

- (void)setMapView:(GMSMapView*)mapView {
    previousCameraPosition = nil;
    _mapView = mapView;
}

- (void)setClusterAlgorithm:(id <GClusterAlgorithm>)clusterAlgorithm {
    previousCameraPosition = nil;
    _clusterAlgorithm = clusterAlgorithm;
}

- (void)setClusterRenderer:(id <GClusterRenderer>)clusterRenderer {
    previousCameraPosition = nil;
    _clusterRenderer = clusterRenderer;
}

- (void)addItem:(id <GClusterItem>) item {
    [_clusterAlgorithm addItem:item];
}

- (void)removeItems {
  [_clusterAlgorithm removeItems];
}

- (void)cluster {
    NSSet *clusters = [_clusterAlgorithm getClusters:_mapView];
    [_clusterRenderer clustersChanged:clusters];
}

- (void) setSelectedMarker:(CLLocationCoordinate2D) position {
    [_clusterRenderer setSelectedMarker:position];
    [self cluster];
}

#pragma mark mapview delegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    assert(mapView == _mapView);
    
//        CLLocation *previousLocation = [[CLLocation alloc]initWithLatitude:previousCameraPosition.target.latitude longitude:previousCameraPosition.target.longitude];
//        CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:cameraPosition.target.latitude longitude:cameraPosition.target.longitude];
//
//        CLLocationDistance dist = [previousLocation distanceFromLocation:currentLocation];
    //only cluster on pan of 5dp or more
//    if (previousCameraPosition == nil || [previousLocation distanceFromLocation:currentLocation] > 4) {
        previousCameraPosition = [mapView camera];
        [self cluster];
//    }
}

-(BOOL) mapView:(GMSMapView *) mapView didTapMarker:(GMSMarker *)marker {
    //markers have data, clusters do not
    if (marker.userData != nil) {
        [_delegate markerSelected: marker];
    } else {
        [_delegate clusterSelected: marker];
    }

    return YES;
}

#pragma mark convenience

+ (instancetype)managerWithMapView:(GMSMapView*)googleMap
                         algorithm:(id<GClusterAlgorithm>)algorithm
                          renderer:(id<GClusterRenderer>)renderer {
    GClusterManager *mgr = [[[self class] alloc] init];
    if(mgr) {
        mgr.mapView = googleMap;
        mgr.clusterAlgorithm = algorithm;
        mgr.clusterRenderer = renderer;
    }
    
    return mgr;
}

@end
