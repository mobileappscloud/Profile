#import <UIKit/UIKit.h>

@protocol ClusterManagerDelegate <GMSMapViewDelegate>

-(void)markerSelected:(GMSMarker*) marker;

-(void)clusterSelected:(GMSMarker*) cluster;

-(void)onMapPan;

@end