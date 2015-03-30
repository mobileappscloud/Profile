//
//  SessionController.swift
//  higi
//
//  Created by Dan Harms on 6/13/14.
//  Copyright (c) 2014 higi, LLC. All rights reserved.
//

import Foundation
import HealthKit

class SessionController {
    
    class var Instance: SessionController {
        return SessionControllerSharedInstance;
    }
    
    var checkins: [HigiCheckin]!;
    
    var activities: [HigiActivity]!;
    
    var challenges: [HigiChallenge]!;
    
    var pulseArticles: [PulseArticle] = [];
    
    var kioskList: [KioskInfo]!;
    
    var healthStore: HKHealthStore!;
    
    var devices: [String: ActivityDevice] = [:];
    
    var earnditError = false, askTouchId = true;
    
    func reset() {
        checkins = nil;
        activities = nil;
        challenges = nil;
        devices = [:];
    }
    
    
}

let SessionControllerSharedInstance = SessionController();