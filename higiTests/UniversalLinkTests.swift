//
//  UniversalLinkTests.swift
//  higi
//
//  Created by Remy Panicker on 10/16/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import XCTest
import higi

class UniversalLinkTests: XCTestCase {
    
    private let validUniversalLinks = [
        "https://www.higi.com/challenge/view/id/testSucceeded",
        "https://www.higi.com/challenge/dashboard",
        "https://www.higi.com/locator",
        "https://www.higi.com/pulse",
        "https://www.higi.com/pulse/testSucceeded",
        "https://www.higi.com/profile/checkin/testSucceeded",
        "https://www.higi.com/stats",
        "https://www.higi.com/stats/blood_pressure",
        "https://www.higi.com/stats/pulse",
        "https://www.higi.com/stats/weight",
        "https://www.higi.com/activity/list",
        "https://higi.com/challenge/view/id/testSucceeded",
        "https://higi.com/challenge/dashboard",
        "https://higi.com/locator",
        "https://higi.com/pulse",
        "https://higi.com/pulse/testSucceeded",
        "https://higi.com/profile/checkin/testSucceeded",
        "https://higi.com/stats",
        "https://higi.com/stats/blood_pressure",
        "https://higi.com/stats/pulse",
        "https://higi.com/stats/weight",
        "https://higi.com/activity/list"
    ]
    
    private let invalidPathLinks = [
        "https://www.higi.com/challenge/view/id",
        "https://www.higi.com/challenge/view/id/",
        "https://www.higi.com/challenge/dashboard/invalidPath",
        "https://www.higi.com/locat",
        "https://www.higi.com/locator/invalidPath",
        "https://www.higi.com/pulse/id/invalidPath",
        "https://www.higi.com/profile",
        "https://www.higi.com/profile/checkin",
        "https://www.higi.com/profile/checkin/invalidPath/2",
        "https://www.higi.com/stats/invalidPath",
        "https://www.higi.com/activity",
        "https://www.higi.com/activity/",
        "https://www.higi.com/activity/invalidPath",
        "https://higi.com/challenge/view/id",
        "https://higi.com/challenge/view/id/",
        "https://higi.com/challenge/dashboard/invalidPath",
        "https://higi.com/locat",
        "https://higi.com/locator/invalidPath",
        "https://higi.com/pulse/id/invalidPath",
        "https://higi.com/profile",
        "https://higi.com/profile/checkin",
        "https://higi.com/profile/checkin/invalidPath/2",
        "https://higi.com/stats/invalidPath",
        "https://higi.com/activity",
        "https://higi.com/activity/",
        "https://higi.com/activity/invalidPath",
    ]
    
    func testValidUniversalLinks() {
        for URLString in validUniversalLinks {
            let URL = NSURL(string: URLString)!
            XCTAssertTrue(UniversalLink.canHandleURL(URL), "Incorrectly failed URL: \(URL.absoluteString)")
        }
    }
    
    func testInvalidPathLinks() {
        for URLString in invalidPathLinks {
            let URL = NSURL(string: URLString)!
            XCTAssertFalse(UniversalLink.canHandleURL(URL), "Incorrectly validated path for URL: \(URL.absoluteString)")
        }
    }

}
