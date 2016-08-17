//
//  UIImageView+ImageRequestor.swift
//  higi
//
//  Created by Remy Panicker on 5/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import ObjectiveC

private var operationAssociationKey: UInt8 = 0

extension UIImageView {
    
    var imageRequestOperation: ImageRequestOperation? {
        get {
            return objc_getAssociatedObject(self, &operationAssociationKey) as? ImageRequestOperation
        }
        set(newValue) {
            objc_setAssociatedObject(self, &operationAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIImageView {
    
    func setImage(withMediaAsset asset: MediaAsset?, transition: Bool = false) {
        guard let asset = asset else { return }
        
        let width = Int(self.bounds.width)
        let height = Int(self.bounds.height)
        
        setImage(withMediaAsset: asset, width: width, height: height, transition: transition)
    }
    
    func setImage(withMediaAsset asset: MediaAsset, length: Int, transition: Bool = false) {
        self.setImage(withMediaAsset: asset, width: length, height: length, transition: transition)
    }
    
    func setImage(withMediaAsset asset: MediaAsset, width: Int, height: Int, transition: Bool = false) {
        let assetURL = asset.sizedURI(width, height: height)
        self.higi_setImage(withURL: assetURL, transition: transition)
    }
    
    // TODO: Rename without namespace after removing conflicting extension
    func higi_setImage(withURL URL: NSURL, transition: Bool = false) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if let imageRequestOperation = strongSelf.imageRequestOperation {
                if URL.absoluteString == imageRequestOperation.URL.absoluteString {
//                    print("RETURN Early -- prevent duplicate operation from being added to queue")
                    return
                }
                
//                print("image view is requesting new image --> Cancel old operation and proceed")
//                imageRequestOperation.cancel()
//                strongSelf.imageRequestOperation = nil
            }
            
            strongSelf.imageRequestOperation = ImageRequestor.sharedInstance.fetchImage(forURL: URL, completion: { [weak strongSelf] (image) in
                
                guard let strongSelf = strongSelf else { return }
                
                if URL.absoluteString == strongSelf.imageRequestOperation?.URL.absoluteString {
//                    print("imageview got image and is setting it")
                    dispatch_async(dispatch_get_main_queue(), {
                        strongSelf.setImage(image, transition: transition)
                    })
                }
                
                strongSelf.imageRequestOperation = nil
                })
        })
    }
}
