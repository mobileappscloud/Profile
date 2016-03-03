//
//  LoadingViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/18/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    private lazy var spinner: CustomLoadingSpinner = {
        let defaultSize: CGFloat = 32.0
        let spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - defaultSize, UIScreen.mainScreen().bounds.size.height / 2 + defaultSize, defaultSize, defaultSize))
        return spinner
    }()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
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
