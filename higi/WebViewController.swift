import Foundation

class WebViewController: UIViewController, NSURLConnectionDataDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url: NSString!;
    
    var loadData = false;
    
    var webData: NSMutableData!;
    
    var headers:[String:String!] = [:];
    
    var device: ActivityDevice!;
    
    var errorMessage: String!;

    var isGone:Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
        
        var urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!);
        
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
        if (((!isGone && request.URL.absoluteString != nil && request.URL.absoluteString!.hasPrefix("http://www.google.com")))) {
            webView.stopLoading();
            var components = NSURLComponents(URL: request.URL, resolvingAgainstBaseURL: false)!;
            errorMessage = "";
            let params = split(components.query!.componentsSeparatedByString("%")) {$0 == "&"};
            for item in components.query!.componentsSeparatedByString("&") {
                var keyValuePair = item.componentsSeparatedByString("=");
                let i = keyValuePair[0];
                if (keyValuePair[0] == "error") {
                    if (keyValuePair.count > 1 && keyValuePair[1].utf16Count > 0) {
                        device.connected = false;
                    }
//                    break;
                } else if (keyValuePair[0] == "message") {
                    errorMessage = keyValuePair[1].stringByReplacingOccurrencesOfString("+", withString: " ", options: nil, range: nil);
                }
            }
            if (errorMessage != "") {
                UIAlertView(title: "Error", message: "\(errorMessage)", delegate: self, cancelButtonTitle: "OK").show();
            }
            goBack(self);
            return false;
        }
        return true;
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        webData = NSMutableData();
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        webData.appendData(data);
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        webView.loadData(webData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: nil);
    }
    
    func goBack(sender: AnyObject!) {
        if (!isGone) {
            self.navigationController!.popViewControllerAnimated(true);
            isGone = true;
        }
    }
}