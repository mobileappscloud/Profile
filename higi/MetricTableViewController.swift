//
//  MetricTableViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/3/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

final class MetricTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableViewConfigurator: MetricTableViewConfigurator?
    
    var tableDataSource: UITableViewDataSource!
    var tableViewDelegate: UITableViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self.tableDataSource
        self.tableView.delegate = self.tableViewDelegate
        
        self.tableViewConfigurator?.configureTableView(self.tableView)
    }
}

protocol MetricTableViewConfigurator {
    
    func configureTableView(tableView: UITableView)
}

extension MetricTableViewConfigurator {
    
    func configureTableView(tableView: UITableView) {
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        tableView.registerNib(UINib(nibName: "MetricTableViewCell", bundle: nil), forCellReuseIdentifier: MetricTableViewCell.cellReuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60.0
    }
}
