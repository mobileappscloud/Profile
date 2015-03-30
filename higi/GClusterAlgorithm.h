#import <Foundation/Foundation.h>
#import "GClusterItem.h"

@protocol GClusterAlgorithm <NSObject>

- (void)addItem:(id <GClusterItem>) item;
- (void)removeItems;

- (NSSet*)getClusters:(GMSMapView*) map;

@end
