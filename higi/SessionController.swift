//
//  SessionController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation

typealias HigiActivitySummary = (totalPoints: Int, activities: [HigiActivity])

final class SessionController {
    
    class var Instance: SessionController {
        return SessionControllerSharedInstance;
    }
    
    var checkins: [HigiCheckin]! = [];
    
    var activities: [String : HigiActivitySummary] = [:];
    
    var devices: [String: ActivityDevice] = [:];
    
    var earnditError = false, askTouchId = true, showQrCheckinCard = false;
    
    func reset() {
        checkins = nil;
        activities = [:];
        devices = [:];
        showQrCheckinCard = false;
    }
}

let SessionControllerSharedInstance = SessionController();
