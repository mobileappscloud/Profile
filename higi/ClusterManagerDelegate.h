#import <UIKit/UIKit.h>

@protocol ClusterManagerDelegate <GMSMapViewDelegate>

@optional
-(void)markerSelected:(GMSMarker*) marker;
-(void)clusterSelected:(GMSMarker*) cluster;
@end