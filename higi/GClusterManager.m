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

#pragma mark mapview delegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    assert(mapView == _mapView);
    
    // Don't re-compute clusters if the map has just been panned/tilted/rotated.
    GMSCameraPosition *position = [mapView camera];
    if (previousCameraPosition != nil && previousCameraPosition.zoom == position.zoom) {
        return;
    }
    previousCameraPosition = [mapView camera];
    
    [self cluster];
}

-(BOOL) mapView:(GMSMapView *) mapView didTapMarker:(GMSMarker *)marker
{
    //hacky way to know if we clicked a marker or not
    if (marker.icon.size.height == 15) {
        if (selectedMarker == nil) {
            selectedMarker = [[GMSMarker alloc] init];
            selectedIcon = [self scaleImage:[UIImage imageNamed:@"map_iconwithdot"] size:CGRectMake(0, 0, 45, 45)];
            selectedMarker.icon = selectedIcon;
        }
        
        selectedMarker.position = marker.position;
        selectedMarker.map = mapView;
        
        NSUInteger count = selectedMarker.userData[@"item"];
        
        [_delegate markerSelected: marker];
    } else {
        //todo zoom a bit
        [_delegate clusterSelected: marker];
    }
    
    CGPoint point = [mapView.projection pointForCoordinate:marker.position];
    GMSCameraUpdate *camera = [GMSCameraUpdate setTarget:[mapView.projection coordinateForPoint:point]];
    [mapView animateWithCameraUpdate:camera];

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

- (UIImage*) scaleImage:(UIImage*)image size:(CGRect)size {
    CGRect rect = size;
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(tempImage);
    return [UIImage imageWithData:imageData];
}

@end
