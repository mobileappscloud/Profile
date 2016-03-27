//
//  HigiAuthorizationTests.swift
//  higi
//
//  Created by Remy Panicker on 3/24/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import XCTest
@testable import higi

class HigiAuthorizationTests: XCTestCase {
    
    let authorization = HigiAuthorization(accessToken: "token", type: .Bearer, expirationDate: NSDate(), refreshToken: "refresh")
}

extension HigiAuthorizationTests {
    
    private func encodedData() -> NSData? {
        return NSKeyedArchiver.archivedDataWithRootObject(authorization)
    }
    
    func testCoding() {
        let encodedData = self.encodedData()
        XCTAssertNotNil(encodedData, "Error encoding object to data.")
    }
    
    func testDecoding() {
        guard let decodedObject = NSKeyedUnarchiver.unarchiveObjectWithData(encodedData()!) as? HigiAuthorization else {
            XCTAssert(false, "Error decoding archived data to higi authorization object.")
            return
        }
        
        XCTAssertEqual(decodedObject.accessToken, authorization.accessToken, "Decoded parameter does not match encoded parameter.")
        XCTAssertEqual(decodedObject.type, authorization.type, "Decoded parameter does not match encoded parameter.")
        XCTAssertEqual(decodedObject.expirationDate, authorization.expirationDate, "Decoded parameter does not match encoded parameter.")
        XCTAssertEqual(decodedObject.refreshToken, authorization.refreshToken, "Decoded parameter does not match encoded parameter.")
    }
}

extension HigiAuthorizationTests {
    
    func testDictionaryInit() {
        let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1bmlxdWVfbmFtZSI6IkgyUERudnZYd2t5Y1dLVzFudUhlQVEiLCJzdWIiOiJIMlBEbnZ2WHdreWNXS1cxbnVIZUFRIiwiaXNzIjoiaHR0cHM6Ly9oaWdpLWRldi1jb3JlLWF1dGhlbnRpY2F0aW9uLmF6dXJld2Vic2l0ZXMubmV0IiwiYXVkIjoiZWVmNzhiZWE3Yzg5NDI4ZTk4ZGI2YWQyY2RjZmQ3NzUiLCJleHAiOjE0NTg3OTY0MjUsIm5iZiI6MTQ1ODc5MjgyNX0.wsf7IImCUqfUsrMwGNXsz6lWDm5OPQITgF3ky6KoXec"
        
        // Value extracted from access token payload
        let expirationTime: NSTimeInterval = 1458796425
        let expirationDate = NSDate(timeIntervalSince1970: expirationTime)
        let tokenType = "bearer"
        
        let refreshToken = "ezvNV6jRqI5O6kPFjCNeiFSJFgh5hXTK.H2PDnvvXwkycWKW1nuHeAQ"
        
        let dictionary = NSMutableDictionary()
        dictionary.setObject(accessToken, forKey: HigiAuthorization.DictionaryKeys.AccessToken)
        dictionary.setObject(tokenType, forKey: HigiAuthorization.DictionaryKeys.TokenType)
        dictionary.setObject(refreshToken, forKey: HigiAuthorization.DictionaryKeys.RefreshToken)
        
        guard let authorizationInfo = HigiAuthorization(dictionary: dictionary) else {
            XCTAssert(false, "Unable to initialize higi authorization object from dictionary.")
            return
        }
        
        XCTAssertEqual(authorizationInfo.accessToken, accessToken, "Authorization info initialization produced unexpected parameter.")
        XCTAssertEqual(authorizationInfo.type.rawValue, tokenType, "Authorization info initialization produced unexpected parameter.")
        XCTAssertEqual(authorizationInfo.expirationDate, expirationDate, "Authorization info initialization produced unexpected parameter.")
        XCTAssertEqual(authorizationInfo.refreshToken, refreshToken, "Authorization info initialization produced unexpected parameter.")
    }
    
    func testInvalidDictionaryInit() {
        let dictionary = NSDictionary()
        
        let authorization = HigiAuthorization(dictionary: dictionary)
        XCTAssertNil(authorization, "Expected nil from failable initializer.")
    }
}

extension HigiAuthorizationTests {

    func testBearerToken() {
        let authorizationHTTPHeaderValue = authorization.bearerToken()
        XCTAssertEqual(authorizationHTTPHeaderValue, "Bearer token", "Malformed HTTP Authorization header value.")
    }
}
