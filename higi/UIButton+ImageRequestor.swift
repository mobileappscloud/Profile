//
//  UIButton+ImageRequestor.swift
//  higi
//
//  Created by Remy Panicker on 6/30/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import ObjectiveC

private var operationAssociationKey: UInt8 = 0

extension UIButton {
    
    var imageRequestOperation: ImageRequestOperation? {
        get {
            return objc_getAssociatedObject(self, &operationAssociationKey) as? ImageRequestOperation
        }
        set(newValue) {
            objc_setAssociatedObject(self, &operationAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIButton {
    
    func setImage(withMediaAsset mediaAsset: MediaAsset?, forState controlState: UIControlState) {
        guard let mediaAsset = mediaAsset else { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if let imageRequestOperation = strongSelf.imageRequestOperation {
                if mediaAsset.URI.absoluteString == imageRequestOperation.URL.absoluteString {
                    //                    print("RETURN Early -- prevent duplicate operation from being added to queue")
                    return
                }
                
                //                print("image view is requesting new image --> Cancel old operation and proceed")
                //                imageRequestOperation.cancel()
                //                strongSelf.imageRequestOperation = nil
            }
            
            strongSelf.imageRequestOperation = ImageRequestor.sharedInstance.fetchImage(forURL: mediaAsset.URI, completion: { [weak strongSelf] (image) in
                
                guard let strongSelf = strongSelf else { return }
                
                if mediaAsset.URI.absoluteString == strongSelf.imageRequestOperation?.URL.absoluteString {
                    //                    print("imageview got image and is setting it")
                    dispatch_async(dispatch_get_main_queue(), {
                        strongSelf.setImage(image, forState: controlState)
                    })
                }
                
                strongSelf.imageRequestOperation = nil
                })
            })
    }
}

