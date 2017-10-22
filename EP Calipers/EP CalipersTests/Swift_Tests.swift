//
//  Swift_Tests.swift
//  EP CalipersTests
//
//  Created by David Mann on 10/21/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import XCTest
@testable import EP_Calipers

class Swift_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        //self.measure {
        // Put the code you want to measure the time of here.
    }
    
    func testQTc() {
        let qtcResult = QTcResult()
        var result = qtcResult.calculateFromQt(inSec: 0.4, rrInSec: 1.0, formula: .Bazett, convertToMsec: false, units: "sec")
        XCTAssertEqual(result, "Mean RR = 1 sec\nQT = 0.4 sec\nQTc = 0.4 sec (Bazett formula)")
        result = qtcResult.calculateFromQt(inSec: 0.4, rrInSec: 1.0, formula: .Hodges, convertToMsec: false, units: "sec")
        XCTAssertEqual(result, "Mean RR = 1 sec\nQT = 0.4 sec\nQTc = 0.4 sec (Hodges formula)")
        
    }
    
    
}
