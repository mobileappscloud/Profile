//
// Third-party includes
//

// AFNetworking (NSURLConnection Wrapper & Helpers)
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

// Core Plot (Graphing Library)
#import "CorePlot-CocoaTouch.h"
#import "CPTPlotRange+SwiftCompatibility.h"
#import "CPTScatterPlot+SwiftCompatibility.h"
// User defined extensions
#import "HIGIScatterPlot.h"

// Facebook SDK
#import <FBSDKCoreKit/FBSDKCoreKit.h>

// Feed Parsing Utility
#import "NSString+HTML.h"

// Flurry Mobile Analytics
#import "Flurry.h"

// Google Maps SDK
#import <GoogleMaps/GoogleMaps.h>

// Google Maps Utility
#import "ClusterManagerDelegate.h"
#import "GClusterManager.h"
#import "NonHierarchicalDistanceBasedAlgorithm.h"
// User defined extensions
#import "ClusterKiosk.h"
#import "HigiClusterRenderer.h"

// TTTAttributedLabel (Replacement for UILabel with support for custom links)
#import "TTTAttributedLabel.h"

//
// Copied third-party includes, manually managed
//

#import "UIImage+Orientation.h"

//
// Custom includes
//

// Obj-C category to return UIInterfaceOrientation while silencing deprecation warning
#import "UIViewController+InterfaceOrientation.h"

// UITextView subclass which automatically resizes to fit content
#import "RGPAutoResizingTextView.h"
