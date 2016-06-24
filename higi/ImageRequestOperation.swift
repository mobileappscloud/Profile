//
//  ImageRequestOperation.swift
//  higi
//
//  Created by Remy Panicker on 5/31/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ImageRequestOperation: NSOperation {
    
    let URL: NSURL
    let completionHandler: ImageRequestorCompletion
    
    lazy private var stateLock: NSLock = {
        return NSLock()
    }()
    
    init(URL: NSURL, completionHandler: ImageRequestorCompletion) {
        self.URL = URL
        self.completionHandler = completionHandler
    }
    
    deinit {
//        print("deinit operation for \(URL.absoluteString)")
    }
    
    // MARK: - Concurrent Operation
    
    override var asynchronous: Bool {
        get {
            return true
        }
    }
    
    // MARK: - KVO
    
    private var _executing: Bool = false
    override private(set) var executing: Bool {
        get {
            return stateLock.withCriticalScope { _executing }
        }
        set {
            willChangeValueForKey("isExecuting")
            
            stateLock.withCriticalScope {
                if _executing != newValue {
                    _executing = newValue
                }
            }
            
            didChangeValueForKey("isExecuting")
        }
    }
    
    private var _finished: Bool = false
    override private(set) var finished: Bool {
        get {
            return stateLock.withCriticalScope { _finished }
        }
        set {
            willChangeValueForKey("isFinished")
            
            stateLock.withCriticalScope {
                if _finished != newValue {
                    _finished = newValue
                }
            }
            
            didChangeValueForKey("isFinished")
        }
    }
}

// MARK: - Operation

extension ImageRequestOperation {
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        executing = true
        
        main()
    }
    
    override func main() {
        if cancelled {
            completeOperation()
            return
        }
        
        if let image = ImageCache.image(forImageURL: URL) {
//            print("returning cached image in NSOperation!")
            completionHandler(image: image)
            completeOperation()
        } else {
            ImageRequestor.sharedInstance.fetchRemoteImage(forURL: URL, completion: { [weak self] (image) in
                guard let strongSelf = self else { return }
                
                if strongSelf.cancelled {
                    strongSelf.completeOperation()
                    return
                }
                
                strongSelf.completionHandler(image: image)
                strongSelf.completeOperation()
            })
        }
    }
}

extension ImageRequestOperation {
    
    func completeOperation () {
        executing = false
        finished = true
    }
}
