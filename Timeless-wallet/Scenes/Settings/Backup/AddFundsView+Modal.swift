//
//  AddFundsView+Modal.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 18/11/2021.
//

import SwiftUI

enum ProviderType: CaseIterable {
    case simplex
    case transak
    case ramp
    case wyre

    var exchangeRate: CGFloat {
        switch self {
        case .simplex: return 150.0001 / 150
        case .transak: return 149.9990 / 150
        case .ramp: return 149.8701 / 150
        case .wyre: return 149.7701 / 150
        }
    }

    var logo: Image {
        switch self {
        case .simplex: return Image.simplexIcon
        case .transak: return Image.transakIcon
        case .ramp: return Image.rampIcon
        case .wyre: return Image.wyreIcon
        }
    }

    var logoSize: CGSize {
        switch self {
        case .simplex: return CGSize(width: 108, height: 34)
        case .transak: return CGSize(width: 118, height: 36)
        case .ramp: return CGSize(width: 113, height: 26)
        case .wyre: return CGSize(width: 92, height: 31)
        }
    }
}
