//
//  UIColor.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 18/11/21.
//

import UIKit

extension UIColor {
    static let tabBackgroundColor = UIColor(named: "tabBackgroundColor")
    static let timelessBlue = UIColor(named: "timelessBlue")
}

extension UIColor {
    var brightness: CGFloat {
        let rgba = self.rgba
        // http://www.w3.org/TR/AERT#color-contrast
        // Color brightness is determined by the following formula:
        // ((Red value X 299) + (Green value X 587) + (Blue value X 114)) / 1000
        // Note: This algorithm is taken from a formula for converting RGB values to YIQ values. This brightness value gives a perceived brightness for a color.
        return (rgba.red * 299 + rgba.green * 587 + rgba.blue * 114) / 1000
    }

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}
