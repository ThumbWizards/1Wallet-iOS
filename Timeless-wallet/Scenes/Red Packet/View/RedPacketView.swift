//
//  RedPacketView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 03/12/21.
//

import SwiftUI
import Combine
import StreamChatUI

struct RedPacketView {
    // MARK: - Variables
    @State private var numberUser = 1
    @State private var sliderValue = 1.0
    private var strUser: String {
        numberUser <= 1 ? "user" : "users"
    }
    private var footerText: String {
        numberUser <= 1
        ? "First user to pick up receives the full amount"
        : "First \(numberUser) users will split packet randomly"
    }
    @StateObject var viewModel: ViewModel
}

// MARK: - Body view
extension RedPacketView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color.sheetBG
            VStack(spacing: 0) {
                header
                currency
                selectedUser
                Spacer()
                footerView
            }
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: .dismissSendOneViews)) { _ in
            onTapClose()
        }
        .onAppear {
            viewModel.swapONEToUSD(value: Double(viewModel.redPacket.amount ?? 0.0))
        }
    }
}

// MARK: - Subview
extension RedPacketView {
    private var header: some View {
        ZStack {
            HStack {
                Button(action: { onTapClose() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                .padding(.leading, 18.5)
                .offset(y: -1)
                Spacer()
            }
            HStack(spacing: 4) {
                Text("Red Packet")
                    .tracking(0)
                    .foregroundColor(Color.white)
                    .font(.sfProDisplayBold(size: 18))
            }.opacity(0.8)
        }
        .padding(.top, 26.5)
        .padding(.bottom, UIView.hasNotch ? 30 : 20)
    }

    private var currency: some View {
        VStack(spacing: 0) {
            Text(viewModel.redPacket.strFormattedAmount ?? "0")
                .tracking(1.6)
                .lineLimit(1)
                .font(.system(size: 55, weight: .bold))
                .foregroundColor(Color.timelessBlue)
                .padding(.horizontal, 10)
            Text("~$\(Utils.formatCurrency(viewModel.rateUSDPay))")
                .tracking(0.7)
                .lineLimit(1)
                .font(.system(size: 18))
                .foregroundColor(Color.exchangeCurrency)
        }
        .padding(.bottom, UIView.hasNotch ? 51 : 20)
    }

    private var selectedUser: some View {
        VStack {
            Text("From your wallet")
                .font(.sfProDisplayRegular(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.paymentTitleFont.opacity(0.6))
            HStack {
                RemoteImage(
                    url: viewModel.redPacket.myImageUrl,
                    loading: .avatar,
                    failure: .avatar)
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .padding(.leading, 16)
                HStack(spacing: 0) {
                    VStack(spacing: 3) {
                        Text(viewModel.redPacket.myName?.toCrazyOne() ?? "-")
                            .font(.sfProText(size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        WalletAddressView(address: viewModel.redPacket.myWalletAddress ?? "", trimCount: 10)
                            .font(.sfProText(size: 12))
                            .foregroundColor(Color.paymentTitleFont.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.trailing, 8)
                }
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(Color.paymentCard)
            .cornerRadius(8)
            sliderView
        }
        .padding(.horizontal, 17)
        .padding(.bottom, 5)
    }

    private var sliderView: some View {
        VStack(spacing: nil) {
            HStack(spacing: nil) {
                Text("\(numberUser)")
                    .font(.sfProText(size: 28))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("\(strUser) can participate")
                    .font(.sfProDisplayRegular(size: 18))
                    .foregroundColor(.white60)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Stepper("", value: $numberUser, in: 1...viewModel.channelUsers)
                    .frame(width: 100)
            }
            Slider(value: $sliderValue, in: 1...Double(viewModel.channelUsers)) { isEditing in
                if !isEditing {
                    withAnimation(.spring()) {
                        sliderValue = round(sliderValue)
                        numberUser = Int(sliderValue)
                    }
                }
            }
            .offset(y: -10)
            .introspectSlider { slider in
                slider.tintColor = UIColor.timelessBlue
            }
        }
        .padding(.top, 15)
        .padding(5)
        .onChange(of: numberUser) { usersCount in
            viewModel.redPacket.participantsCount = usersCount
            withAnimation(.spring()) {
                sliderValue = Double(usersCount)
            }
        }
    }

    private var footerView: some View {
        VStack(spacing: 15) {
            Text(footerText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white60)
            Text("Next")
                .font(.sfProText(size: 17))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.timelessBlue)
                .clipShape(Capsule())
                .contentShape(Rectangle())
                .padding(.horizontal, 30)
                .onTapGesture {
                    viewModel.redPacket.participantsCount = numberUser
                    if viewModel.isValidAmount() {
                        showConfirmation(.redPacketConfirmation(redPacket: viewModel.redPacket), interactiveHide: false)
                    }
                }
        }
        .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom : 35)
    }
}

// MARK: - Methods
extension RedPacketView {
    private func onTapClose() {
        dismiss()
    }
}

struct RedPacketView_Previews: PreviewProvider {
    static var previews: some View {
        RedPacketView(viewModel: .init(redPacket: RedPacket()))
    }
}
