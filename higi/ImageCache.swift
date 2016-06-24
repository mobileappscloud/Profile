//
//  ImageCache.swift
//  higi
//
//  Created by Remy Panicker on 5/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

/// Simple cache dedicated for temporary storage of images.
final class ImageCache: NSCache {
    
    /// Shared instance suitable for storing images which can be used anywhere in the app.
    private static var sharedImageCache: ImageCache = {
       let cache = ImageCache()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak cache] (notification) in
            cache?.removeAllObjects()
        })
        
        return cache
    }()
}

// MARK: - Write

extension ImageCache {
    
    /**
     Stores image in a temporary cache.
     
     - parameter image:   Image object to cache.
     - parameter request: Request object with URI for image to be cached.
     */
    class func cache(image: UIImage, forRequest request: NSURLRequest) {
        cache(image, forImageURL: request.URL!)
    }
    
    /**
     Stores image in a temporary cache.
     
     - parameter image: Image object to cache.
     - parameter URL:   URI for image to be cached.
     */
    class func cache(image: UIImage, forImageURL URL: NSURL) {
        sharedImageCache[URL.cachedImageKey()] = image
    }
}

// MARK: - Read

extension ImageCache {
    
    /**
     Checks if an image has been cached and returns the image if it exists in the cache.
     
     - parameter request: Request object with URI for image.
     
     - returns: `UIImage` for cached image, otherwise `nil`.
     */
    class func image(forRequest request: NSURLRequest) -> UIImage? {
        
        var image: UIImage? = nil
        
        switch request.cachePolicy {
        case .UseProtocolCachePolicy:
            fallthrough
        case .ReturnCacheDataElseLoad:
            fallthrough
        case .ReturnCacheDataDontLoad:
            image = self.image(forImageURL: request.URL!)
            
        case .ReloadIgnoringLocalCacheData:
            fallthrough
        case .ReloadIgnoringCacheData:
            break
            
        // As per the documentation, these options are unimplemented and should NOT be used!
        case .ReloadIgnoringLocalAndRemoteCacheData:
            break
        case .ReloadRevalidatingCacheData:
            break
        }
        
        return image
    }
    
    /**
     Checks if an image has been cached and returns the image if it exists in the cache.
     
     - parameter URL: URI for image.
     
     - returns: `UIImage` for cached image, otherwise `nil`.
     */
    class func image(forImageURL URL: NSURL) -> UIImage? {
        return sharedImageCache[URL.cachedImageKey()]
    }
}

// MARK: - Subscripting

private extension ImageCache {
    
    subscript(key: String) -> UIImage? {
        get {
            return objectForKey(key) as? UIImage
        }
        set {
            if let value: UIImage = newValue {
                setObject(value, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }
}

// MARK: - Convenience

private extension NSURL {
    
    func cachedImageKey() -> String {
        return absoluteString
    }
}

private extension NSURLRequest {
    
    func cachedImageKey() -> String {
        return URL!.cachedImageKey()
    }
}
