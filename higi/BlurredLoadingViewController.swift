//
//  BlurredLoadingViewController.swift
//  higi
//
//  Created by Remy Panicker on 6/10/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class BlurredLoadingViewController: UIViewController {
    
    @IBOutlet private var spinnerContainer: UIView!
    @IBOutlet private var spinnerContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var spinnerContainerWidthConstraint: NSLayoutConstraint!
    
    private lazy var spinner: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(0, 0, self.spinnerContainerWidthConstraint.constant, self.spinnerContainerHeightConstraint.constant))
        return spinner
    }()
}

// MARK: - View Lifecycle

extension BlurredLoadingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerContainer.addSubview(spinner)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        spinner.startAnimating()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        spinner.stopAnimating()
    }
}

// MARK: - Convenience

extension BlurredLoadingViewController {
    
    func show(parentViewController: UIViewController) {
        parentViewController.addChildViewController(self)
        self.view.alpha = 0.0
        parentViewController.view.addSubview(self.view, pinToEdges: true)
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 1.0
        })
        self.didMoveToParentViewController(parentViewController)
    }
    
    func hide() {
        guard let parentViewController = parentViewController else { return }
        
        self.willMoveToParentViewController(nil)
        parentViewController.view.willRemoveSubview(self.view)
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 0.0
            }, completion: { (success) in
                self.view.removeFromSuperview()
                self.didMoveToParentViewController(nil)
        })
    }
}
