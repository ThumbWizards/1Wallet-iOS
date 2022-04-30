//
//  SendOneSuccessfulView.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 09/12/21.
//

import SwiftUI
import SafariServices

struct SendOneSuccessfulView {
    @StateObject var viewModel: ViewModel
    var symbol: String
}

extension SendOneSuccessfulView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer(minLength: 80)
                processView
                Spacer(minLength: 0)
                VStack {
                    Text("Check the transaction detail via block explorer")
                        .foregroundColor(Color.paymentTitleFont.opacity(0.6))
                        .font(.sfProText(size: 12))
                    HStack {
                        Text("Block Explorer")
                            .padding(10)
                            .font(.sfProText(size: 17))
                            .frame(maxWidth: .infinity)
                            .background(Color.timelessBlue)
                            .clipShape(Capsule())
                            .onTapGesture {
                                let strBlockExp = "\(Constants.blockExplore.url)\(viewModel.sendOneWalletData.txId ?? "")"
                                guard let url = URL(string: strBlockExp) else { return }
                                let svc = SFSafariViewController(url: url)
                                let nav = UINavigationController(rootViewController: svc)
                                nav.isNavigationBarHidden = true
                                UIApplication.shared.keyWindowInConnectedScenes?
                                    .rootViewController?.present(nav, animated: true, completion: nil)
                            }
                    }
                    .padding(.horizontal, 10)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .height(400)
            Spacer(minLength: 20)
            Text("Successfully Sent")
                .font(.sfProDisplayBold(size: 28))
                .foregroundColor(.white)
                .padding(.top, 30)
        }
        .padding(.bottom, UIView.safeAreaBottom + 18)
        .height(450)
    }
}

extension SendOneSuccessfulView {
    private var processView: some View {
        VStack(spacing: 15) {
            Spacer()
            Text("\((viewModel.sendOneWalletData.strFormattedAmount ?? "0")) \(symbol) Sent")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.paymentTitleFont.opacity(0.7))
            HStack {
                Spacer()
                WalletAvatar(wallet: WalletInfo.shared.currentWallet, frame: CGSize(width: 58, height: 58))
                Spacer()
                loadingView
                    .frame(width: 75, height: 75)
                Spacer()
                RemoteImage(
                    url: viewModel.sendOneWalletData.recipientImageUrl,
                    loading: .avatar,
                    failure: .avatar)
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
                Spacer()
            }
        }
        .frame(height: 150)
    }

    private var loadingView: some View {
        LottieView(name: "heart-burst", loopMode: .constant(.loop), isAnimating: .constant(true))
            .scaledToFill()
    }
}
