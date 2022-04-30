//
//  RedPacketConfirmationView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 03/12/21.
//

import SwiftUI
import StreamChatUI

struct RedPacketConfirmationView {
    @AppStorage(ASSettings.Setting.requireForTransaction.key)
    private var requireForTransaction = ASSettings.Setting.requireForTransaction.defaultValue
    @AppStorage(ASSettings.Settings.lockMethod.key)
    private var lockMethod = ASSettings.Settings.lockMethod.defaultValue
    @StateObject var viewModel: ViewModel
    private var appLockEnable: Bool {
        Lock.shared.passcode != nil && lockMethod != ASSettings.LockMethod.none.rawValue && requireForTransaction
    }
}

extension RedPacketConfirmationView: View {
    var body: some View {
        ZStack(alignment: .center) {
            ZStack(alignment: .top) {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 100)
                    detailsView
                    VStack(spacing: 10) {
                        makeButton(type: viewModel.btn1State)
                            .animation(.easeOut(duration: 0.25), value: true)
                        makeButton(type: viewModel.btn2State)
                            .animation(.easeOut(duration: 0.25), value: true)
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .height(430)
                Spacer(minLength: 20)
                VStack(spacing: 15) {
                    Text("Red Packet")
                        .font(.sfProDisplayBold(size: 28))
                        .foregroundColor(.white)
                    Text("\(StreamChatUI.Constants.redPacketExpireTime) minutes limit to pick up the packet.\n Any unclaimed packets will be returned.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white87)
                        .frame(width: 300)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30)

            }
            .padding(.bottom, UIView.safeAreaBottom + 18)
            if viewModel.isLoading {
                loadingOverlay
            }
        }
    }
}

extension RedPacketConfirmationView {
    func makeButton(type: ViewModel.ButtonState) -> some View {
        Button(action: {
            handleButtonActions(type: type)
        }) {
            switch type {
            case .confirmSend:
                Text("Confirm Send")
                    .padding(10)
                    .font(.sfProText(size: 17))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.timelessBlue)
                    .opacity(1.0)
                    .clipShape(Capsule())
            case .confirmSendDisable:
                Text("Confirm Send")
                    .padding(10)
                    .font(.sfProText(size: 17))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.timelessBlue)
                    .clipShape(Capsule())
                    .opacity(0.5)
            case .cancel:
                Text("Cancel")
                    .padding(10)
                    .font(.sfProText(size: 17))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.reviewButtonBackground)
                    .clipShape(Capsule())
                    .opacity(1.0)
            case .cancelDisable:
                Text("Cancel")
                    .padding(10)
                    .font(.sfProText(size: 17))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.reviewButtonBackground)
                    .clipShape(Capsule())
                    .opacity(0.1)
            case .retry:
                Text("Retry")
                    .padding(10)
                    .font(.sfProText(size: 17))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.timelessBlue)
                    .opacity(1.0)
                    .clipShape(Capsule())
            case .retryCancel:
                Text("Cancel")
                    .padding(10)
                    .font(.sfProText(size: 17))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.reviewButtonBackground)
                    .clipShape(Capsule())
                    .opacity(1.0)
            }
        }
    }

    private var detailsView: some View {
        VStack(spacing: 15) {
            WalletAvatar(wallet: WalletInfo.shared.currentWallet, frame: CGSize(width: 74, height: 74))
            VStack(spacing: 5) {
                Text("\(viewModel.redPacket.myName?.toCrazyOne() ?? "-")")
                    .font(.sfProTextSemibold(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                WalletAddressView(address: viewModel.redPacket.myWalletAddress ?? "", trimCount: 10)
                    .font(.sfProText(size: 12))
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }.opacity(0.8)
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.2)
        }
            .frame(width: 70, height: 70)
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
    }
}

// MARK: - Methods
extension RedPacketConfirmationView {
    func requestAuthentication(for action: @escaping (Bool) -> Void) {
        present(BiometricView(
            callback: action).hideNavigationBar(),
                presentationStyle: .overFullScreen
        )
    }

    private func handleButtonActions(type: ViewModel.ButtonState) {
        switch type {
        case .confirmSend:
            sendRedPacket()
        case .cancel:
            viewModel.cancelTransaction()
        case .cancelDisable, .confirmSendDisable:
            break
        case .retry:
            sendRedPacket()
        case .retryCancel:
            hideConfirmationSheet()
        }
    }

    private func sendRedPacket() {
        guard !viewModel.isLoading else { return }
        if appLockEnable {
            requestAuthentication { _ in
                viewModel.sendGiftPacket()
            }
        } else {
            viewModel.sendGiftPacket()
        }
    }
}

struct RedPacketConfirmationView_Preview: PreviewProvider {
    static var previews: some View {
        RedPacketConfirmationView(viewModel: .init(redPacket: RedPacket()))
    }
}
