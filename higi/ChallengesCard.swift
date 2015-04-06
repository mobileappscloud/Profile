//
//  ChallengesCard.swift
//  higi
//
//  Created by Dan Harms on 1/20/15.
//  Copyright (c) 2015 higi, LLC. All rights reserved.
//

import Foundation

class ChallengesCard: UIView {
    
    @IBOutlet weak var challengeBox: UIView!
    @IBOutlet weak var challengeAvatar: UIImageView!
    @IBOutlet weak var challengeTitle: UILabel!
    @IBOutlet weak var blankStateImage: UIImageView!
    @IBOutlet weak var loadingContainer: UIView!
    var spinner: CustomLoadingSpinner!
}