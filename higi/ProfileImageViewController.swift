//
//  ProfileImageViewController.swift
//  higi
//
//  Created by Dan Harms on 7/31/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ProfileImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var chooseLibraryButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var fromSettings = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "What do you look like?";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 1.0)];
        self.navigationItem.hidesBackButton = true;
        
        if (fromSettings) {
            (self.navigationController as MainNavigationController).revealController.panGestureRecognizer().enabled = false;
            var backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
            backButton.setBackgroundImage(UIImage(named: "btn_back_black.png"), forState: UIControlState.Normal);
            backButton.addTarget(self, action: "goBack:", forControlEvents: UIControlEvents.TouchUpInside);
            backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30);
            var backBarItem = UIBarButtonItem(customView: backButton);
            self.navigationItem.leftBarButtonItem = backBarItem;
            
            skipButton.hidden = true;
        }
        
        chooseLibraryButton.layer.borderWidth = 1.0;
        chooseLibraryButton.layer.borderColor = Utility.colorFromHexString("#76C044").CGColor;
        takePhotoButton.layer.borderWidth = 1.0;
        takePhotoButton.layer.borderColor = Utility.colorFromHexString("#76C044").CGColor;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    @IBAction func chooseFromLibrary(sender: AnyObject) {
        var imagePicker = UIImagePickerController();
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        imagePicker.allowsEditing = false;
        self.presentViewController(imagePicker, animated: true, completion: nil);
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        var imagePicker = UIImagePickerController();
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
        imagePicker.allowsEditing = false;
        self.presentViewController(imagePicker, animated: true, completion: nil);
    }
    
    @IBAction func skip(sender: AnyObject) {
        spinner.hidden = false;
        skipButton.hidden = true;
        var user = SessionData.Instance.user;
        if (user.profileImage == nil) {
            user.retrieveProfileImages();
        }
        
        Utility.gotoDashboard(self);
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        var image = (info[UIImagePickerControllerOriginalImage] as UIImage).fixOrientation();
        var modifyViewController = ModifyImageViewController(nibName: "ModifyImageView", bundle: nil);
        modifyViewController.profileImage = image;
        modifyViewController.fromSettings = fromSettings;
        self.navigationController!.pushViewController(modifyViewController, animated: true);
    }
    
    func goBack(sender: AnyObject!) {
        self.navigationController!.popViewControllerAnimated(true);
    }
    
}
 