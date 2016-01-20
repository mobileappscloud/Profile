//
//  UtilityTests.swift
//  higi
//
//  Created by Remy Panicker on 1/20/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import XCTest
@testable import higi

class UtilityTests: XCTestCase {

    func testMinimumVersionComparison() {
        
        let testCases: [(String, String, Bool)] = [
            // basic integer comparison
            ("1", "1", false),
            ("1", "0", true),
            ("2", "1", true),
            ("0", "3", false),
            ("33", "41", false),
            
            // point releases
            ("1.0", "1", true),
            ("1", "1.0", true),
            ("1.0", "1.0", true),
            ("2.2.1.3", "3", false),
            ("2.2.2.2.", "2", true),
            ("2", "2.2.2.", false),
            
            // alpha-numeric
            ("x", "y", false),
            ("2.1", "2.x", true),
            ("x.x", "2.x", false),
            ("3.1", "x.1", true),
            
            // empty strings
            ("", "", true),
            ("", "1", false),
            ("1", "", true),
            
            // misc
            (" ", " ", true),
            ("1", " ", true),
            (" ", "2", false),
            ("2.2", " 2.2 ", true)
        ]
        
        for (appVersion, minVersion, expectedResult) in testCases {
            let result = Utility.appVersion(appVersion, meetsMinimumVersionRequirement: minVersion)
            XCTAssertEqual(result, expectedResult, "Testing app version \(appVersion) against minimum version \(minVersion) resulted in \(result). Expected \(expectedResult).")
        }
    }

}
