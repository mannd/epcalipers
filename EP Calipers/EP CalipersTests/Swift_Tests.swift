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
        // test a real calculation using these formulas
        let qtcTable: [(formula: QTcFormulaPreference, value: Double, name: String)] = [(.Bazett, 0.3367, "Bazett"), (.Fridericia, 0.3159, "Fridericia"), (.Framingham, 0.327, "Framingham"), (.Hodges, 0.327, "Hodges")]
        for (formula, value, name) in qtcTable {
            result = qtcResult.calculateFromQt(inSec: 0.278, rrInSec: 0.6818, formula: formula, convertToMsec: false, units: "sec")
            XCTAssertEqual(result, "Mean RR = 0.6818 sec\nQT = 0.278 sec\nQTc = \(value) sec (\(name) formula)")
        }
        
        let qtcTable2: [(formula: QTcFormulaPreference, value: Double, name: String)] = [(.Bazett, 456.3, "Bazett"), (.Fridericia, 411.2, "Fridericia"), (.Framingham, 405.5, "Framingham"), (.Hodges, 425, "Hodges")]
        for (formula, value, name) in qtcTable2 {
            result = qtcResult.calculateFromQt(inSec: 0.334, rrInSec: 0.5357, formula: formula, convertToMsec: true, units: "msec")
            XCTAssertEqual(result, String.localizedStringWithFormat("Mean RR = 535.7 msec\nQT = 334 msec\nQTc = %.4g msec (%@ formula)", value, name))
        }
    }
    
    
}
