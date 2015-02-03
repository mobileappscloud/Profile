import Foundation

class ConnectDeviceRow: UITableViewCell, UIAlertViewDelegate {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var connectedToggle: UISwitch!
    
    var device:ActivityDevice!;
    var parentController:UINavigationController!;
    
    @IBAction func deviceSwitchTouch(sender: UISwitch) {
        let connected = sender.on;
        if (connected) {
            connectDevice();
        } else {
            disconnectDevice();
        }
    }
    
    func instanceFromNib() -> ConnectDeviceRow {
        let row = UINib(nibName: "ConnectDeviceRow", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as ConnectDeviceRow;
        row.logo.setImageWithURL(Utility.loadImageFromUrl(device.iconUrl));
        row.name.text = device.name;
        row.connectedToggle.on = device.connected;
        row.device = device;
        row.parentController = parentController;
        return row;
    }
    
    func connectDevice() {
        var webView = WebViewController(nibName: "WebView", bundle: nil);
        webView.url = "\(HigiApi.webUrl)/mobileDeviceConnect";

        let headers = ["Higi-Device-Connect-Url": device.connectUrl.stringByReplacingOccurrencesOfString("{redirect}", withString: "http://www.google.com".stringByReplacingPercentEscapesUsingEncoding(16)!), "User-Id": SessionData.Instance.user.userId, "Token": SessionData.Instance.token];
        webView.headers = headers;
        parentController.pushViewController(webView, animated: true);
    }
    
    func disconnectDevice() {
        UIAlertView(title: "Remove device", message: "You are about to remove \(device.name) from your devices.  Are you sure?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes").show();
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            connectedToggle.on = true;
        } else {
            HigiApi().sendDelete(device.disconnectUrl, parameters: nil, success: {operation, responseObject in
                self.device.connected = false;
                }, failure: { operation, error in
                    UIAlertView(title: "Uh oh", message: "Unable to remove device.  Please try again later.", delegate: self, cancelButtonTitle: "OK").show();
            });
        }
    }
}