import Foundation

class WebViewController: UIViewController, NSURLConnectionDataDelegate, UIWebViewDelegate {
    
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
        if let URL = request.URL where URL.absoluteString != "" && URL.absoluteString.hasPrefix("https://www.google.com") && !isGone {
            webView.stopLoading();
            guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false), query = components.query else {                
                return false
            }
            
            errorMessage = "";
            for item in query.componentsSeparatedByString("&") {
                let keyValuePair = item.componentsSeparatedByString("=");
                let key = keyValuePair[0]
                let value = keyValuePair[1]
                if (key == "error") {
                    if (keyValuePair.count > 1 && value.characters.count > 0) {
                        device.connected = false;
                    }
                } else if (key == "message") {
                    errorMessage = value.stringByReplacingOccurrencesOfString("+", withString: " ", options: [], range: nil);
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