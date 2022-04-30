//
//  DaoShareView+ViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/02/22.
//

import SwiftUI
import StreamChat
import StreamChatUI

extension DaoShareView {
    class ViewModel: ObservableObject {
        // MARK: - Variables
        var hashTagSpacing = 5.0
        var chatData: [String: RawJSON]

        // MARK: - Init
        init(_ data: [String: RawJSON]) {
            self.chatData = data
        }
    }
}

// MARK: - Computed
extension DaoShareView.ViewModel {
    var containerHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height - UIView.safeAreaTop - UIView.safeAreaBottom
        return (screenHeight * 646) / 734
    }
    var daoTrimmedAddress: String {
        return (chatData.safeAddress ?? "")
            .convertToWalletAddress()
            .trimStringByFirstLastCount(firstCount: 6, lastCount: 5)
    }

    func getCharityThumb() -> String {
        if let thumb = chatData["charityThumb"] {
            return fetchRawData(raw: thumb) as? String ?? ""
        } else {
            return ""
        }
    }
}
