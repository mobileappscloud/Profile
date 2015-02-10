import Foundation

class WebViewController: UIViewController, NSURLConnectionDataDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url: NSString!;
    
    var loadData = false;
    
    var webData: NSMutableData!;
    
    var headers:[String:String!] = [:];
    
    var device: ActivityDevice!;
    
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
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if (webView.request?.URL.absoluteString?.rangeOfString("www.google.com") != nil) {
            webView.stopLoading();
            var components = NSURLComponents(URL: webView.request!.URL, resolvingAgainstBaseURL: false)!;
            for item in components.query!.componentsSeparatedByString("%") {
                var keyValuePair = item.componentsSeparatedByString("=");
                if (keyValuePair[0] == "error") {
                    if (keyValuePair.count > 1 && keyValuePair[1].utf16Count > 0) {
                        device.connected = false;
                    }
                    break;
                }
            }
            goBack(self);
        }
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
        self.navigationController!.popViewControllerAnimated(true);
    }
}