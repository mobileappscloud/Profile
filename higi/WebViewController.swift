import Foundation
import WebKit

class WebViewController: UIViewController {

    var url: NSString!;

    var headers:[String:String!] = [:];
    
    @IBOutlet weak var webViewContainer: UIView!
    
    lazy private var webView: WKWebView = {
        let webView = WKWebView(frame: self.webViewContainer.bounds)
        return webView
    }()
    
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
        
        if (self.headers.count > 0) {
            for (field, value) in self.headers {
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
        self.navigationController!.popViewControllerAnimated(true);
    }
}
