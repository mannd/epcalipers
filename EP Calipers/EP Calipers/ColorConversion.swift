//
//  File.swift
//  EP Calipers
//
//  Created by David Mann on 6/8/22.
//  Copyright © 2022 EP Studios. All rights reserved.
//

import Foundation

@objc
extension UIColor {
    @objc
    var toString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return ("\(red),\(green),\(blue),\(alpha)")
    }

    @objc
    static func convertColorName(_ colorName: String?) -> UIColor? {
        if let colorName = colorName, !colorName.isEmpty {
            let rgbArray = colorName.components(separatedBy: ",")
            guard rgbArray.count >= 4 else { return nil }
            if let red = Double(rgbArray[0]), let green = Double(rgbArray[1]), let blue = Double(rgbArray[2]), let alpha = Double(rgbArray[3]) {
                let uiColor: UIColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
                return uiColor
            }
        }
        return nil
    }
}
