import Foundation
import WebKit

class WebViewController: UIViewController {

    var url: NSString!;

    var headers:[String:String!] = [:];
    
    var device: ActivityDevice!;
    
    @IBOutlet weak var webViewContainer: UIView!
    
    lazy private var webView: WKWebView = {
        let webView = WKWebView(frame: self.webViewContainer.bounds)
        webView.navigationDelegate = self
        return webView
    }()

    private var webData: NSMutableData!;
    
    private var errorMessage: String!;

    private var isGone = false;
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad();

        self.configureNavBar()
        
        self.addWebView(self.webView)
        
        let URLRequest = self.URLRequest(url)
        
        self.webView.loadRequest(URLRequest)
    }
    
    private func URLRequest(URLString: NSString) -> NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: url as String)!);
        
        if (headers.count > 0) {
            for (field, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: field);
            }
        }
        urlRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
        
        return urlRequest.copy() as! NSURLRequest
    }
    
    private func configureNavBar() {
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Default;
        let backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    private func addWebView(aWebView: UIView) {
        self.webViewContainer.addSubview(aWebView)
        aWebView.translatesAutoresizingMaskIntoConstraints = false
        self.webViewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[aWebView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["aWebView" : aWebView]))
        self.webViewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[aWebView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["aWebView" : aWebView]))
    }
    
    // MARK: Navigation
    
    func goBack(sender: AnyObject!) {
        if (!isGone) {
            self.navigationController!.popViewControllerAnimated(true);
            isGone = true;
        }
    }
}

extension WebViewController: WKNavigationDelegate {

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        let request = navigationAction.request
        
        if (request.allHTTPHeaderFields?.indexForKey("Higi-Source") == nil && request.URL?.absoluteString == request.mainDocumentURL?.absoluteString) {
            dispatch_async(dispatch_get_main_queue(), {
                if let mutableRequest = request.mutableCopy() as? NSMutableURLRequest {
                    mutableRequest.addValue("mobile-ios", forHTTPHeaderField: "Higi-Source");
                    
                    webView.loadRequest(mutableRequest);
                }
            });
            
            decisionHandler(.Cancel)
            return
        }
        
        if (((!isGone && request.URL!.absoluteString != "" && request.URL!.absoluteString.hasPrefix("https://www.google.com")))) {
            webView.stopLoading();
            let components = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)!;
            errorMessage = "";

            for item in components.query!.componentsSeparatedByString("&") {
                var keyValuePair = item.componentsSeparatedByString("=");

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

        decisionHandler(.Allow)
        return
    }
}
