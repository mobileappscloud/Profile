//
//  ImageRequestor.swift
//  higi
//
//  Created by Remy Panicker on 5/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import ImageIO

typealias ImageRequestorCompletion = (image: UIImage?) -> Void

final class ImageRequestor {
    
    static let sharedInstance = ImageRequestor()
    
    private lazy var session: NSURLSession = {
       return APIClient.defaultSession()
    }()
    
    private(set) var pendingOperations: [String : ImageRequestOperation] = [:]
    
    private lazy var operationQueue: NSOperationQueue = {
       let queue = NSOperationQueue()
        queue.qualityOfService = .UserInitiated
        return queue
    }()
    
    deinit {
        operationQueue.cancelAllOperations()
    }
}

extension ImageRequestor {
    
    func fetchImage(forURL URL: NSURL, completion: ImageRequestorCompletion) -> ImageRequestOperation {
        
//        let requestOperation = ImageRequestOperation(URL: URL, completionHandler: completion)
//        
//        for operation in operationQueue.operations {
//            guard let operation = operation as? ImageRequestOperation else { continue }
//            
//            if requestOperation.URL.absoluteString == operation.URL.absoluteString {
//                requestOperation.queuePriority = .High
//                print("*** add Dependancy on request to identical resource")
//                requestOperation.addDependency(operation)
//                break
//            }
//        }
//        
//        operationQueue.addOperation(requestOperation)
        
        
        
        let operationKey = URL.absoluteString
        let requestOperation = ImageRequestOperation(URL: URL, completionHandler: { [weak self] (image) in
            guard let strongSelf = self else { return }
            
            strongSelf.pendingOperations[operationKey] = nil
            completion(image: image)
        })
        if let operation = pendingOperations[operationKey] {
            requestOperation.queuePriority = .High
            requestOperation.addDependency(operation)
        }
        operationQueue.addOperation(requestOperation)
        pendingOperations[operationKey] = requestOperation
        
        return requestOperation
    }
    
    func fetchRemoteImage(forURL URL: NSURL, completion: ImageRequestorCompletion) {
        
        let task = session.downloadTaskWithURL(URL, completionHandler: { [weak self] (responseURL, response, error) in
            
            guard let strongSelf = self else { return }
            guard let responseURL = responseURL,
                let response = response as? NSHTTPURLResponse else {
                    strongSelf.completeOnMainThread(nil, completion: completion)
                    return
            }
            
            if response.statusCodeEnum.isSuccess {
                
                if let data = NSData(contentsOfURL: responseURL),
                    let image = UIImage(data: data) {

                    //
                    // redraw to prevent deferred decompression
                    // https://www.cocoanetics.com/2011/10/avoiding-image-decompression-sickness/
                    //
                    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
                    image.drawAtPoint(CGPoint.zero)
                    let redrawnImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    ImageCache.cache(image, forImageURL: URL)

                    strongSelf.completeOnMainThread(redrawnImage, completion: completion)
                } else {
                    strongSelf.completeOnMainThread(nil, completion: completion)
                }
                
            } else {
                strongSelf.completeOnMainThread(nil, completion: completion)
            }
            })
        task.resume()
    }
    
    private func completeOnMainThread(image: UIImage?, completion: ImageRequestorCompletion) {
        dispatch_async(dispatch_get_main_queue(), {
            completion(image: image)
        })
    }
}
