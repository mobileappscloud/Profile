import Foundation

class ConnectDeviceRow: UITableViewCell, UIAlertViewDelegate {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var connectedToggle: UISwitch!
    
    var device:ActivityDevice!;
    var parentController:UINavigationController!;
    var webView:WebViewController!;
    
    @IBAction func deviceSwitchTouch(sender: UISwitch) {
        let connected = sender.on;
        if (connected) {
            connectDevice();
        } else {
            disconnectDevice();
        }
    }
    
    func connectDevice() {
        self.device.connected = true;
        webView = WebViewController(nibName: "WebView", bundle: nil);
        webView.url = "\(HigiApi.webUrl)/mobileDeviceConnect";

        let headers = ["Higi-Device-Connect-Url": device.connectUrl.stringByReplacingOccurrencesOfString("{redirect}", withString: "http://www.google.com".stringByReplacingPercentEscapesUsingEncoding(16)!), "User-Id": SessionData.Instance.user.userId, "Token": SessionData.Instance.token];
        webView.headers = headers;
        webView.device = device;
        parentController.pushViewController(webView, animated: true);
    }
    
    func disconnectDevice() {
        UIAlertView(title: "Remove device", message: "You are about to remove \(device.name) from your devices.  Are you sure?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes").show();
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //index 0 == cancel
        if (buttonIndex == 0) {
            connectedToggle.on = true;
        } else {
            if (device.disconnectUrl != nil) {
                self.device.connected = false;
                HigiApi().sendDelete(device.disconnectUrl, parameters: nil, success: nil,
                    failure: { operation, error in
                        self.device.connected = true;
                        self.connectedToggle.on = true;
                        UIAlertView(title: "Uh oh", message: "Unable to remove device.  Please try again later.", delegate: self, cancelButtonTitle: "OK").show();
                });
            } else {
                UIAlertView(title: "Uh oh", message: "Unable to disconnect device.  Please try again later.", delegate: self, cancelButtonTitle: "OK").show();
            }
        }
    }
}