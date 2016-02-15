import Foundation
import WebKit
import SafariServices

class ConnectDeviceRow: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = ""
        }
    }
    @IBOutlet weak var connectedToggle: UISwitch!
    
    var device:ActivityDevice!;
    var parentController: UINavigationController!
    var webViewController: UIViewController?
    
    @IBAction func deviceSwitchTouch(sender: UISwitch) {
        let connected = sender.on;
        if (connected) {
            connectDevice();
        } else {
            disconnectDevice();
        }
    }
    
    func connectDevice() {
        if device.name == BrandedDevice.HigiActivityTracker {
            if HealthKitManager.deviceHasMotionProcessor() {
                self.connectBrandedDevice()
            } else {
                self.showUnsupportedDeviceAlert()
            }
        } else {
            self.device.connected = true;

            let userId = SessionData.Instance.user.userId as String
            ApiUtility.fetchTemporarySessionToken(userId, completion: { [weak self] (token, error) in
                if error == nil && token != nil {
                    guard let URL = self?.deviceConnectURL(token!) else {
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.presentOAuthBrowser(connectDeviceURL: URL)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.showDeviceConnectError()
                    })
                }
            })
        }
    }
    
    private func presentOAuthBrowser(connectDeviceURL URL: NSURL) {
        if #available(iOS 9.0, *) {
            let safari = SFSafariViewController(URL: URL)
            self.webViewController = safari
            self.parentController.presentViewController(safari, animated: true, completion: nil)
        } else {
            let embeddedWebViewController = WebViewController(nibName: "WebView", bundle: nil)
            embeddedWebViewController.url = URL.absoluteString
            embeddedWebViewController.navigationDelegate = self
            self.webViewController = embeddedWebViewController
            self.parentController.pushViewController(embeddedWebViewController, animated: true)
        }
    }
    
    private func showDeviceConnectError() {
        
    }
    
    private func deviceConnectURL(temporaryToken: String) -> NSURL? {
        guard let deviceConnectURL = device.connectUrl else { return nil }
        guard let user = SessionData.Instance.user else { return nil }
        let userId = user.userId as String
        
        let resource = "mobileDeviceConnect"
        let redirectURLString = "\(HigiApi.webUrl)/settings/apps"
        let deviceConnectWithRedirectURLString = deviceConnectURL.stringByReplacingOccurrencesOfString("{redirect}", withString: redirectURLString)
        
        guard let formattedDeviceConnectURLString = deviceConnectWithRedirectURLString.stringByRemovingPercentEncoding else { return nil }
        guard let encodedUserId = userId.stringByAddingPercentEncodingForURLQueryParameter() else { return nil }
        guard let encodedToken = temporaryToken.stringByAddingPercentEncodingForURLQueryParameter() else { return nil }
        
        let baseURLString = HigiApi.webUrl
        let fullyQualifiedURLString = "\(baseURLString)/\(resource)?User-id=\(encodedUserId)&Token=\(encodedToken)&Higi-device-connect-url=\(formattedDeviceConnectURLString)"        
        return NSURL(string: fullyQualifiedURLString)
    }
    
    func showUnsupportedDeviceAlert() {
        let title = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_NO_MOTION_PROCESSOR_ALERT_TITLE", comment: "Title for alert displayed when user toggles switch to connect branded activity tracker, but the device does not have a motion processor.")
        let message = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_NO_MOTION_PROCESSOR_ALERT_MESSAGE", comment: "Message for alert displayed when user toggles switch to connect branded activity tracker, but the device does not have a motion processor")
        let dismissActionTitle = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_NO_MOTION_PROCESSOR_ALERT_ACTION_ACKNOWLEDGE_ACTION", comment: "Title for alert action to acknowledge alert displayed when user toggles switch to connect branded activity tracker, but the device does not have a motion processor")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissActionTitle, style: .Default, handler: { [weak self] (action) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.connectedToggle.on = false
            })
            })
        alert.addAction(dismissAction)
        self.parentController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func connectBrandedDevice() {
        if !HealthKitManager.didShowAuthorizationModal() {
            HealthKitManager.requestReadAccessToStepData( { (didRespond, error) in
                if didRespond {
                    HealthKitManager.checkReadAuthorizationForStepData({ [weak self] (isAuthorized) in
                        if isAuthorized {
                            HealthKitManager.enableBackgroundUpdates()
                        } else {
                            HealthKitManager.disableBackgroundUpdates()
                            dispatch_async(dispatch_get_main_queue(), {
                                self?.connectedToggle.on = false
                            })
                        }
                        })
                }
            })
        } else {
            let title = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_ALERT_TITLE", comment: "Title for alert displayed when user toggles switch to connect branded activity tracker (HealthKit) ON.")
            let message = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_ALERT_MESSAGE", comment: "Message for alert displayed when user toggles switch to connect branded activity tracker (HealthKit) ON.")
            let dismissActionTitle = NSLocalizedString("CONNECT_DEVICE_ROW_CONNECT_HEALTHKIT_ALERT_ACTION_ACKNOWLEDGE_ACTION", comment: "Title for alert action to acknowledge alert displayed when user toggles switch to connect branded activity tracker (HealthKit) ON.")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: dismissActionTitle, style: .Default, handler: { [weak self] (action) in
                dispatch_async(dispatch_get_main_queue(), {
                    self?.connectedToggle.on = false
                })
                })
            alert.addAction(dismissAction)
            self.parentController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func disconnectDevice() {
        if device.name == BrandedDevice.HigiActivityTracker {
            let title = NSLocalizedString("CONNECT_DEVICE_ROW_DISCONNECT_HEALTHKIT_ALERT_TITLE", comment: "Title for alert displayed when user toggles switch to connect branded activity tracker (HealthKit) OFF.")
            let message = NSLocalizedString("CONNECT_DEVICE_ROW_DISCONNECT_HEALTHKIT_ALERT_MESSAGE", comment: "Message for alert displayed when user toggles switch to connect branded activity tracker (HealthKit) OFF.")
            let dismissActionTitle = NSLocalizedString("CONNECT_DEVICE_ROW_DISCONNECT_HEALTHKIT_ALERT_ACTION_ACKNOWLEDGE_ACTION", comment: "Title for alert action to acknowledge alert displayed when user toggles switch to connect branded activity tracker (HealthKit) OFF.")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: dismissActionTitle, style: .Default, handler: { [weak self] (action) in
                dispatch_async(dispatch_get_main_queue(), {
                    self?.connectedToggle.on = true
                })
                })
            alert.addAction(dismissAction)
            self.parentController.presentViewController(alert, animated: true, completion: nil)
        } else {
            let title = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_TITLE", comment: "Title for alert displayed prior to disconnecting a device from a higi Profile.")
            let messageFormat = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_MESSAGE_FORMAT", comment: "Message for alert displayed prior to disconnecting a device from a higi Profile.")
            let message = String(format: messageFormat, arguments: [device.name])
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let confirmTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_ACTION_TITLE_YES", comment: "Title for alert action to confirm disconnecting a device from a higi Profile.")
            let confirmAction = UIAlertAction(title: confirmTitle, style: .Default, handler: { [weak self] (action) in
                self?.attemptToDisconnect()
                })
            alertController.addAction(confirmAction)
            let declineTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_ALERT_ACTION_TITLE_NO", comment: "Title for alert action to decline disconnecting a device from a higi Profile.")
            let declineAction = UIAlertAction(title: declineTitle, style: .Cancel, handler: { [weak self] (action) in
                self?.connectedToggle.on = true
                })
            alertController.addAction(declineAction)
            self.parentController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func attemptToDisconnect() {
            let title = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_TITLE", comment: "Title for alert displayed after failure to remove/disconnect a device from a higi Profile.")
            let dismissTitle = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss device remove/disconnect failure alert.")
        
        if (device.disconnectUrl != nil) {
            self.device.connected = false;
            HigiApi().sendDelete(device.disconnectUrl as! String, parameters: nil, success: { (operation, response) in
                 dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.parentController.viewWillAppear(false)
                })
                },
                failure: { operation, error in
                    let removeMessage = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed after failure to remove a device from a higi Profile.")
                    let alertController = UIAlertController(title: title, message: removeMessage, preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: { [unowned self] (action) in
                        dispatch_async(dispatch_get_main_queue(), {
                            self.device.connected = true;
                            self.connectedToggle.on = true;
                        })
                        })
                    alertController.addAction(dismissAction)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.parentController.presentViewController(alertController, animated: true, completion: nil)
                    })
            });
        } else {
            let disconnectMessage = NSLocalizedString("CONNECT_DEVICE_ROW_REMOVE_DEVICE_DISCONNECT_FAILURE_ALERT_MESSAGE", comment: "Message for alert displayed after failure to disconnect a device from a higi Profile.")
            let alertController = UIAlertController(title: title, message: disconnectMessage, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
            alertController.addAction(dismissAction)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.parentController.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }
}

extension ConnectDeviceRow: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {        
        guard let URL = webView.URL else { return }
                
        let (path, _) = UniversalLink.parsePath(forURL: URL)
        if let path = path where path == .ConnectDevice {
            dispatch_async(dispatch_get_main_queue(), {
                webView.stopLoading()
                self.parentController.popViewControllerAnimated(true)
            })
        }
    }
}
