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
        self.title = "Scan QR Code";
        
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
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
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
        let deviceInput: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error);
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
        switch(Array(code)[0]) {
        case "0":
            sendCheckinResults(code);
            return true;
        case "1":
            requestMobileLoginCode(code);
            return false;
        case "2", "3", "4", "5", "6", "7", "8", "9", ".", "-", ":", "$", " ", "*":
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
    
    func sendCheckinResults(code:String) {
        var done = false;
        let userId = SessionData.Instance.user.userId;
        var contents = NSMutableDictionary();
        contents["qrValue"] = code;
        
        showNotification("Uploading checkin data to higi servers...");
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            while !done {
                HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(userId)/qrCheckin", parameters: contents, success: {operation, responseObject in
                    self.clearNotification();
                    self.showNotification("Checkin data successfully uploaded to higi servers!  Check it out in the app");
                    done = true;
                    
                    }, failure: {operation, error in
                        if operation.response.statusCode == 400 {
                            self.clearNotification();
                            self.showNotification("There was a problem uploading your checkin data");
                            done = true;
                        }
                });
                if !done {
                    NSThread.sleepForTimeInterval(10);
                }
            }
        }
    }
    
    func requestMobileLoginCode(code:String) {
        
    }
    
    func showNotification(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            var notification = UILocalNotification();
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