#import <UIKit/UIKit.h>

@protocol ClusterManagerDelegate <GMSMapViewDelegate>

-(void)markerSelected:(GMSMarker*) marker;

@optional
-(void)clusterSelected:(GMSMarker*) cluster;

@end