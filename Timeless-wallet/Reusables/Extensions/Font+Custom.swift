//
//  Font+Custom.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 29/10/21.
//

import SwiftUI

extension Font {
    public enum Name {
        public static let sfProText = "SFProText-Regular"
        public static let sfCompactText = "SFCompactText-Regular"
        public static let sfProDisplayBold = "SFProDisplay-Bold"
        public static let sfProTextSemibold = "SFProText-Semibold"
        public static let sfProDisplayRegular = "SFProDisplay-Regular"
        public static let futuraStdExtraBold = "FuturaStd-ExtraBold"
        public static let freeNetOldOriginals = "FontsFree-Net-Old-Originals"
        public static let phosphate = "Phosphate"
        public static let futuraBook = "FuturaStd-Book"
        public static let futuraExtraBoldOblique = "FuturaStd-ExtraBoldOblique"
    }
}

public extension Font {
    static func sfProText(size: CGFloat) -> Font {
        Font.custom(Name.sfProText, size: size)
    }

    static func sfCompactText(size: CGFloat) -> Font {
        Font.custom(Name.sfCompactText, size: size)
    }

    static func sfProDisplayBold(size: CGFloat) -> Font {
        Font.custom(Name.sfProDisplayBold, size: size)
    }

    static func sfProTextSemibold(size: CGFloat) -> Font {
        Font.custom(Name.sfProTextSemibold, size: size)
    }

    static func sfProDisplayRegular(size: CGFloat) -> Font {
        Font.custom(Name.sfProDisplayRegular, size: size)
    }

    static func futuraStdExtraBold(size: CGFloat) -> Font {
        Font.custom(Name.futuraStdExtraBold, size: size)
    }

    static func freeNetOldOriginals(size: CGFloat) -> Font {
        Font.custom(Name.freeNetOldOriginals, size: size)
    }

    static func phosphate(size: CGFloat) -> Font {
        Font.custom(Name.phosphate, size: size)
    }

    static func futuraBook(size: CGFloat) -> Font {
        Font.custom(Name.futuraBook, size: size)
    }

    static func futuraExtraBoldOblique(size: CGFloat) -> Font {
        Font.custom(Name.futuraExtraBoldOblique, size: size)
    }
}
