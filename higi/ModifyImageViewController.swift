//
//  ModifyImageViewController.swift
//  higi
//
//  Created by Remy Panicker on 5/18/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

final class ModifyImageViewController: UIViewController {

    @IBOutlet private var profileImageView: UIImageView! {
        didSet {
            profileImageView.addGestureRecognizer(pinchGestureRecognizer)
            profileImageView.addGestureRecognizer(panGestureRecognizer)
            profileImageView.image = image
            // Maintaining legacy functionality where view is hidden because frame is manipulated after view is laid out. Hiding the view eliminates an abrupt adjustment.
            profileImageView.hidden = true
        }
    }
    
    lazy private var pinchGestureRecognizer: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        return pinch
    }()
    
    lazy private var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        return pan
    }()
    
    private var previousScale: CGFloat = 1.0
    
    private var originalProfileImageViewFrame: CGRect!
    
    @IBOutlet private var topMask: UIView!
    
    @IBOutlet private var circleMask: UIImageView!
    
    @IBOutlet private var bottomMask: UIView!
    
    @IBOutlet private var spinner: UIActivityIndicatorView!
    
    weak var delegate: ModifyImageViewControllerDelegate?
    
    /// Returns `true` if the client should only send the image position to the API because the image has already been uploaded to the server, otherwise upload the image and image position to the API.
    var resizeMode = false
    
    private(set) var imageURL: NSURL?
    private(set) var image: UIImage? {
        didSet {
            if self.isViewLoaded() && profileImageView != nil {
                layoutProfileImageView()
                profileImageView.image = image
            }
        }
    }
    
    private(set) var userController: UserController!

    private var modifyImageController = ModifyImageController()
}

extension ModifyImageViewController {
    
    override func didReceiveMemoryWarning() {
        image = nil
        profileImageView.image = nil
        
        // The warning may be received before the view presentation has completed. This delay is a quick hack to ensure we don't attempt to present the alert while the view controller presentation is in progress.
        // TODO: Reconsider solution -- this is kind of dumb
        Utility.delay(0.3, closure: { [weak self] in
            self?.showMemoryWarningAlert()
        })
    }
}

// MARK: - Config

extension ModifyImageViewController {
    
    func configure(userController: UserController, imageURL: NSURL, delegate: ModifyImageViewControllerDelegate) {
        self.userController = userController
        self.delegate = delegate
        self.imageURL = imageURL
    }
    
    func configure(userController: UserController, image: UIImage, delegate: ModifyImageViewControllerDelegate) {
        self.userController = userController
        self.image = image
        self.delegate = delegate
    }
}

// MARK: - View Lifecycle 

extension ModifyImageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if image == nil, let _ = imageURL {
            fetchImage()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        layoutProfileImageView()
    }
    
    private func fetchImage() {
        guard let imageURL = imageURL else { return }
        
        toggleElements(false)
        self.navigationItem.leftBarButtonItem?.enabled = true
        modifyImageController.fetchImage(withURL: imageURL, completion: { [weak self] (image) in
            guard let strongSelf = self,
                let image = image else { return }
            
            dispatch_async(dispatch_get_main_queue(), { [weak strongSelf] in
                guard let strongSelf = strongSelf else { return }
                
                strongSelf.image = image
                strongSelf.toggleElements(true)
                })
            })
    }

    private func layoutProfileImageView() {
        guard let image = image else { return }
        
        // size image view to fill view's height or width based on larger dimension and scale to maintain aspect ratio
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        
        if (image.size.width > image.size.height) {
            width = self.view.frame.size.width
            height = self.view.frame.size.width * image.size.height / image.size.width
        } else {
            width = self.view.frame.size.width * image.size.width / image.size.height
            height = self.view.frame.width
        }
        
        // Center align image horizontally/vertically in view
        originalProfileImageViewFrame = CGRect(x: self.view.frame.size.width * 0.5 - width * 0.5, y: self.view.frame.size.height * 0.5 - height * 0.5, width: width, height: height)
        
        if profileImageView.hidden {
            profileImageView.alpha = 0.0
            profileImageView.hidden = false
            UIView.animateWithDuration(0.2, animations: {
                self.profileImageView.alpha = 1.0
                self.profileImageView.frame = self.originalProfileImageViewFrame
            })
        }
    }
}

// MARK: - Gesture Recognizer

extension ModifyImageViewController {
    
