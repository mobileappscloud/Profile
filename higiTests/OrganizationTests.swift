//
//  OrganizationTests.swift
//  higi
//
//  Created by Remy Panicker on 3/25/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import XCTest
@testable import higi

class OrganizationTests: XCTestCase {
    
    /**
     Test required initializaer to ensure object is initialized as expected.
     */
    func testInit() {
        let organization = Organization(identifier: "1", isActive: true, name: "test", description: "test desc", locale: "en-US")
        XCTAssertEqual(organization.identifier, "1")
        XCTAssertEqual(organization.isActive, true)
        XCTAssertEqual(organization.name, "test")
        XCTAssertEqual(organization.description, "test desc")
        XCTAssertEqual(organization.locale, "en-US")
    }
}

extension OrganizationTests {
    
    /**
     Test dictionary initializer to ensure a valid dictionary initialize a valid object.
     */
    func testDictionaryInit() {
        let dictionary = JSONFileReader.JSON("organization") as! NSDictionary
        let organization = Organization(dictionary: dictionary)
        XCTAssertNotNil(organization)
        
        XCTAssertEqual(organization?.identifier, "05NzHO7OY0e1UUiMM38eiQ")
        XCTAssertEqual(organization?.name, "Brooklyn S. Down Associates")
        XCTAssertEqual(organization?.description, "The higi organization")
        XCTAssertEqual(organization?.locale, "en-US")
        XCTAssertEqual(organization?.isActive, true)
        XCTAssertEqual(organization?.defaultCommunityIdentifier, "03298fwf3r89wef")
        XCTAssertEqual(organization?.logoURL?.absoluteString, "https://higi.com")
    }
    
    /**
     Test dictionary initializer to verify that a partial dictionary with required keys initializes a valid object.
     */
    func testPartialValidDictionaryInit() {
        let dictionary = JSONFileReader.JSON("organization-partial-valid") as! NSDictionary
        let organization = Organization(dictionary: dictionary)
        XCTAssertNotNil(organization)
    }
    
    /**
     Test dictionary initializer to verify that a partial dictionary WITHOUT required keys fails to initialize a valid object.
     */
    func testPartialInvalidDictionaryInit() {
        let dictionary = JSONFileReader.JSON("organization-partial-invalid") as! NSDictionary
        let organization = Organization(dictionary: dictionary)
        XCTAssertNil(organization)
    }
    
    /**
     Test dictionary initializer to verify that empty dictionary fails to initialize a object.
     */
    func testEmptyDictionaryInit() {
        let dictionary = NSDictionary()
        let organization = Organization(dictionary: dictionary)
        XCTAssertNil(organization)
    }
}
