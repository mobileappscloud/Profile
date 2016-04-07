import Foundation

class Utility {
    
    class func colorFromHexString(hexString: NSString) -> UIColor {
        var rgbValue: CUnsignedInt;
        rgbValue = 0;
        let scanner = NSScanner(string: hexString as String);
        scanner.scanLocation = 1;
        scanner.scanHexInt(&rgbValue);
        return UIColor(red: (CGFloat)((rgbValue & 0xFF0000) >> 16) / 255.0, green:(CGFloat)((rgbValue & 0xFF00) >> 8) / 255.0, blue:(CGFloat)(rgbValue & 0xFF) / 255.0, alpha:1.0);
    }
    
    class func mainTabBarController() -> TabBarController? {
        let appDelegate = AppDelegate.instance()
        guard let hostViewController = appDelegate.window?.rootViewController as? HostViewController else { return nil }
        
        return hostViewController.splashViewController.mainTabBarController
    }
    
    class func scaleImage(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale);
        image.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
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
        return NSURL(string: imageUrlString)!;
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
        let attributedString = try! NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil);
        
        return attributedString.string;
    }
    
    class func imageWithColor(image: UIImage, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        let context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, CGBlendMode.Normal);
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
        for char in Array(haystack.characters) {
            if char == needle {
                return i;
            }
            i += 1
        }
        return -1;
    }
}

extension Utility {
    
    /**
     Convenience method which compares two numeric strings and determines whether or not the minimum has been satisfied.
     
     - param minVersion: Numeric string which contains the minimum acceptable version.
     
     - returns: `true` if the current app version is greater than or equal to the `minVersion`
     */
    class func appMeetsMinimumVersionRequirement(minVersion: String) -> Bool {
        return Utility.appVersion(Utility.appVersion(), meetsMinimumVersionRequirement: minVersion)
    }
    
    /**
    Method which compares two numeric strings and determines whether or not the minimum has been satisfied.

    - param appVersion: Numeric string to test for minimum version compliance.
    - param minVersion: Numeric string which contains the minimum acceptable version.
    
    - returns: `true` if `appVersion` is greater than or equal to the `minVersion`
     */
    class func appVersion(appVersion: String, meetsMinimumVersionRequirement minVersion: String) -> Bool {
        let result = appVersion.compare(minVersion, options: NSStringCompareOptions.NumericSearch)
        return result == NSComparisonResult.OrderedDescending || result == NSComparisonResult.OrderedSame
    }
}

extension Utility {
    
    class func roundToLowest(number: Double, roundTo: Double) -> Double {
        var num = number
        if num < 0 {
            num -= roundTo
        }
        return Double(Int(num / roundTo) * Int(roundTo))
    }
    
    class func roundToHighest(number: Double, roundTo: Double) -> Double {
        return roundTo * Double(Int(ceil(number / roundTo)))
    }
}

extension Utility {

    class func organizationId() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("OrganizationId") as! String;
    }
}
