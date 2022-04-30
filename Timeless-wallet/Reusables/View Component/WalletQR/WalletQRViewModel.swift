//
//  WalletQRViewModel.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 31/03/22.
//

import UIKit

class WalletQRViewModel: ObservableObject {

    // MARK: - Variable
    @Published var qrCodeCGImage: CGImage?
    @Published var screenBrightness: CGFloat = 1
    var wallet: Wallet

    // MARK: - Init
    init(wallet: Wallet) {
        self.wallet = wallet
    }

    // MARK: - Functions
    func copyWalletAddress() {
        UIPasteboard.general.string = wallet.address.convertToWalletAddress()
        showSnackBar(.coppied)
    }

    func setDefaultBrightness() {
        UIScreen.main.brightness = screenBrightness
    }

    func generateWalletQRCode() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {
                return
            }
            let qrCode = QRCodeHelper
                .generateQRCodeCFImage(from: self.wallet.address.convertToWalletAddress())
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.qrCodeCGImage = qrCode
            }
        }
    }

    func onTapClose() {
        dismiss()
    }
}
