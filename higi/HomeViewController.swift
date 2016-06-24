//
//  HomeViewController.swift
//  higi
//
//  Created by Remy Panicker on 6/23/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class HomeViewController: UIViewController {

    private var feedViewController: FeedViewController!
    
    private(set) var userController: UserController!
    
    func configure(userController: UserController) {
        self.userController = userController
    }
}

extension HomeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("HOME_VIEW_TITLE", comment: "Title for home view.")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            feedViewController = segue.destinationViewController as! FeedViewController
        }
    }
}