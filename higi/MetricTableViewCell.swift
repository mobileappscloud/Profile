//
//  MetricTableViewCell.swift
//  higi
//
//  Created by Remy Panicker on 12/9/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

final class MetricTableViewCell: UITableViewCell {

    static let cellReuseIdentifier = "MetricTableViewCellReuseIdentifier"
    
    @IBOutlet var checkinSummaryView: MetricCheckinSummaryView!
    
}
