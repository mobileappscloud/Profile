import Foundation

class OldWebViewController: UIViewController, NSURLConnectionDataDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url: NSString!;
    
    var webData: NSMutableData!;
    
    var headers:[String:String!] = [:];
    
    var device: ActivityDevice!;
    
    var errorMessage: String!;
    
    var loadData = false, isGone = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        let backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: url as String)!);
        
        if (headers.count > 0) {
            for (field, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: field);
            }
        }
        webView.delegate = self;
        
        urlRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
        if (loadData) {
            NSURLConnection(request: urlRequest, delegate: self);
        } else {
            webView.loadRequest(urlRequest);
        }
        
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (request.allHTTPHeaderFields?.indexForKey("Higi-Source") == nil && request.URL?.absoluteString == request.mainDocumentURL?.absoluteString) {
            dispatch_async(dispatch_get_main_queue(), {
                if let mutableRequest = request.mutableCopy() as? NSMutableURLRequest {
                    mutableRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
                    
                    if (self.loadData) {
                        NSURLConnection(request: mutableRequest, delegate: self);
                    } else {
                        webView.loadRequest(mutableRequest);
                    }
                }
            });
            
            return false;
        }
        if (((!isGone && request.URL!.absoluteString != "" && request.URL!.absoluteString.hasPrefix("https://www.google.com")))) {
            webView.stopLoading();
            let components = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)!;
            errorMessage = "";
            let params = components.query!.componentsSeparatedByString("%").split {$0 == "&"};
            for item in components.query!.componentsSeparatedByString("&") {
                var keyValuePair = item.componentsSeparatedByString("=");
                let i = keyValuePair[0];
                if (keyValuePair[0] == "error") {
                    if (keyValuePair.count > 1 && keyValuePair[1].characters.count > 0) {
                        device.connected = false;
                    }
                } else if (keyValuePair[0] == "message") {
                    errorMessage = keyValuePair[1].stringByReplacingOccurrencesOfString("+", withString: " ", options: [], range: nil);
                }
            }
            if (errorMessage != "") {
                UIAlertView(title: "Error", message: "\(errorMessage)", delegate: self, cancelButtonTitle: "OK").show();
            }
            goBack(self);
        }
        return true;
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        webData = NSMutableData();
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        webData.appendData(data);
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        webView.loadData(webData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: NSURL());
    }
    
    func goBack(sender: AnyObject!) {
        if (!isGone) {
            self.navigationController!.popViewControllerAnimated(true);
            isGone = true;
        }
    }
}