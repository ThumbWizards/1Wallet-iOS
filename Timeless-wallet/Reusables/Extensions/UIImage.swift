//
//  Extension+UIImage.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 18/11/21.
//

import UIKit

extension UIImage {
    static let systemPerson = UIImage(systemName: "person")
    static let systemMagnifying = UIImage(systemName: "magnifyingglass")
    static let systemCheckMarkCircle = UIImage(systemName: "checkmark.circle.fill")
    static let systemPersonBadge = UIImage(systemName: "person.badge.plus")
    static let systemCheckmarkCircle = UIImage(systemName: "checkmark.circle.fill")
    static let iconArrowRight = UIImage(named: "Icon_arrow_right")
    static let xmas = UIImage(systemName: "xmark")
    static let checkMark = UIImage(systemName: "checkmark")
    static let backSheet = UIImage(named: "backSheet")
    static let releaseAppIcon = UIImage(named: "AppIcon.release")
    static let appIcon = UIImage(named: "AppIcon")
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
