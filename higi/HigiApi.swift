import Foundation


class HigiApi {
    
    var manager: AFHTTPRequestOperationManager;
    
    class var higiApiUrl: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("HigiUrl") as! String;
    }
    
    class var earnditApiUrl: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("EarnditUrl") as! String;
    }
    
    class var webUrl: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("WebUrl")  as! String;
    }
    
    class var apiKey: String {
        return API_KEY;
    }
    
    class var apiVersion: String {
        return API_VERSION;
    }
    
    init() {
        manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: HigiApi.higiApiUrl));
        manager.requestSerializer = AFJSONRequestSerializer(writingOptions: NSJSONWritingOptions.allZeros);
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments);
        manager.requestSerializer.timeoutInterval = 30;
        
        manager.requestSerializer.setValue(API_KEY, forHTTPHeaderField: "ApiToken");
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type");
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept");
        manager.requestSerializer.setValue("application/vnd.higi.earndit;version=" + HigiApi.apiVersion, forHTTPHeaderField: "Accept");
        manager.requestSerializer.setValue("iOSv\(Utility.appVersion()).\(Utility.appBuild())", forHTTPHeaderField: "X-Consumer-Id");
        
        if (!SessionData.Instance.token.isEmpty) {
            manager.requestSerializer.setValue(SessionData.Instance.token, forHTTPHeaderField: "Token");
        }
    }
    
    func sendPost(url: String, parameters: NSDictionary?, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        manager.POST(url, parameters: parameters, success: success, failure: failure);
    }
    
    func sendGet(url: String, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        manager.GET(url, parameters: NSDictionary(), success: success, failure: failure);
    }
    
    func sendPut(url: String, parameters: NSDictionary?, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        manager.PUT(url, parameters: parameters, success: success, failure: failure);
    }
    
    func sendDelete(url: String, parameters: NSDictionary?, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        manager.DELETE(url, parameters: parameters, success: success, failure: failure);
    }
    
    func sendBytePost(url: String, contentType: String, body: NSData, parameters: NSDictionary?, success: ((AFHTTPRequestOperation!, AnyObject!) -> Void)?, failure: ((AFHTTPRequestOperation!, NSError!) -> Void)?) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!);
        request.HTTPMethod = "POST";
        request.setValue(contentType, forHTTPHeaderField: "Content-Type");
        request.setValue(HigiApi.apiKey, forHTTPHeaderField: "ApiToken");
        request.setValue("application/vnd.higi.earndit;version=" + HigiApi.apiVersion, forHTTPHeaderField: "Accept");
        if (!SessionData.Instance.token.isEmpty) {
            request.setValue(SessionData.Instance.token, forHTTPHeaderField: "Token");
        }
        request.HTTPBody = body;
        
        var op = AFHTTPRequestOperation(request: request);
        op.setCompletionBlockWithSuccess(success, failure: failure);
        op.start();
    }
}

let API_VERSION = "2.1.1";

let API_KEY = "SyNAqa1DNkeph3P6pvMw8kCdbAh0mMNaJ0quimRPHNZH5jKvzBZulRhn31mGfPfUIZ7l2HBazU9tMeWMJ7eNPn35ZVxw9liS3mQ20Bj780MBAA==";