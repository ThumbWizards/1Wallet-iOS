//
//  QRCodeHelper.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 09/11/2021.
//
import EFQRCode
import SwiftUI

struct QRCodeHelper {
    static func generateQRCode(from string: String) -> Image? {
        let generator = EFQRCodeGenerator(content: string,
                                          size: EFIntSize(width: 512,
                                                          height: 512))
        // Lastly, get the final two-dimensional code image
        generator.foregroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        generator.pointShape = .circle

        if let outputImage = generator.generate() {
            return Image(cgImage: outputImage)
        }

        return nil
    }

    static func generateQRCodeCFImage(from string: String) -> CGImage? {
        let generator = EFQRCodeGenerator(content: string,
                                          size: EFIntSize(width: 512,
                                                          height: 512))
        // Lastly, get the final two-dimensional code image
        generator.foregroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        generator.pointShape = .circle

        if let outputImage = generator.generate() {
            return outputImage
        }

        return nil
    }
}
