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
    
    func setImage(withMediaAsset asset: MediaAsset?, forState controlState: UIControlState) {
        guard let asset = asset else { return }
        
        let width = Int(self.bounds.width)
        let height = Int(self.bounds.height)
        
        self.setImage(withMediaAsset: asset, width: width, height: height, forState: controlState)
    }
    
    func setImage(withMediaAsset mediaAsset: MediaAsset?, width: Int, height: Int, forState controlState: UIControlState) {
        guard let mediaAsset = mediaAsset else { return }
        
        let assetURL = mediaAsset.sizedURI(width, height: height)
        self.setImage(withURL: assetURL, forState: controlState)
    }
    
    func setImage(withURL assetURL: NSURL, forState controlState: UIControlState) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
            
            guard let strongSelf = self else { return }
            
            if let imageRequestOperation = strongSelf.imageRequestOperation {
                if assetURL.absoluteString == imageRequestOperation.URL.absoluteString {
                    //                    print("RETURN Early -- prevent duplicate operation from being added to queue")
                    return
                }
                
                //                print("image view is requesting new image --> Cancel old operation and proceed")
                //                imageRequestOperation.cancel()
                //                strongSelf.imageRequestOperation = nil
            }
            
            strongSelf.imageRequestOperation = ImageRequestor.sharedInstance.fetchImage(forURL: assetURL, completion: { [weak strongSelf] (image) in
                
                guard let strongSelf = strongSelf else { return }
                
                if assetURL.absoluteString == strongSelf.imageRequestOperation?.URL.absoluteString {
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
