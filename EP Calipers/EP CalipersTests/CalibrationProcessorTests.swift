//
//  CalibrationProcessorTests.swift
//  EP CalipersTests
//
//  Created by David Mann on 6/18/20.
//  Copyright © 2020 EP Studios. All rights reserved.
//

import XCTest
@testable import EP_Calipers

class CalibrationProcessorTests: XCTestCase {

    func testCalibrationProcessor() {
        XCTAssertEqual(false, CalibrationProcessor.matchesMsec(""))
        XCTAssertEqual(false, CalibrationProcessor.matchesMsec("xxxx"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMsec("msec"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMsec("мсек"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMsec("мсекxx"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMsec("мс"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMsec("miLLiSec"))

        XCTAssertEqual(true, CalibrationProcessor.matchesSec("с"))
        XCTAssertEqual(true, CalibrationProcessor.matchesSec("сек"))
        XCTAssertEqual(false, CalibrationProcessor.matchesSec("мсек"))
        XCTAssertEqual(false, CalibrationProcessor.matchesSec("msec"))
        XCTAssertEqual(true, CalibrationProcessor.matchesSec("sec"))
        XCTAssertEqual(true, CalibrationProcessor.matchesSec("seconds"))
        XCTAssertEqual(true, CalibrationProcessor.matchesSec("SECONDS"))

        XCTAssertEqual(true, CalibrationProcessor.matchesMM("mm"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMM("миллим"))
        XCTAssertEqual(false, CalibrationProcessor.matchesMM("мсек"))
        XCTAssertEqual(false, CalibrationProcessor.matchesMM("msec"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMM("MM"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMM("millimeter"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMM("mm"))

        XCTAssertEqual(true, CalibrationProcessor.matchesMV("мв"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMV("милливXXX"))
        XCTAssertEqual(false, CalibrationProcessor.matchesMV("мсек"))
        XCTAssertEqual(false, CalibrationProcessor.matchesMV("msec"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMV("MV"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMV("milliVolts"))
        XCTAssertEqual(true, CalibrationProcessor.matchesMV("mv"))
    }

    func testValidation() {
        var validation = CalibrationProcessor.validate("", direction: .Horizontal)
        XCTAssertEqual(true, validation.noInput)

        validation = CalibrationProcessor.validate("test", direction: .Horizontal)
        XCTAssertEqual(true, validation.noNumber)

        validation = CalibrationProcessor.validate("1000 msec", direction: .Horizontal)
        XCTAssertEqual(1000, validation.number)
        XCTAssertEqual("msec", validation.units)
        XCTAssertEqual(true, validation.isValid())

        validation = CalibrationProcessor.validate("   1.00  ", direction: .Horizontal)
        XCTAssertEqual(1, validation.number)
        XCTAssertEqual(false, validation.isValid())

        validation = CalibrationProcessor.validate(".01", direction: .Horizontal)
        XCTAssertEqual(0.01, validation.number, accuracy: 0.0001)
        XCTAssertEqual("", validation.units)
        XCTAssertEqual(true, validation.noUnits)

        validation = CalibrationProcessor.validate("1,001", direction: .Horizontal)
        XCTAssertEqual(1, validation.number)

        validation = CalibrationProcessor.validate("1000 msec sec", direction: .Horizontal)
        XCTAssertEqual("msec", validation.units)

        validation = CalibrationProcessor.validate("1000", direction: .Horizontal)
        XCTAssertEqual("", validation.units)

        validation = CalibrationProcessor.validate("xxx 100", direction: .Horizontal)
        XCTAssertEqual(true, validation.noNumber)
        XCTAssertEqual(true, validation.invalidUnits)

        // validate units
        validation = CalibrationProcessor.validate("1.0.1.0", direction: .Horizontal)
        XCTAssertEqual(1, validation.number)
        XCTAssertEqual(true, validation.invalidUnits)
        XCTAssertEqual(false, validation.isValid())

        validation = CalibrationProcessor.validate("10.5 mV", direction: .Horizontal)
        XCTAssertEqual(10.5, validation.number, accuracy: 0.0001)
        XCTAssertEqual("mV", validation.units)
        XCTAssertEqual(true, validation.invalidUnits)

        validation = CalibrationProcessor.validate("10 mm", direction: .Vertical)
        XCTAssertEqual(10, validation.number, accuracy: 0.0001)
        XCTAssertEqual("mm", validation.units)
        XCTAssertEqual(false, validation.invalidUnits)

        validation = CalibrationProcessor.validate("10 миллим", direction: .Vertical)
        XCTAssertEqual(10, validation.number, accuracy: 0.0001)
        XCTAssertEqual("миллим", validation.units)
        XCTAssertEqual(false, validation.invalidUnits)
    }

    func testCalibrationString() {
        let validation = CalibrationProcessor.validate("   100.05   sec", direction: .Horizontal)
        XCTAssertEqual("   100.05   sec", validation.calibrationString)
    }

}