    func didPinch(sender: UIPinchGestureRecognizer) {
        let scale = 1.0 + sender.scale - previousScale;
        let center = profileImageView.center;

        profileImageView.frame.size = CGSize(width: profileImageView.frame.size.width * scale, height: profileImageView.frame.size.height * scale);
        profileImageView.center = center;

        previousScale = sender.scale;
        if (sender.state == UIGestureRecognizerState.Ended) {
            previousScale = 1;
        }
    }
    
    func didPan(sender: UIPanGestureRecognizer) {
        profileImageView.frame.origin.x += sender.translationInView(self.view).x
        profileImageView.frame.origin.y += sender.translationInView(self.view).y
        
        sender.setTranslation(CGPointZero, inView: self.view)
    }
}

// MARK: - UI Action

extension ModifyImageViewController {
    
    @IBAction func didTapCancelButton(sender: UIBarButtonItem) {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.delegate?.modifyImageViewControllerDidCancel(self)
            })
    }
    
    @IBAction func didTapDoneButton(sender: UIBarButtonItem) {
        toggleElements(false)
        
        if resizeMode {
            updatePosition()
        } else {
            uploadImage()
        }
    }
}

// MARK: - Network Tasks

extension ModifyImageViewController {
    
    private func uploadImage() {
        guard let image = image else { return }
        
        modifyImageController.update(userController.user, image: image, success: { [weak self] in
            self?.updatePosition()
            }, failure: { [weak self] (error) in
                self?.showErrorAlert(error)
        })
    }
    
    private func updatePosition() {
        guard let image = image else { return }
        
        let (centerX, centerY, serverScale) = modifyImageController.calculatePosition(self.view.frame, originalImageViewFrame: originalProfileImageViewFrame, imageViewFrame: profileImageView.frame, image: image)
        
        modifyImageController.updateImagePosition(forUser: userController.user, centerX: centerX, centerY: centerY, serverScale: serverScale, success: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.modifyImageViewController(strongSelf, didModifyWithSuccess: true)
            }, failure: { [weak self] in
                self?.showErrorAlert(nil)
        })
    }
}

// MARK: -

extension ModifyImageViewController {
    
    private func showErrorAlert(error: NSError?) {
        let title = NSLocalizedString("MODIFY_IMAGE_VIEW_SERVER_ERROR_ALERT_TITLE", comment: "Title for alert which is displayed if the server is unreachable.")
        let message = NSLocalizedString("MODIFY_IMAGE_VIEW_SERVER_ERROR_ALERT_MESSAGE", comment: "Message for alert which is displayed if the server is unreachable.")
        let dismissTitle = NSLocalizedString("MODIFY_IMAGE_VIEW_SERVER_ERROR_ALERT_ACTION_TITLE_DISMISS", comment: "Title for alert action to dismiss alert which is displayed if the server is unreachable.")
        
        let displayMessage = (error?.userInfo[NSLocalizedDescriptionKey] as? String) ?? message
        let alertController = UIAlertController(title: title, message: displayMessage, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: dismissTitle, style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.toggleElements(true)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    private func showMemoryWarningAlert() {
        let title = NSLocalizedString("MODIFY_IMAGE_VIEW_MEMORY_WARNING_ALERT_TITLE", comment: "Title for alert which is displayed if the view receives a memory warning.")
        let message = NSLocalizedString("MODIFY_IMAGE_VIEW_MEMORY_WARNING_ALERT_MESSAGE", comment: "Message for alert which is displayed if the view receives a memory warning.")
        let dismissTitle = NSLocalizedString("MODIFY_IMAGE_VIEW_MEMORY_WARNING_ALERT_ACTION_TITLE_DISMISS", comment: "Title for action to dismiss alert which is displayed if the view receives a memory warning.")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismiss = UIAlertAction(title: dismissTitle, style: .Default, handler: { (action) in
            self.delegate?.modifyImageViewControllerDidCancel(self)
        })
        alertController.addAction(dismiss)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.toggleElements(false)
            self.view.userInteractionEnabled = false
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    private func toggleElements(enableInteraction: Bool) {
        self.navigationItem.leftBarButtonItem?.enabled = enableInteraction
        self.navigationItem.rightBarButtonItem?.enabled = enableInteraction
        
        let spinnerAction = enableInteraction ? spinner.stopAnimating : spinner.startAnimating
        spinnerAction()
        spinner.hidden = enableInteraction
    }
}

// MARK: - Protocol

protocol ModifyImageViewControllerDelegate: class {
    
    func modifyImageViewController(viewController: ModifyImageViewController, didModifyWithSuccess: Bool)
    
    func modifyImageViewControllerDidCancel(viewController: ModifyImageViewController)
}
