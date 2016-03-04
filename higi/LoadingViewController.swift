//
//  LoadingViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/18/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet private var spinnerContainer: UIView!
    @IBOutlet private var spinnerContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var spinnerContainerWidthContainer: NSLayoutConstraint!
    
    private lazy var spinner: CustomLoadingSpinner = {
        let spinner = CustomLoadingSpinner(frame: CGRectMake(0, 0, self.spinnerContainerWidthContainer.constant, self.spinnerContainerHeightConstraint.constant))
        return spinner
    }()
    
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

extension LoadingViewController {
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}
