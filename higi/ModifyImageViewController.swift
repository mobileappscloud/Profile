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
    
    var doneButton: UIButton!;
    
    var origFrame: CGRect!;
    
    var lastScale: CGFloat! = 1.0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        if (fromSettings) {
            (self.navigationController as MainNavigationController).revealController.panGestureRecognizer().enabled = false;
        }
        self.navigationController!.interactivePopGestureRecognizer.enabled = false;
        self.navigationController!.interactivePopGestureRecognizer.delegate = nil;
        profileImageView.image = profileImage;
        
        doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30));
        doneButton.setTitle("Done", forState: UIControlState.Normal);
        doneButton.addTarget(self, action: "done:", forControlEvents: UIControlEvents.TouchUpInside);
        var doneBarItem = UIBarButtonItem();
        doneBarItem.customView = doneButton;
        self.navigationItem.rightBarButtonItem = doneBarItem;
        
        profileImageView.hidden = true;
        
        var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        backButton.setBackgroundImage(UIImage(named: "btn_back_white.png"), forState: UIControlState.Normal);
        backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
        var backBarItem = UIBarButtonItem(customView: backButton);
        self.navigationItem.leftBarButtonItem = backBarItem;
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
        self.navigationItem.leftBarButtonItem?.customView?.hidden = true;
        doneButton.hidden = true;
        spinner.hidden = false;
        if (resizing) {
            sendSize();
        } else {
            var imageData = UIImageJPEGRepresentation(profileImage, 1.0);
            var compressionQuality: CGFloat = 0.5;
            while (imageData.length > 1000000) {
                imageData = UIImageJPEGRepresentation(profileImage, compressionQuality);
                compressionQuality -= 0.1;
            }
            var user = SessionData.Instance.user;
            HigiApi().sendBytePost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)/photo", contentType: "image/jpg", body: imageData, parameters: nil, success: {operation, responseObject in
                user.fullProfileImage = UIImage(data: imageData);
                user.hasPhoto = true;
                user.createBlurredImage();
                self.sendSize();
                
                }, failure: {operation, error in
                    self.showErrorAlert();
            });
        }
    }
    
    func sendSize() {
        var user = SessionData.Instance.user;
        var contents = NSMutableDictionary();
        var frame = profileImageView.frame;
        var iamgeSize = profileImage.size;
        var scale = profileImageView.frame.size.width / profileImage.size.width;
        var serverScale = 140.0 / ((self.view.frame.size.width * 0.571296296) / scale);
        var deltaX = profileImageView.frame.origin.x - origFrame.origin.x + (profileImageView.frame.size.width - origFrame.size.width) / 2;
        var deltaY = profileImageView.frame.origin.y - origFrame.origin.y + (profileImageView.frame.size.height - origFrame.size.height) / 2;
        var centerX = Int((profileImage.size.width / 2.0 - deltaX / scale) * serverScale);
        var centerY = Int((profileImage.size.height / 2.0 - deltaY / scale) * serverScale);
        contents.setObject(centerX, forKey: "centerX");
        contents.setObject(centerY, forKey: "centerY");
        contents.setObject(serverScale, forKey: "scale");
        
        HigiApi().sendPost("\(HigiApi.higiApiUrl)/data/user/\(user.userId)/photoPosition", parameters: contents, success: {operation, responseObject in
            if (responseObject != nil) {
                user.photoTime = ((responseObject as NSDictionary)["photoTime"] ?? Int(NSDate().timeIntervalSince1970)) as Int;
            } else {
                user.photoTime = Int(NSDate().timeIntervalSince1970);
            }
            user.profileImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(HigiApi.higiApiUrl)/view/\(user.userId)/profile,400.png?t=\(user.photoTime)")!)!);
            if (self.fromSettings) {
                for viewController in self.navigationController!.viewControllers as [UIViewController] {
                    if (viewController.isKindOfClass(SettingsViewController)) {
                        self.navigationController!.popToViewController(viewController, animated: false);
                        break;
                    }
                }
            } else {
                ApiUtility.initializeApiData();
                Utility.gotoDashboard(self);
            }
            
            }, failure: {operation, error in
                self.showErrorAlert();
        });
    }
    
    @IBAction func pinchZoom(sender: UIPinchGestureRecognizer) {
        var scale = 1.0 + sender.scale - lastScale;
        var center = profileImageView.center;
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
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    func showErrorAlert() {
        UIAlertView(title: "Something went wrong!", message: "We were unable to reach the server. Please try again.", delegate: nil, cancelButtonTitle: "OK").show();
        reset();
    }
    
    func reset() {
        self.navigationItem.hidesBackButton = true;
        self.navigationItem.leftBarButtonItem?.customView?.hidden = false;
        spinner.hidden = true;
        doneButton.hidden = false;
    }
    
}