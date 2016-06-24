//
//  FeedViewController.swift
//  higi
//
//  Created by Remy Panicker on 6/21/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

final class FeedViewController: UIViewController {

    @IBOutlet private var tableView: UITableView! {
        didSet {
            
        }
    }
    
    private(set) var userController: UserController?
    
    private let feedController = FeedController()
    
    func configure(userController: UserController) {
        self.userController = userController
    }
}

extension FeedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch()
    }
}

extension FeedViewController {
    
    private func fetch() {
        
    }
}

extension FeedViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension FeedViewController: UITableViewDelegate {
    
}
