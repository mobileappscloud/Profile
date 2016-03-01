//
//  UniversalLinkTests.swift
//  higi
//
//  Created by Remy Panicker on 10/16/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import XCTest
@testable import higi

class UniversalLinkTests: XCTestCase {
    
    private let validUniversalLinks: [(String, PathType)] = [
        // URLs with WWW subdomain
        ("https://www.higi.com/challenge/view/id/testSucceeded", .ChallengeDetail),
        ("https://www.higi.com/challenge/view/id/2398hfwf9h329r8/join/testSucceeded", .ChallengeDetailSubPath),
        ("https://www.higi.com/challenge/view/id/2398hfwf9h329r8/invite/testSucceeded", .ChallengeDetailSubPath),
        ("https://www.higi.com/challenge/view/id/2398hfwf9h329r8/foo/bar/etc/testSucceeded", .ChallengeDetailSubPath),
        ("https://www.higi.com/challenge/dashboard", .ChallengeDashboard),
        ("https://www.higi.com/settings/apps", .ConnectDevice),
        ("https://www.higi.com/locator", .StationLocator),
        ("https://www.higi.com/pulse", .PulseHome),
        ("https://www.higi.com/pulse/testSucceeded", .PulseArticle),
        ("https://www.higi.com/pulse/2016/01/02/this-is-an-article-permalink", .PulseArticle),
        ("https://www.higi.com/profile/checkin/testSucceeded", .DailySummary),
        ("https://www.higi.com/stats", .Metrics),
        ("https://www.higi.com/stats/blood_pressure", .MetricsBloodPressure),
        ("https://www.higi.com/stats/pulse", .MetricsPulse),
        ("https://www.higi.com/stats/weight", .MetricsWeight),
        ("https://www.higi.com/activity/list", .ActivityList),

        // URLs without WWW subdomain
        ("https://higi.com/challenge/view/id/testSucceeded", .ChallengeDetail),
        ("https://higi.com/challenge/view/id/2398hfwf9h329r8/join/testSucceeded", .ChallengeDetailSubPath),
        ("https://higi.com/challenge/view/id/2398hfwf9h329r8/invite/testSucceeded", .ChallengeDetailSubPath),
        ("https://higi.com/challenge/view/id/2398hfwf9h329r8/foo/bar/etc/testSucceeded", .ChallengeDetailSubPath),
        ("https://higi.com/challenge/dashboard", .ChallengeDashboard),
        ("https://higi.com/settings/apps", .ConnectDevice),
        ("https://higi.com/locator", .StationLocator),
        ("https://higi.com/pulse", .PulseHome),
        ("https://higi.com/pulse/testSucceeded", .PulseArticle),
        ("https://higi.com/pulse/2016/01/02/this-is-an-article-permalink", .PulseArticle),
        ("https://higi.com/profile/checkin/testSucceeded", .DailySummary),
        ("https://higi.com/stats", .Metrics),
        ("https://higi.com/stats/blood_pressure", .MetricsBloodPressure),
        ("https://higi.com/stats/pulse", .MetricsPulse),
        ("https://higi.com/stats/weight", .MetricsWeight),
        ("https://higi.com/activity/list", .ActivityList)
    ]
    
    private let invalidPathLinks = [
        "https://www.higi.com/challenge/view/id",
        "https://www.higi.com/challenge/view/id/",
        "https://www.higi.com/challenge/dashboard/invalidPath",
        "https://www.higi.com/locat",
        "https://www.higi.com/locator/invalidPath",
        "https://www.higi.com/profile",
        "https://www.higi.com/profile/checkin",
        "https://www.higi.com/profile/checkin/invalidPath/2",
        "https://www.higi.com/stats/invalidPath",
        "https://www.higi.com/activity",
        "https://www.higi.com/activity/",
        "https://www.higi.com/activity/invalidPath",
        "https://www.higi.com/settings/apps/invalidPath",
        "https://higi.com/challenge/view/id",
        "https://higi.com/challenge/dashboard/invalidPath",
        "https://higi.com/locat",
        "https://higi.com/locator/invalidPath",
        "https://higi.com/profile",
        "https://higi.com/profile/checkin",
        "https://higi.com/profile/checkin/invalidPath/2",
        "https://higi.com/stats/invalidPath",
        "https://higi.com/activity",
        "https://higi.com/activity/invalidPath",
        "https://higi.com/settings/apps/invalidPath"
    ]
    
    func testValidUniversalLinks() {
        for (URLString, _) in validUniversalLinks {
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
    
    func testHandlingOfValidUniversalLinks() {
        for (URLString, pathType) in validUniversalLinks {
            let URL = NSURL(string: URLString)!
            
            let parsedResults = UniversalLink.parsePath(forURL: URL)
            XCTAssertEqual(pathType, parsedResults.pathType, "Parser incorrectly identified path type for URL: \(URL.absoluteString)")
            
            switch pathType {
            case .PulseArticle:
                fallthrough
            case .DailySummary:
                fallthrough
            case .ChallengeDetail:
                fallthrough
            case .ChallengeDetailSubPath:
                XCTAssertNotNil(parsedResults.parameters, "Expected parsed parameter, but got nil instead for \(pathType) with URL \(URL.absoluteString).")
                
            case .ActivityList:
                fallthrough
            case .ChallengeDashboard:
                fallthrough
            case .Metrics:
                fallthrough
            case .MetricsBloodPressure:
                fallthrough
            case .MetricsPulse:
                fallthrough
            case .MetricsWeight:
                fallthrough
            case .StationLocator:
                fallthrough
            case .PulseHome:
                fallthrough
            case .ConnectDevice:
                break
            }
        }
    }

}
