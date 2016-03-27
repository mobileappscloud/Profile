//
//  CommunitiesViewController.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

final class CommunitiesViewController: UIViewController {
    
    struct StoryBoard {
        struct Scene {
            static let communitiesIdentifier = "CommunitiesViewControllerStoryboardIdentifier"
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("COMMUNITIES_VIEW_TITLE", comment: "Title for communities view.")
    }
}
