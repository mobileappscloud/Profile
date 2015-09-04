import Foundation

class Utility {
    
    class func colorFromHexString(hexString: NSString) -> UIColor {
        var rgbValue: CUnsignedInt;
        rgbValue = 0;
        var scanner = NSScanner(string: hexString as String);
        scanner.scanLocation = 1;
        scanner.scanHexInt(&rgbValue);
        return UIColor(red: (CGFloat)((rgbValue & 0xFF0000) >> 16) / 255.0, green:(CGFloat)((rgbValue & 0xFF00) >> 8) / 255.0, blue:(CGFloat)(rgbValue & 0xFF) / 255.0, alpha:1.0);
    }
    
    class func getViewController(view: UIView) -> UIViewController? {
        var responder: UIResponder? = view.nextResponder();
        while (responder != nil) {
            if (responder!.isKindOfClass(UIViewController)) {
                return responder as? UIViewController;
            }
            responder = responder!.nextResponder();
        }
        return nil;
    }
    
    class func gotoDashboard(viewController: UIViewController) {
        var dashboardController = DashboardViewController(nibName: "DashboardView", bundle: nil);
        var navController = MainNavigationController(rootViewController: dashboardController);
        var drawerController = DrawerViewController(nibName: "DrawerView", bundle: nil);
        var revealController = RevealViewController(rearViewController: drawerController, frontViewController: navController);
        drawerController.navController = navController;
        drawerController.revealController = revealController;
        navController.revealController = revealController;
        navController.drawerController = drawerController;
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController = revealController;
        if (SessionData.Instance.pin != "") {
            revealController.presentViewController(PinCodeViewController(nibName: "PinCodeView", bundle: nil), animated: false, completion: nil);
        }
    }
    
    class func scaleImage(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale);
        image.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    class func iphone5Image(named: String) -> UIImage {
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone && UIScreen.mainScreen().bounds.size.height == 568) {
            return UIImage(named: "\(named)-568h")!;
        } else {
            return UIImage(named: named)!;
        }
    }
    
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as NSString as String) as! String
    }
    
    class func loadImageFromUrl(imageUrlString: String) -> NSURL {
        let imageUrl = NSURL(string: imageUrlString);
        if let imageError = imageUrl?.checkResourceIsReachableAndReturnError(NSErrorPointer()) {
            return imageUrl!;
        }
        return NSURL();
    }

    class func heightForTextView(width: CGFloat, text: String, fontSize: CGFloat, margin: CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.max));
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        label.font = UIFont.systemFontOfSize(fontSize);
        label.text = text;
        
        label.sizeToFit();
        return label.frame.height + margin;
    }
    
    class func widthForTextView(height: CGFloat, text: String, fontSize: CGFloat, margin: CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.max, height: height));
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        label.font = UIFont.systemFontOfSize(fontSize);
        label.text = text;
        
        label.sizeToFit();
        return label.frame.height + margin;
    }
    
    class func htmlDecodeString(encodedString: String) -> String {
        let encodedData = encodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)!;
        
        return attributedString.string;
    }
    
    class func imageWithColor(image: UIImage, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        let context = UIGraphicsGetCurrentContext() as CGContextRef;
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        let rect = CGRectMake(0, 0, image.size.width, image.size.height) as CGRect;
        CGContextClipToMask(context, rect, image.CGImage);
        color.setFill();
        CGContextFillRect(context, rect);
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    class func growAnimation(view: UIView, startHeight: CGFloat, endHeight: CGFloat) {
        view.frame.size.height = startHeight;
        view.layoutIfNeeded();
        UIView.animateWithDuration(1, animations: {
            view.frame.size.height = endHeight;
        }, completion: nil)
    }
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    class func stringIndexOf(haystack: String, needle: Character) -> Int {
        var i = 0;
        for char in Array(haystack) {
            if char == needle {
                return i;
            }
            i++;
        }
        return -1;
    }
}