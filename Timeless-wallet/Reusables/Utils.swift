//
//  Utils.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 28/12/21.
//

import Foundation
import web3swift
import BigInt
import SafariServices
import Combine
import StreamChat
import StreamChatUI

class Utils {
    class func formatCurrency(_ number: Double?) -> String {
        if let number = number {
            if let formattedBalance = Formatters.Currency.twoFractionDigitFormatter.string(from: number as NSNumber) {
                return formattedBalance
            }
        }
        return "0.00"
    }

    class func formatONE(_ number: Double?) -> String {
        if let number = number {
            if let formattedBalance = Formatters.Currency.oneFractionDigitFormatter.string(from: number as NSNumber) {
                return formattedBalance
            }
        }
        return "0.000"
    }

    class func formatBalance(_ number: Double?) -> String {
        if let number = number {
            if let formattedBalance = Formatters.Currency.currencyFractionDigitFormatter.string(from: number as NSNumber) {
                return formattedBalance
            }
        }
        return "0.0000"
    }

    class func formatStringToDouble(_ value: String) -> Double {
        var doubleValue = 0.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: value) {
            let amount = number.doubleValue
            doubleValue = amount
        }
        return doubleValue
    }

    class func isExiestCurrencyMaxDigit(_ value: String) -> Bool {
        guard let decimalSeparator = Locale.current.decimalSeparator else {
            return false
        }
        if !value.contains(decimalSeparator) {
            return false
        }
        let strings = value.components(separatedBy: decimalSeparator)
        if strings[1].count > 4 {
            return true
        }
        return false
    }

    class func getWalletBalance(token: Web3Service.Erc20Token?) -> AnyPublisher<Double, Never> {
        guard let wallet = Wallet.currentWallet,
              let walletAddress = EthereumAddress(wallet.address.convertBech32ToEthereum()) else {
                  return Just(0).eraseToAnyPublisher()
              }
        if let token = token {
            return Web3Service.shared.getErc20TokenBalance(for: token, at: walletAddress)
                .map { Web3Service.shared.amountFromWeiUnit(amount: $0, weiUnit: token.weiUnit) }
                .catch({ _ in
                    Just(0)
                })
                .eraseToAnyPublisher()
        }
        return Web3Service.shared.getBalance(at: walletAddress)
            .map { Web3Service.shared.amountFromWeiUnit(amount: $0, weiUnit: OneWalletService.weiUnit) }
            .catch({ _ in
                Just(0)
            })
            .eraseToAnyPublisher()
    }

    class func playHapticEvent() {
        try? HapticsGenerator.shared.playTransientEvent(
            withIntensity: 1.0,
            sharpness: 1.0
        )
    }

    class func setApplicationIconNameWihoutMessage(_ iconName: String?) {
        if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons))
            && UIApplication.shared.supportsAlternateIcons {

            typealias setAlternateIconName = @convention(c) (
                NSObject, Selector, NSString?, @escaping (NSError) -> Void
            ) -> Void

            let selectorString = "_setAlternateIconName:completionHandler:"

            let selector = NSSelectorFromString(selectorString)
            let imp = UIApplication.shared.method(for: selector)
            let method = unsafeBitCast(imp, to: setAlternateIconName.self)
            method(UIApplication.shared, selector, iconName as NSString?, { _ in })
        }
    }

    class func hideTabbar() {
        NotificationCenter.default.post(name: .hideTabbar, object: nil)
    }

    class func showTabbar() {
        NotificationCenter.default.post(name: .showTabbar, object: nil)
    }

    class func scanWallet(onScanWalletSuccess: @escaping ((String) -> Void)) {
        let view = QRCodeReaderView()
        view.onScanSuccess = { result in
            onQRCodeScanSuccess(strScanned: result, onScanWalletSuccess: { strScanned in
                onScanWalletSuccess(strScanned)
            })
        }
        view.screenType = .moneyORAddToContact
        if let topVc = UIApplication.shared.getTopViewController() {
            view.modalPresentationStyle = .fullScreen
            topVc.present(view, animated: true)
        }
    }

    class func onQRCodeScanSuccess(strScanned: String, onScanWalletSuccess: @escaping ((String) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let url = URL(string: strScanned), UIApplication.shared.canOpenURL(url) {
                if url.lastPathComponent.isOneWalletAddress {
                    onScanWalletSuccess(url.lastPathComponent)
                } else if isGroupInvitationLink(url) {
                    handleGroupInvitationLink(url: url)
                } else {
                    showSnackBar(.qrDetails(url: strScanned, didTap: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            openURLinApp(strScanned)
                        }
                    }))
                }
            } else if strScanned.isOneWalletAddress {
                onScanWalletSuccess(strScanned)
            } else {
                showSnackBar(.errorMsg(text: "Could not find wallet, Please try again"))
            }
        }
    }

    class func openURLinApp(_ urlStr: String) {
        guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
        let svc = SFSafariViewController(url: url)
        let nav = UINavigationController(rootViewController: svc)
        nav.isNavigationBarHidden = true
        present(nav)
    }
}

// MARK: - Deeplinks handler
extension Utils {
    private class func isGroupInvitationLink(_ url: URL) -> Bool {
        guard let urlString = url.absoluteString.removingPercentEncoding else {
            return false
        }
        return urlString.hasPrefix(AppConstant.firebaseDynamicLinkBaseURL) ? true : false
    }

    private class func handleGroupInvitationLink(url: URL) {
        guard let urlString = url.absoluteString.removingPercentEncoding,
              urlString.hasPrefix(AppConstant.firebaseDynamicLinkBaseURL) else {
            return
        }
        DeeplinkHelper.shared.extractActualLink(url) { linkUrl in
            guard let linkUrl = linkUrl else {
                return
            }
            if DeeplinkHelper.shared.isDaoGroupLink(linkUrl) {
                DeeplinkHelper.shared.handleDaoGroupLink(linkUrl)
            } else if DeeplinkHelper.shared.isGeneralGroupLink(linkUrl) {
                DeeplinkHelper.shared.handleGeneralGroupDeepLink(linkUrl)
            }
        }
    }
}
