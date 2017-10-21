//
//  QTcResult.swift
//  EP Calipers
//
//  Created by David Mann on 10/21/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

import Foundation

//import QTc
// TODO remove (is in QTc module)
enum QTcFormula {
    case qtcBzt
    case qtcFrd
    case qtcFrm
    case qtcHdg
}

class QTcResult: QTcResultProtocol {
    
    func calculateFromQt(inSec qtInSec: Double, rrInSec: Double, formula: QTcFormulaPreference, convertToMsec: Bool, units: String!) -> String! {
        let errorResult = NSLocalizedString("Invalid Result", comment:"")
        if rrInSec <= 0 {
            return errorResult
        }
        let qtcFormulas: [QTcFormula]
        switch formula {
        case QTcFormulaPreference.Bazett:
            qtcFormulas = [.qtcBzt]
        case QTcFormulaPreference.Fridericia:
            qtcFormulas = [.qtcFrd]
        case QTcFormulaPreference.Framingham:
            qtcFormulas = [.qtcFrm]
        case QTcFormulaPreference.Hodges:
            qtcFormulas = [.qtcHdg]
        case QTcFormulaPreference.all:
            qtcFormulas = [.qtcBzt, .qtcFrd, .qtcFrm, .qtcHdg]
        }
//        var meanRR = rrInSec
//        var qt = qtInSec
//        if convertToMsec {
//            meanRR *= 1000
//            qt *= 1000
//        }
//        var result = NSString.localizedStringWithFormat(NSLocalizedString("Mean RR = %.4g %@\nQT = %.4g %@", comment:"") as NSString, meanRR, units, qt, units) as String
//        for qtcFormula in qtcFormulas {
//            let qtcCalculator = QTc.qtcCalculator(formula: qtcFormula)
//            var qtc = qtcCalculator.calculate(qtInSec: qtInSec, rrInSec: rrInSec)
//            if qtc == Double.infinity || qtc.isNaN {
//                return errorResult
//            }
//            // switch to units that calibration uses
//            if convertToMsec {
//                qtc *= 1000
//            }
//            result += NSString.localizedStringWithFormat(NSLocalizedString("\nQTc = %.4g %@ (%@ formula)", comment:"") as NSString, qtc, units, qtcCalculator.longName) as String
//        }
        let result = "Test QTc Result"
        return result
    }
}
