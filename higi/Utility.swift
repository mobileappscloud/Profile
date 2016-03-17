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
            i++;
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

// MARK: URL Percent Encoding Extensions --> http://stackoverflow.com/a/24888789

extension NSCharacterSet {
    
    /// Returns the character set for characters allowed in the individual parameters within a query URL component.
    ///
    /// The query component of a URL is the component immediately following a question mark (?).
    /// For example, in the URL `http://www.example.com/index.php?key1=value1#jumpLink`, the query
    /// component is `key1=value1`. The individual parameters of that query would be the key `key1`
    /// and its associated value `value1`.
    ///
    /// According to RFC 3986, the set of unreserved characters includes
    ///
    /// `ALPHA / DIGIT / "-" / "." / "_" / "~"`
    ///
    /// In section 3.4 of the RFC, it further recommends adding `/` and `?` to the list of unescaped characters
    /// for the sake of compatibility with some erroneous implementations, so this routine also allows those
    /// to pass unescaped.
    
    
    class func URLQueryParameterAllowedCharacterSet() -> Self {
        return self.init(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~/?")
    }
    
}

extension String {
    
    /// Returns a new string made from the `String` by replacing all characters not in the unreserved
    /// character set (As defined by RFC3986) with percent encoded characters.
    
    func stringByAddingPercentEncodingForURLQueryParameter() -> String? {
        let allowedCharacters = NSCharacterSet.URLQueryParameterAllowedCharacterSet()
        return stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
}

extension Utility {
    
    static var mediumStyleDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        return formatter
    }()
}

extension UITableView {
    /**
     Gets a collection of all table view cell's which are completely visible without obstruction.
     
     - returns: Array of table view cells which are completely visible without obstruction.
     */
    func fullyVisibleCells() -> [UITableViewCell] {
        var fullyVisibleCells: [UITableViewCell] = self.visibleCells
        if !fullyVisibleCells.isEmpty && !self.isFullyVisible(fullyVisibleCells.first) {
            fullyVisibleCells.removeFirst()
        }
        if !fullyVisibleCells.isEmpty && !self.isFullyVisible(fullyVisibleCells.last) {
            fullyVisibleCells.removeLast()
        }
        return fullyVisibleCells
    }
    
    /**
     Determines if a table view cell is fully visible within a table view's bounds. Said another way, this method determines if a cell's frame is fully contained within a table view's bounds.
     
     **Note:** This method does not take external factors into account when determining cell visisbility. This method does not gaurantee that the cell is visible on screen. For example, if a subview is covering the table view or if the table view is hidden, the cell may not be visible.
     
     - parameter cell: Table view cell to evaluate.
     
     - returns: `true` if the cell's frame is contained completely within the table view's bounds.
     */
    func isFullyVisible(cell: UITableViewCell?) -> Bool {
        guard let cell = cell else { return false }
        guard let superview = self.superview else { return false }
        guard let indexPath = self.indexPathForCell(cell) else { return false }
        
        let cellRect = self.rectForRowAtIndexPath(indexPath)
        let convertedCellRect = self.convertRect(cellRect, toView: superview)
        return CGRectContainsRect(self.frame, convertedCellRect)
    }
}

extension UIView {
    
    func addSubview(subview: UIView, pinToEdges: Bool) {
        self.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : subview]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : subview]))
    }
}

extension Utility {
    
    class func roundToLowest(var number: Double, roundTo: Double) -> Double {
        if number < 0 {
            number -= roundTo
        }
        return Double(Int(number / roundTo) * Int(roundTo))
    }
    
    class func roundToHighest(number: Double, roundTo: Double) -> Double {
        return roundTo * Double(Int(ceil(number / roundTo)))
    }
}
