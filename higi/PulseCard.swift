//
//  PulseCard.swift
//  higi
//
//  Created by Dan Harms on 1/20/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class PulseCard: UIView {
    
    @IBOutlet weak var topImage: UIImageView!
    
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var topExcerpt: UILabel!
    @IBOutlet weak var middleArticleContainer: UIView!
    @IBOutlet weak var middleImage: UIImageView!
    @IBOutlet weak var middleTitle: UILabel!
    @IBOutlet weak var middleExcerpt: UILabel!
    @IBOutlet weak var bottomArticleContainer: UIView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var bottomTitle: UILabel!
    @IBOutlet weak var bottomExcerpt: UILabel!
}