//
//  ModifyImageController.swift
//  higi
//
//  Created by Remy Panicker on 5/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ModifyImageController {
    
    private lazy var session: NSURLSession = {
        return APIClient.sharedSession
    }()
}

extension ModifyImageController {
    
    func fetchImage(withURL URL: NSURL, completion: (image: UIImage?) -> Void) {
        let task = session.dataTaskWithURL(URL, completionHandler: { (data, response, error) in
            guard let data = data,
                let response = response as? NSHTTPURLResponse where response.statusCodeEnum.isSuccess else {
                    completion(image: nil)
                    return
            }
            
            let image = UIImage(data: data)
            completion(image: image)
        })
        task.resume()
    }
}

extension ModifyImageController {
    
    func update(user: User, image: UIImage, success: () -> Void, failure: (error: NSError?) -> Void) {
        compressedJPEGData(fromImage: image, success: { [weak self] (imageData) in
            self?.uploadImage(forUser: user, data: imageData, success: success, failure: failure)
            }, failure: { (error) in
                failure(error: error)
        })
    }
    
    private func uploadImage(forUser user: User, data: NSData, success: () -> Void, failure: (error: NSError?) -> Void) {
        ImageUploadRequest.request(user, imageData: data, completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure(error: error)
                return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { (JSON, response) in
                success()
                }, failure: { (error, response) in
                    failure(error: error)
            })
            task.resume()
        })
    }
    
    func updateImagePosition(forUser user: User, centerX: Int, centerY: Int, serverScale: CGFloat, success: () -> Void, failure: () -> Void) {
        
        ImageUploadRequest.request(user, centerX: centerX, centerY: centerY, scale: serverScale, completion: { [weak self] (request, error) in
            guard let strongSelf = self,
                let request = request else {
                    failure()
                    return
            }
            
            let task = NSURLSessionTask.JSONTask(strongSelf.session, request: request, success: { (JSON, response) in
                success()
                }, failure: { (error, response) in
                    failure()
            })
            task.resume()
        })
    }
}

extension ModifyImageController {
    
    private func compressedJPEGData(fromImage image: UIImage, success: (imageData: NSData) -> Void, failure: (error: NSError?) -> Void) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            var imageData: NSData?
            let maxSize = 1000000
            var compressionQuality: CGFloat = 1.0
            let minimumCompressionQuality: CGFloat = 0.1
            autoreleasepool({
                repeat {
                    let compressedImageData = UIImageJPEGRepresentation(image, compressionQuality)
                    if let compressedImageData = compressedImageData {
                        imageData = compressedImageData
                    } else {
                        break
                    }
                    compressionQuality -= 0.1
                    
                } while (imageData?.length > maxSize && compressionQuality >= minimumCompressionQuality)
            })
            
            if let imageData = imageData {
                if imageData.length > maxSize && compressionQuality < minimumCompressionQuality {
                    let userInfo = [NSLocalizedDescriptionKey : "The image is too large to upload. Please try uploading a smaller file."]
                    let error = NSError(domain: "\(self.dynamicType)", code: 1000, userInfo: userInfo)
                    failure(error: error)
                } else {
                    success(imageData: imageData)
                }
            } else {
                failure(error: nil)
            }
        }
    }
}

extension ModifyImageController {
    
    func calculatePosition(containerFrame: CGRect, originalImageViewFrame: CGRect, imageViewFrame: CGRect, image: UIImage) -> (centerX: Int, centerY: Int, serverScale: CGFloat) {
        // Porting over legacy code. Sorry, but I don't know where these numbers come from
        let magicNumber1: CGFloat = 140.0
        let magicNumber2: CGFloat = 0.571296296
        
        let scale = imageViewFrame.size.width / image.size.width;
        let serverScale = magicNumber1 / ((containerFrame.size.width * magicNumber2) / scale);
        
        let deltaX = imageViewFrame.origin.x - originalImageViewFrame.origin.x + (imageViewFrame.size.width - originalImageViewFrame.size.width) / 2;
        let deltaY = imageViewFrame.origin.y - originalImageViewFrame.origin.y + (imageViewFrame.size.height - originalImageViewFrame.size.height) / 2;
        
        let centerX = Int((image.size.width / 2.0 - deltaX / scale) * serverScale);
        let centerY = Int((image.size.height / 2.0 - deltaY / scale) * serverScale);
        
        return (centerX, centerY, serverScale)
    }
}
