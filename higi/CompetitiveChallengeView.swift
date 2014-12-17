//
//  CompetitiveChallengeView.swift
//  higi
//
//  Created by Joe Sangervasi on 10/31/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class CompetitiveChallengeView: UIView {

    @IBOutlet var firstPositionAvatar: UIImageView!
    @IBOutlet var secondPositionAvatar: UIImageView!
    @IBOutlet var thirdPositionAvatar: UIImageView!
    @IBOutlet var firstPositionRank: UILabel!
    @IBOutlet var secondPositionRank: UILabel!
    @IBOutlet var thirdPositionRank: UILabel!
    @IBOutlet var firstPositionName: UILabel!
    @IBOutlet var secondPositionName: UILabel!
    @IBOutlet var thirdPositionName: UILabel!
    @IBOutlet var firstPositionProgressBar: UIView!
    @IBOutlet var secondPositionProgressBar: UIView!
    @IBOutlet var thirdPositionProgressBar: UIView!
    @IBOutlet var firstPositionPoints: UILabel!
    @IBOutlet var secondPositionPoints: UILabel!
    @IBOutlet var thirdPositionPoints: UILabel!
    
    class func instanceFromNib() -> CompetitiveChallengeView {
        return UINib(nibName: "CompetitiveChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as CompetitiveChallengeView
    }
}