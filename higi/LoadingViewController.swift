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
        let spinner = CustomLoadingSpinner(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 16, UIScreen.mainScreen().bounds.size.height / 2 + 32, 32, 32))
        return spinner
    }()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
    }
}
