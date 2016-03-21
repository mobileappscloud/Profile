#import <CoreText/CoreText.h>
#import "HigiClusterRenderer.h"
#import "GQuadItem.h"
#import "GCluster.h"
#import "GClusterItem.h"

@implementation HigiClusterRenderer {
    GMSMapView *_map;
    NSMutableArray *_markerCache;
    UIImage *selectedIcon;
    UIImage *unselectedIcon;
    CLLocationCoordinate2D selectedMarkerPosition;
}

- (id)initWithMapView:(GMSMapView*)googleMap {
    if (self = [super init]) {
        _map = googleMap;
        _markerCache = [[NSMutableArray alloc] init];
        unselectedIcon = [self scaleImage:[UIImage imageNamed:@"map-circle-icon"] size:CGSizeMake(50, 50)];
        selectedIcon = [self scaleImage:[UIImage imageNamed:@"map-icon-dot"] size:CGSizeMake(50, 50)];
    }
    return self;
}

- (void)setSelectedMarker:(CLLocationCoordinate2D) position {
    selectedMarkerPosition = position;
}

- (void)clustersChanged:(NSSet*)clusters {
    [_map clear];
    
    [_markerCache removeAllObjects];
    
    for (id <GCluster> cluster in clusters) {
        GMSMarker *marker;
        marker = [[GMSMarker alloc] init];
        
        [_markerCache addObject:marker];
        
        NSUInteger count = cluster.items.count;
        if (count > 1) {
            marker.icon = [self generateClusterIconWithCount:count];
        } else {
            if (selectedMarkerPosition.latitude == cluster.position.latitude && selectedMarkerPosition.longitude == cluster.position.longitude) {
                marker.icon = selectedIcon;
            } else {
                marker.icon = unselectedIcon;
            }
            //how do you get a single item from nsset?
            for (id <GClusterItem> clusterItem in cluster.items) {
                marker.userData = clusterItem.data;
            }
        }
        marker.position = cluster.position;
        marker.map = _map;
    }
}

- (UIImage*) generateClusterIconWithCount:(NSUInteger)count {
    
    int diameter = 40;
    float inset = 3;
    
    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // set stroking color and draw circle
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] setStroke];
    [[UIColor colorWithRed:0.463 green:0.753 blue:0.267 alpha:1] setFill];  /* #76c043 */
    
    CGContextSetLineWidth(ctx, inset);
    
    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(0, 0, diameter, diameter);
    circleRect = CGRectInset(circleRect, inset, inset);
    
    // draw circle
    CGContextFillEllipseInRect(ctx, circleRect);
    CGContextStrokeEllipseInRect(ctx, circleRect);
    
    CTFontRef myFont = CTFontCreateWithName( (CFStringRef)@"Helvetica-Bold", 16.0f, NULL);
    if (count > 999) {
        myFont = CTFontCreateWithName( (CFStringRef)@"Helvetica-Bold", 12.0f, NULL);
    }
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)myFont, (id)kCTFontAttributeName,
                                    [UIColor whiteColor], (id)kCTForegroundColorAttributeName, nil];
    
    // create a naked string
    NSString *string = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)count];
    
    NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:string
                                                                       attributes:attributesDict];
    // flip the coordinate system
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, diameter);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(stringToDraw));
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                                        frameSetter, /* Framesetter */
                                                                        CFRangeMake(0, stringToDraw.length), /* String range (entire string) */
                                                                        NULL, /* Frame attributes */
                                                                        CGSizeMake(diameter, diameter), /* Constraints (CGFLOAT_MAX indicates unconstrained) */
                                                                        NULL /* Gives the range of string that fits into the constraints, doesn't matter in your situation */
                                                                        );
    CFRelease(frameSetter);
    
    //Get the position on the y axis
    float midHeight = diameter / 2;
    midHeight -= suggestedSize.height / 2 - 4;
    
    float midWidth = diameter / 2;
    midWidth -= suggestedSize.width / 2;
    
    CTLineRef line = CTLineCreateWithAttributedString(
                                                      (__bridge CFAttributedStringRef)stringToDraw);
    CGContextSetTextPosition(ctx, midWidth, midHeight);
    CTLineDraw(line, ctx);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*) scaleImage:(UIImage*)image size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end