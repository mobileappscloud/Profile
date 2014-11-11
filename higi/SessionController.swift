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
    
    var healthStore: HKHealthStore!;
    
    func reset() {
        checkins = [];
    }
    
    
}

let SessionControllerSharedInstance = SessionController();