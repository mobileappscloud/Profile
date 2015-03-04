#import <UIKit/UIKit.h>

@protocol ClusterManagerDelegate <GMSMapViewDelegate>

@optional
-(void)markerSelected:(GMSMarker*) marker;

@optional
-(void)clusterSelected:(GMSMarker*) cluster;
@end