//
//  CommunityTests.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import XCTest
@testable import higi

class CommunityTests: XCTestCase {
    
    /**
     Test required initializaer to ensure object is initialized as expected.
     */
    func testInit() {
        let community = Community(identifier: "1", organizationIdentifier: "1", memberCount: 1, isMember: true, canLeave: true, isActive: true, isPublished: true, name: "test", description: "test desc", missionStatement: "test mission", locale: "en-US", isPublic: true)
        
        XCTAssertEqual(community.identifier, "1")
        XCTAssertEqual(community.organizationIdentifier, "1")
        XCTAssertEqual(community.memberCount, 1)
        XCTAssertEqual(community.isMember, true)
        XCTAssertEqual(community.canLeave, true)
        XCTAssertEqual(community.isActive, true)
        XCTAssertEqual(community.isPublished, true)
        XCTAssertEqual(community.name, "test")
        XCTAssertEqual(community.description, "test desc")
        XCTAssertEqual(community.missionStatement, "test mission")
        XCTAssertEqual(community.locale, "en-US")
        XCTAssertEqual(community.isPublic, true)
    }
}

extension CommunityTests {
    
    /**
     Test dictionary initializer to ensure a valid dictionary initialize a valid object.
     */
    func testDictionaryInit() {
        let dictionary = JSONFileReader.JSON("community") as! NSDictionary
        let community = Community(dictionary: dictionary)
        XCTAssertNotNil(community)
        
        XCTAssertEqual(community?.identifier, "um56HoCKZkmymMPwEpR2Kw")
        XCTAssertEqual(community?.organizationIdentifier, "05NzHO7OY0e1UUiMM38eiQ")
        XCTAssertEqual(community?.memberCount, 1)
        XCTAssertEqual(community?.isMember, false)
        XCTAssertEqual(community?.canLeave, true)
        XCTAssertEqual(community?.isActive, true)
        XCTAssertEqual(community?.isPublished, false)
        XCTAssertEqual(community?.name, "Next test community")
        XCTAssertEqual(community?.description, "Next test description on community 05NzHO7OY0e1UUiMM38eiQ")
        XCTAssertEqual(community?.missionStatement, "Next test community on 05NzHO7OY0e1UUiMM38eiQ")
        XCTAssertEqual(community?.locale, "en-US")
        XCTAssertEqual(community?.isPublic, false)
        XCTAssertEqual(community?.logoURL?.absoluteString, "https://corecommunitydev002.blob.core.windows.net/0c9d46a7-04bd-498d-8602-e65d6ec6782d/72e751f1-7944-4335-b89c-f35cf1b1bf91.jpg")
        XCTAssertEqual(community?.headerImageURL?.absoluteString, "https://corecommunitydev002.blob.core.windows.net/0c9d46a7-04bd-498d-8602-e65d6ec6782d/e867d6ce-90f0-4b8e-8727-45486067ad24.jpg")
    }
    
    /**
     Test dictionary initializer to verify that a partial dictionary with required keys initializes a valid object.
     */
    func testPartialValidDictionaryInit() {
        let dictionary = JSONFileReader.JSON("community-partial-valid") as! NSDictionary
        let community = Community(dictionary: dictionary)
        XCTAssertNotNil(community)
        
        XCTAssertEqual(community?.identifier, "um56HoCKZkmymMPwEpR2Kw")
        XCTAssertEqual(community?.organizationIdentifier, "05NzHO7OY0e1UUiMM38eiQ")
        XCTAssertEqual(community?.memberCount, 1)
        XCTAssertEqual(community?.isMember, false)
        XCTAssertEqual(community?.canLeave, true)
        XCTAssertEqual(community?.isActive, true)
        XCTAssertEqual(community?.isPublished, false)
        XCTAssertEqual(community?.name, "Next test community")
        XCTAssertEqual(community?.description, "Next test description on community 05NzHO7OY0e1UUiMM38eiQ")
        XCTAssertEqual(community?.missionStatement, "Next test community on 05NzHO7OY0e1UUiMM38eiQ")
        XCTAssertEqual(community?.locale, "en-US")
        XCTAssertEqual(community?.isPublic, false)
        XCTAssertNil(community?.logoURL)
        XCTAssertNil(community?.headerImageURL)
    }
    
    /**
     Test dictionary initializer to verify that a partial dictionary WITHOUT required keys fails to initialize a valid object.
     */
    func testPartialInvalidDictionaryInit() {
        let dictionary = JSONFileReader.JSON("community-partial-invalid") as! NSDictionary
        let community = Community(dictionary: dictionary)
        XCTAssertNil(community)
    }
    
    /**
     Test dictionary initializer to verify that empty dictionary fails to initialize a object.
     */
    func testEmptyDictionaryInit() {
        let dictionary = NSDictionary()
        let community = Community(dictionary: dictionary)
        XCTAssertNil(community)
    }
}
