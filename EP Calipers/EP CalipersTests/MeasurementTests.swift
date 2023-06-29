//
//  MeasurementTests.swift
//  EP CalipersTests
//
//  Created by David Mann on 6/27/23.
//  Copyright © 2023 EP Studios. All rights reserved.
//

import XCTest
@testable import EP_Calipers

final class MeasurementTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testNegativeMeasurements() {
        if let cal = Calibration() {
            cal.calibrated = true
            cal.direction = .Horizontal
            cal.offset = CGPoint(x: 100.0, y: 0.0)
            cal.originalZoom = 1.0
            cal.currentZoom = 1.0
            cal.originalCalFactor = 1.0
            cal.calibrationString = "1000 msec"
            cal.units = "msec"
            if let c = Caliper() {
                c.calibration = cal
                c.bar1Position = 1000
                c.bar2Position = 2000
                var m = c.measurement()
                XCTAssertEqual(m, "1,000 msec")
                cal.displayRate = true
                m = c.measurement()
                XCTAssertEqual(m, "60 bpm")
                cal.displayRate = false
                c.bar1Position = 2000
                c.bar2Position = 1000
                m = c.measurement()
                XCTAssertEqual(m, "-1,000 msec")
                cal.displayRate = true
                m = c.measurement()
                XCTAssertEqual(m, "60 bpm")
            }
        }
    }

}
