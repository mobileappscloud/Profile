import AVFoundation
import CoreVideo
import CoreMedia

class QrScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var blankStateLayer: UIView!
    @IBOutlet weak var userLayer: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var settingsButton: UIButton!
    
    var captureSession:AVCaptureSession?;
    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?;
    
    var fakeNavBar:UIView!;
    
    let navBarHeight:CGFloat = 64;
    
    var invalidQrAlert:UIAlertView!;
    
    var readingQrInput = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.title = "Scanner";
        
        initBackButton();
        infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "infoClicked:"));
        invalidQrAlert = UIAlertView(title: "Uh oh", message: "There was a problem with the QR code you scanned.  The scanner will only work for QR codes on the higi kiosk.", delegate: nil, cancelButtonTitle: "OK");
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        checkPermissionsAndInitScanner();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        captureSession?.stopRunning();
    }
    
    func initBackButton() {
        let backButton = UIButton(type: UIButtonType.Custom);
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        let backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
        self.navigationItem.hidesBackButton = true;
    }
    
    func checkPermissionsAndInitScanner() {
        var hasCameraPermission = false;
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ==  AVAuthorizationStatus.Authorized {
            initVideoCapture();
        } else {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.initVideoCapture();
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showBlankState();
                    });
                }
            });
        }
    }
    
    func initVideoCapture() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        var error:NSError?;
        let deviceInput: AnyObject!
        do {
            deviceInput = try AVCaptureDeviceInput.deviceInputWithDevice(device)
        } catch let error1 as NSError {
            error = error1
            deviceInput = nil
        };
        if error != nil {
            UIAlertView(title: "Uh oh", message: "The scanner will not work with your device", delegate: self, cancelButtonTitle: "OK").show();
        } else {
            captureSession = AVCaptureSession();
            captureSession?.addInput(deviceInput as! AVCaptureInput);
            let captureMetadataOutput = AVCaptureMetadataOutput();
            captureSession?.addOutput(captureMetadataOutput);
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue());
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode];
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
            videoPreviewLayer?.frame = view.layer.bounds;
            videoPreviewLayer?.frame.origin.y = navBarHeight;
            videoPreviewLayer?.frame.size.height = view.layer.bounds.size.height - navBarHeight;
            self.view.layer.addSublayer(videoPreviewLayer);
            captureSession?.startRunning();
            view.bringSubviewToFront(userLayer);
        }
    }
    
    func showBlankState() {
        //it is impossible to actually send the user to the settings app before iOS8
        if (UIDevice.currentDevice().systemVersion < "8.0") {
            self.settingsButton.hidden = true;
        }
        self.blankStateLayer.hidden = false;
        self.userLayer.hidden = true;
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if !readingQrInput && metadataObjects != nil && metadataObjects.count > 0 {
            let output = metadataObjects[0] as! AVMetadataMachineReadableCodeObject;
            if output.type == AVMetadataObjectTypeQRCode {
                if let code = output.stringValue {
                    if performQrAction(code) {
                        readingQrInput = true;
                        goBack(nil);
                    }
                }
            }
        }
    }
    
    func performQrAction(code:String) -> Bool {
        switch(Array(code.characters)[0]) {
        case "0":
            self.attemptCheckInResultUpload(code);
            return true;

        case "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "-", ":", "$", " ", "*":
            if !invalidQrAlert.visible {
                invalidQrAlert.show();
            }
        default:
            if !invalidQrAlert.visible {
                invalidQrAlert.show();
            }
        }
        return false;
    }
    
    func attemptCheckInResultUpload(code: String) {
        dispatch_async(dispatch_get_main_queue(), {
            UIAlertView(title: "On its way!", message: "Your checkin data is being uploaded to the higi servers", delegate: nil, cancelButtonTitle: "Got it").show();
        });
        
        self.sendCheckinResults(code);
    }
    
    func sendCheckinResults(code:String) {
        let userId = SessionData.Instance.user.userId;
        let contents = NSMutableDictionary();
        contents["qrValue"] = code;
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(userId)/qrCheckin", parameters: contents, success: { (operation, responseObject) in
                self.clearNotification();
                self.showNotification("Checkin data successfully uploaded to higi servers!  Check it out in the app");
                }, failure: { (operation, error) in
                    if operation.response.statusCode != 400 {
                        self.clearNotification();
                        self.showNotification("There was a problem uploading your checkin data");
                    } else {
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.sendCheckinResults(code);
                        }
                    }
            });
        };
    }
    
    func requestMobileLoginCode(code:String) {
        
    }
    
    func showNotification(message: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let showCheckInNotification = userDefaults.boolForKey("AllLocalNotificationSettingKey") && userDefaults.boolForKey("ScannedCheckInNotificationSettingKey");
        if !showCheckInNotification {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            let notification = UILocalNotification();
            notification.fireDate = NSDate();
            notification.alertBody = message;
            notification.applicationIconBadgeNumber = -1;
            notification.userInfo = ["ID": 99];
            UIApplication.sharedApplication().scheduleLocalNotification(notification);
        });
    }
    
    func clearNotification() {
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().cancelAllLocalNotifications();
        });
    }
    
    func goBack(sender: AnyObject!) {
        if let nav = self.navigationController {
            nav.popViewControllerAnimated(false);
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        goBack(self);
    }
    
    @IBAction func settingsButtonClick(sender: AnyObject) {
        if (UIDevice.currentDevice().systemVersion >= "8.0") {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!);
        }
    }
    
    func infoClicked(sender: AnyObject) {
        UIAlertView(title: "What does this scanner do?", message: "The scanner allows you to save your check-in results at a higi Station that may not be connecting to the internet.  For offline Stations just scan the QR code that appears on the higi Station and viola!  The results from your check-in will be added to your account.", delegate: nil, cancelButtonTitle: "Got it").show();
    }
}