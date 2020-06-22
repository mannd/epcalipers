//
//  CalibrationProcessor.swift
//  EP Calipers
//
//  Created by David Mann on 6/18/20.
//  Copyright © 2020 EP Studios. All rights reserved.
//

import UIKit
import os.log

// Ideally this should be a struct, but can't use structs with Objective C. :(
@objc
class Validation: NSObject {
    @objc var noInput = false
    @objc var noNumber = false
    @objc var noUnits = false
    @objc var invalidNumber = false
    @objc var invalidUnits = false
    // might as well return these too
    @objc var number: Float = 0
    @objc var units: String = ""
    @objc var calibrationString: String = ""

    @objc func isValid() -> Bool {
        return !(noInput || noNumber || noUnits || invalidNumber || invalidUnits)
    }

    @objc func evilInput() -> Bool {
        return noInput || noNumber || invalidNumber
    }
}

@objc
class CalibrationProcessor: NSObject {
    @objc static let msRegex = "(?:^msec|^millis|^мсек|^миллис|^ms$|^мс$)";
    @objc static let secondRegex = "(?:^sec|^сек|^s$|^с$)";
    @objc static let mmRegex = "(?:^millim|^миллим|^mm$|^мм$)";
    @objc static let mvRegex = "(?:^milliv|^mv$|^миллив|^мв$)";

    @objc class func matchesMsec(_ s: String) -> Bool {
        return isMatch(pattern: msRegex, s: s)
    }

    @objc class func matchesSec(_ s: String) -> Bool {
        return isMatch(pattern: secondRegex, s: s)
    }

    @objc class func matchesMM(_ s: String) -> Bool {
        return isMatch(pattern: mmRegex, s: s)
    }
    
    @objc class func matchesMV(_ s: String) -> Bool {
        return isMatch(pattern: mvRegex, s: s)
    }

    private class func isMatch(pattern: String, s: String) -> Bool {
        return s.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private class func validateUnits(_ units: String, direction: CaliperDirection) -> Bool {
        if direction == .Horizontal {
            return matchesMsec(units) || matchesSec(units)
        }
        else {
            return matchesMM(units) || matchesMV(units)
        }
    }

    @objc
    class func validate(_ s: String, direction: CaliperDirection) -> Validation {
        let validation = Validation()
        if s.count < 1 {
            validation.noInput = true
            return validation
        }
        let scanner = Scanner(string: s)
        // Use below to test localization
        //let locale = Locale(identifier: "FR")
        //scanner.locale = locale
        var value: Float = 0
        if scanner.scanFloat(&value) {
            if value <= 0 {
                validation.invalidNumber = true
            }
        }
        else {
            validation.noNumber = true
        }
        let index = scanner.string.index(scanner.string.startIndex, offsetBy: scanner.scanLocation)
        var units = String(scanner.string[index...])
        units = units.trimmingCharacters(in: .whitespacesAndNewlines)
        let unitsArray = units.components(separatedBy: .whitespacesAndNewlines)
        units = unitsArray[0]
        if units.count < 1 {
            validation.noUnits = true
        }
        else {
            validation.invalidUnits = !validateUnits(units, direction: direction)
        }
        validation.number = value
        validation.units = units
        validation.calibrationString = s;
        os_log("number = %f", value)
        os_log("units = %s", units)
        os_log("calibrationString = %s", validation.calibrationString)
        return validation
    }

    static var showWarningDialogs: Bool = true

    @objc
    class func showValidationDialog(validation: Validation, direction: CaliperDirection) {
        if validation.isValid() {
            // processCalibration
            os_log("valid calibration")
            return
        }
        if validation.noInput || validation.noNumber || validation.invalidNumber {
            // showMessage(error message)
            os_log("invalid input")
            return
        }
        if showWarningDialogs && (validation.noUnits || (validation.invalidUnits && direction == .Horizontal)) {
            // show calibration warning
            os_log("invalid units")
        }
    }

}
