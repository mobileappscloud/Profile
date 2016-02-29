//
//  ProfileImageViewController.swift
//  higi
//
//  Created by Dan Harms on 7/31/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class ProfileImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var chooseLibraryButton: UIButton! {
        didSet {
            chooseLibraryButton.setTitle(NSLocalizedString("PROFILE_IMAGE_VIEW_PHOTO_LIBRARY_BUTTON_TITLE", comment: "Title for button to choose a photo from the photo library."), forState: .Normal)
        }
    }
    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.setTitle(NSLocalizedString("PROFILE_IMAGE_VIEW_PHOTO_CAPTURE_BUTTON_TITLE", comment: "Title for button to capture a photo using the device camera."), forState: .Normal)
        }
    }
    @IBOutlet weak var skipButton: UIButton! {
        didSet {
            skipButton.setTitle(NSLocalizedString("PROFILE_IMAGE_VIEW_SKIP_BUTTON_TITLE", comment: "Title for button to bypass choosing a profile image."), forState: .Normal)
        }
    }
    var spinner: CustomLoadingSpinner!
    
    var fromSettings = false;
    var dashboardSent = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = NSLocalizedString("PROFILE_IMAGE_VIEW_TITLE", comment: "Title for Profile Image view.");
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 1.0)];
        self.navigationItem.hidesBackButton = true;
        
        if (fromSettings) {
            skipButton.hidden = true;
        }
        
        chooseLibraryButton.layer.borderWidth = 1.0;
        chooseLibraryButton.layer.borderColor = Utility.colorFromHexString(Constants.higiGreen).CGColor;
        takePhotoButton.layer.borderWidth = 1.0;
        takePhotoButton.layer.borderColor = Utility.colorFromHexString(Constants.higiGreen).CGColor;
        
        spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 66, 32, 32));
        spinner.shouldAnimateFull = false;
        spinner.hidden = true;
        self.view.addSubview(spinner);
    }
    
    @IBAction func chooseFromLibrary(sender: AnyObject) {
        let imagePicker = UIImagePickerController();
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        imagePicker.allowsEditing = false;
        self.presentViewController(imagePicker, animated: true, completion: nil);
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        let imagePicker = UIImagePickerController();
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
        imagePicker.allowsEditing = false;
        self.presentViewController(imagePicker, animated: true, completion: nil);
    }
    
    @IBAction func skip(sender: AnyObject) {
        spinner.startAnimating();
        spinner.hidden = false;
        skipButton.hidden = true;
        let user = SessionData.Instance.user;
        if (user.profileImage == nil) {
            user.retrieveProfileImages();
        }
        
        ApiUtility.initializeApiData();
        Utility.gotoDashboard();
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        let image = (info[UIImagePickerControllerOriginalImage] as! UIImage).fixOrientation();
        let modifyViewController = ModifyImageViewController(nibName: "ModifyImageView", bundle: nil);
        modifyViewController.profileImage = image;
        modifyViewController.fromSettings = fromSettings;
        self.navigationController!.pushViewController(modifyViewController, animated: true);
    }

    func gotoDashboard() {
        if (SessionController.Instance.checkins != nil && SessionController.Instance.challenges != nil && SessionController.Instance.kioskList != nil && SessionController.Instance.pulseArticles.count > 0 && !dashboardSent) {
            Utility.gotoDashboard();
            dashboardSent = true;
        }
    }
}
 