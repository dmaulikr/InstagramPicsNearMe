//
//  PicturesNearMeTests.swift
//  PicturesNearMeTests
//
//  Created by Georgios Taskos on 4/18/15.
//  Copyright (c) 2015 Xplat Solutions. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

import PicturesNearMe

class PicturesNearMeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInstagramApiRepository() {
        let expectation = expectationWithDescription("Test Instagram API return results")
        InstagramApiRepository.sharedInstance.getMedia(CLLocationCoordinate2DMake(40.7127, 74.0059), distance: 3000) { (instagramMedia) -> Void in
            XCTAssertNotNil(instagramMedia, "instagramMedia should not be nil")
            XCTAssertGreaterThan(instagramMedia.count, 0, "instagramMedia should return more than 1 record")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            println(error)
        }
    }

}
