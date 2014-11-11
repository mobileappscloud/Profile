//
//  GoalChallengeView.swift
//  higi
//
//  Created by Joe Sangervasi on 10/31/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

class GoalChallengeView: UIView {
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var rank: UILabel!
    @IBOutlet var progressBar: UIView!
    
    class func instanceFromNib() -> GoalChallengeView {
        return UINib(nibName: "GoalChallengeView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as GoalChallengeView
    }
    
}