//
//  WalletAddressView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 09/02/22.
//

import SwiftUI

struct WalletAddressView: View {
    @AppStorage(ASSettings.Settings.hexFormat.key)
    private var hexFormat = ASSettings.Settings.hexFormat.defaultValue
    var address: String
    var trimCount = 10
    var tracking: CGFloat = 0

    var body: some View {
        if hexFormat {
            Text(address.convertBech32ToEthereum().trimStringByCount(count: trimCount))
                .tracking(tracking)
        } else {
            Text(address.convertEthereumToBech32().trimStringByCount(count: trimCount))
                .tracking(tracking)
        }
    }
}
