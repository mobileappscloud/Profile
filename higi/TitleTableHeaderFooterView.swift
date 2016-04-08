//
//  TitleTableHeaderFooterView.swift
//  higi
//
//  Created by Remy Panicker on 4/7/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

class TitleTableHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.text = ""
        }
    }
}
