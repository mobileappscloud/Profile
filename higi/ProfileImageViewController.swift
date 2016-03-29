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
        
        self.navigationItem.hidesBackButton = !fromSettings
        
        if (fromSettings) {
            skipButton.hidden = true;
        }
        
        chooseLibraryButton.layer.borderWidth = 1.0;
        chooseLibraryButton.layer.borderColor = Theme.Color.primary.CGColor;
        takePhotoButton.layer.borderWidth = 1.0;
        takePhotoButton.layer.borderColor = Theme.Color.primary.CGColor;
        
        spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false;
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let user = SessionData.Instance.user;
            if (user.profileImage == nil) {
                user.retrieveProfileImages();
            }
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)

            self.spinner.hidden = false;
            self.spinner.startAnimating();

            self.skipButton.hidden = true;
            self.takePhotoButton.enabled = false
            self.chooseLibraryButton.enabled = false
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue(), {
            
            picker.dismissViewControllerAnimated(true, completion: nil);
            
            let image = (info[UIImagePickerControllerOriginalImage] as! UIImage).fixOrientation();
            
            let modifyViewController = ModifyImageViewController(nibName: "ModifyImageView", bundle: nil);
            modifyViewController.profileImage = image;
            modifyViewController.fromSettings = self.fromSettings;
            modifyViewController.delegate = self
            let modifyNav = UINavigationController(rootViewController: modifyViewController)
            
            self.navigationController?.presentViewController(modifyNav, animated: true, completion: nil)
        })
    }
}

extension ProfileImageViewController: ModifyImageViewControllerDelegate {
    
    func modifyImageViewController(viewController: ModifyImageViewController, didTapDoneWithSuccess: Bool) {
        if fromSettings {
            viewController.dismissViewControllerAnimated(false, completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            })
        } else {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func modifyImageViewControllerDidTapCancel(viewController: ModifyImageViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)        
    }
}
 