//
//  ProfileImageViewController.swift
//  higi
//
//  Created by Remy Panicker on 5/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ProfileImageViewController: UIViewController {

    @IBOutlet private var photoLibraryButton: UIButton! {
        didSet {
            photoLibraryButton.setTitle(NSLocalizedString("PROFILE_IMAGE_VIEW_PHOTO_LIBRARY_BUTTON_TITLE", comment: "Title for button to choose a photo from the photo library."), forState: .Normal)
            photoLibraryButton.layer.borderWidth = 1.0
            photoLibraryButton.layer.borderColor = Theme.Color.primary.CGColor
        }
    }
    
    @IBOutlet private var captureButton: UIButton! {
        didSet {
            captureButton.setTitle(NSLocalizedString("PROFILE_IMAGE_VIEW_PHOTO_CAPTURE_BUTTON_TITLE", comment: "Title for button to capture a photo using the device camera."), forState: .Normal)
            captureButton.layer.borderWidth = 1.0
            captureButton.layer.borderColor = Theme.Color.primary.CGColor
        }
    }
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    @IBOutlet private var skipButton: UIButton! {
        didSet {
            skipButton.setTitle(NSLocalizedString("PROFILE_IMAGE_VIEW_SKIP_BUTTON_TITLE", comment: "Title for button to bypass choosing a profile image."), forState: .Normal)
        }
    }
    
    lazy private var spinner: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height - 150 - self.topLayoutGuide.length, 32, 32))
        spinner.shouldAnimateFull = false
        return spinner
    }()
    
    var hideSkipButton = true
    
    var hideCancelButton = true
    
    private(set) weak var delegate: ProfileImageViewControllerDelegate?
    
    private(set) var userController: UserController!
}

// MARK: - Configuration

extension ProfileImageViewController {
    
    func configure(userController: UserController, delegate: ProfileImageViewControllerDelegate) {
        self.userController = userController
        self.delegate = delegate
    }
}

// MARK: - View Lifecycle

extension ProfileImageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("PROFILE_IMAGE_VIEW_TITLE", comment: "Title for Profile Image view.")
        
        spinner.hidden = true
        self.view.addSubview(spinner)
        self.view.sendSubviewToBack(spinner)
        
        if hideCancelButton {
            self.navigationItem.rightBarButtonItem = nil
        }
        skipButton.hidden = hideSkipButton
        captureButton.enabled = UIImagePickerController.isCameraDeviceAvailable(.Front) || UIImagePickerController.isCameraDeviceAvailable(.Rear)
    }
}

// MARK: - UI Action

extension ProfileImageViewController {
    
    @IBAction func didTapCancelButton(sender: UIBarButtonItem) {
        delegate?.profileImageViewDidCancel(self)
    }
    
    @IBAction func didTapPhotoLibraryButton(sender: UIButton) {
        showImagePicker(.PhotoLibrary)
    }
    
    @IBAction func didTapCaptureButton(sender: UIButton) {
        showImagePicker(.Camera)
    }
    
    @IBAction func didTapSkipButton(sender: UIButton) {
        delegate?.profileImageViewDidCancel(self)
    }
    
    private func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - Image Picker

extension ProfileImageViewController: UINavigationControllerDelegate {}
extension ProfileImageViewController: UIImagePickerControllerDelegate {
 
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
       
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let image = originalImage.fixOrientation();
        
        let storyboard = UIStoryboard(name: "ModifyImage", bundle: nil)
        guard let modifyNav = storyboard.instantiateInitialViewController() as? UINavigationController,
            let modifyViewController = modifyNav.topViewController as? ModifyImageViewController else {
                return
        }
        modifyViewController.configure(userController, image: image, delegate: self)
        
        dispatch_async(dispatch_get_main_queue(), {
            picker.dismissViewControllerAnimated(false, completion: nil)
            self.presentViewController(modifyNav, animated: true, completion: nil)
        })
    }
}

// MARK: - Modify Image

extension ProfileImageViewController: ModifyImageViewControllerDelegate {
    
    func modifyImageViewControllerDidCancel(viewController: ModifyImageViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            viewController.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func modifyImageViewController(viewController: ModifyImageViewController, didModifyWithSuccess: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            viewController.dismissViewControllerAnimated(true, completion: nil)
        })
        delegate?.profileImageViewDidUpdateUserImage(self, userController: userController)
    }
}

// MARK: - Protocol

protocol ProfileImageViewControllerDelegate: class {
    
    func profileImageViewDidUpdateUserImage(viewController: ProfileImageViewController, userController: UserController)
    
    func profileImageViewDidCancel(viewController: ProfileImageViewController)
}
