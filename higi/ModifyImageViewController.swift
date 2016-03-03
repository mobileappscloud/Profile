//
//  ModifyImageViewController.swift
//  higi
//
//  Created by Dan Harms on 8/8/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ModifyImageViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var topMask: UIView!
    @IBOutlet weak var circleMask: UIImageView!
    @IBOutlet weak var bottomMask: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var profileImage: UIImage!;
    
    var resizing = false, fromSettings = false;
    
    var origFrame: CGRect!;
    
    var lastScale: CGFloat! = 1.0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false;
        self.navigationController!.interactivePopGestureRecognizer!.delegate = nil;
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(done))
        
        profileImageView.image = profileImage;
        
        profileImageView.hidden = true;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        profileImageView.hidden = false;
        var width: CGFloat, height: CGFloat;
        if (profileImage.size.width > profileImage.size.height) {
            width = self.view.frame.size.width;
            height = self.view.frame.size.width * profileImage.size.height / profileImage.size.width;
        } else {
            width = self.view.frame.size.width * profileImage.size.width / profileImage.size.height;
            height = self.view.frame.width;
        }
        origFrame = CGRect(x: self.view.frame.size.width * 0.5 - width * 0.5, y: self.view.frame.size.height * 0.5 - height * 0.5, width: width, height: height);
        profileImageView.frame = origFrame;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        topMask.frame.size.height = circleMask.frame.origin.y;
        bottomMask.frame.origin.y = circleMask.frame.origin.y + circleMask.frame.size.height;
    }
    
    func done(sender: AnyObject!) {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.navigationItem.rightBarButtonItem?.enabled = false
            self?.spinner.hidden = false;
        })
        
        if (resizing) {
            sendSize();
        } else {
            var imageData = UIImageJPEGRepresentation(profileImage, 1.0);
            var compressionQuality: CGFloat = 0.5;
            while (imageData!.length > 1000000) {
                imageData = UIImageJPEGRepresentation(profileImage, compressionQuality);
                compressionQuality -= 0.1;
            }
            let user = SessionData.Instance.user;
            HigiApi().sendBytePost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)/photo", contentType: "image/jpg", body: imageData!, parameters: nil, success: {operation, responseObject in
                user.fullProfileImage = UIImage(data: imageData!);
                user.hasPhoto = true;
                user.createBlurredImage();
                self.sendSize();
                
                }, failure: {operation, error in
                    self.showErrorAlert();
            });
        }
    }
    
    func sendSize() {
        let user = SessionData.Instance.user;
        let contents = NSMutableDictionary();
        var frame = profileImageView.frame;
        var iamgeSize = profileImage.size;
        let scale = profileImageView.frame.size.width / profileImage.size.width;
        let serverScale = 140.0 / ((self.view.frame.size.width * 0.571296296) / scale);
        let deltaX = profileImageView.frame.origin.x - origFrame.origin.x + (profileImageView.frame.size.width - origFrame.size.width) / 2;
        let deltaY = profileImageView.frame.origin.y - origFrame.origin.y + (profileImageView.frame.size.height - origFrame.size.height) / 2;
        let centerX = Int((profileImage.size.width / 2.0 - deltaX / scale) * serverScale);
        let centerY = Int((profileImage.size.height / 2.0 - deltaY / scale) * serverScale);
        contents.setObject(centerX, forKey: "centerX");
        contents.setObject(centerY, forKey: "centerY");
        contents.setObject(serverScale, forKey: "scale");
        
        HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)/photoPosition", parameters: contents, success: {operation, responseObject in
            if (responseObject != nil) {
                user.photoTime = ((responseObject as! NSDictionary)["photoTime"] ?? Int(NSDate().timeIntervalSince1970)) as! Int;
            } else {
                user.photoTime = Int(NSDate().timeIntervalSince1970);
            }
            user.profileImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(HigiApi.higiApiUrl)/view/\(user.userId)/profile,400.png?t=\(user.photoTime)")!)!);
            
            if (self.fromSettings) {
                if let settingsViewController = self.presentingViewController as? SettingsViewController {
                    settingsViewController.pictureChanged = true
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
            }, failure: {operation, error in
                self.showErrorAlert();
        });
    }
    
    @IBAction func pinchZoom(sender: UIPinchGestureRecognizer) {
        let scale = 1.0 + sender.scale - lastScale;
        let center = profileImageView.center;
        profileImageView.frame.size = CGSize(width: profileImageView.frame.size.width * scale, height: profileImageView.frame.size.height * scale);
        profileImageView.center = center;
        lastScale = sender.scale;
        if (sender.state == UIGestureRecognizerState.Ended) {
            lastScale = 1;
        }
    }
    
    @IBAction func dragImage(sender: UIPanGestureRecognizer) {
        profileImageView.frame.origin.x += sender.translationInView(self.view).x;
        profileImageView.frame.origin.y += sender.translationInView(self.view).y;
        sender.setTranslation(CGPointZero, inView: self.view);
    }
    
    func showErrorAlert() {
        let title = NSLocalizedString("MODIFY_IMAGE_VIEW_SERVER_ERROR_ALERT_TITLE", comment: "Title for alert which is displayed if the server is unreachable.")
        let message = NSLocalizedString("MODIFY_IMAGE_VIEW_SERVER_ERROR_ALERT_MESSAGE", comment: "Message for alert which is displayed if the server is unreachable.")
        let dismissTitle = NSLocalizedString("MODIFY_IMAGE_VIEW_SERVER_ERROR_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert which is displayed if the server is unreachable.")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: {
                self.reset()
            })
        })
    }
    
    func reset() {
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            self?.navigationItem.hidesBackButton = true
            self?.spinner.hidden = true;
            self?.spinner.stopAnimating();
            self?.navigationItem.rightBarButtonItem?.enabled = true
        })
    }
    
}