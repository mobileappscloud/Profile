//
//  NSURLSessionTask+Utility.swift
//  higi
//
//  Created by Remy Panicker on 4/5/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

extension NSURLSessionTask {
    
    /**
     Builds a basic data task object using the given parameters.
     
     - parameter session: Session which will perform the task.
     - parameter request: Request to be performed.
     - parameter success: Task completion handler which will be executed upon success.
     - parameter failure: Task completion handler which will be executed upon failure.
     
     - returns: New instance of `NSURLSessionDataTask` configured with input parameters.
     */
    class func dataTask(session: NSURLSession,
                        request: NSURLRequest,
                        success: (data: NSData?, response: NSHTTPURLResponse?) -> Void,
                        failure: (error: NSError?, response: NSHTTPURLResponse?) -> Void) -> NSURLSessionDataTask {
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let error = error {
                failure(error: error, response: response as? NSHTTPURLResponse)
            } else {
                success(data: data, response: response as? NSHTTPURLResponse)
            }
        })
        return task
    }
}

extension NSURLSessionTask: HigiAPIJSONDeserializer {
    
    /**
     Builds a basic data task object using the given parameters. Assumes that the response will be returned as JSON.
     
     - parameter session: Session which will perform the task.
     - parameter request: Request to be performed.
     - parameter success: Task completion handler which will be executed upon success.
     - parameter failure: Task completion handler which will be executed upon failure.
     
     - returns: New instance of `NSURLSessionDataTask` configured with input parameters.
     */
    class func JSONTask(session: NSURLSession,
                        request: NSURLRequest,
                        success: (JSON: AnyObject?, response: NSHTTPURLResponse?) -> Void,
                        failure: (error: NSError?, response: NSHTTPURLResponse?) -> Void) -> NSURLSessionDataTask {
        
        let task = self.dataTask(session, request: request, success: { (data, response) in
            if let response = response where response.statusCodeEnum.isSuccess {
                
                if response.statusCodeEnum == .NoContent {
                    success(JSON: nil, response: response)
                    return
                }
                
                deserialize(data, success: { (JSON) in
                    success(JSON: JSON, response: response)
                }, failure: { (error) in
                    failure(error: error, response: response)
                })
            
            } else {
                failure(error: nil, response: response)
            }
        }, failure: failure)
        
        return task
    }
}
