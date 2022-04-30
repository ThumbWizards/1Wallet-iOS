//
//  SwapView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/16/21.
//

import SwiftUI

var pendingSwapViewModel: [SwapView.ViewModel] = []

struct SwapView {
    @StateObject private var viewModel = SwapView.ViewModel()
    @StateObject private var walletInfo = WalletInfo.shared
}

extension SwapView {
    private var swapRate: String {
        viewModel.swapRate
    }

    private var rateUSDPay: String {
        "$\(Utils.formatCurrency(viewModel.rateUSDPay))"
    }

    private var reviewButtonEnable: Bool {
        return viewModel.payValue > 0 && viewModel.gotValue > 0
    }

    private var showClearPayButton: Bool {
        !viewModel.payText.isEmpty && viewModel.focusState == .pay
    }

    private var showClearGotButton: Bool {
        !viewModel.gotText.isEmpty && viewModel.focusState == .got
    }
}

extension SwapView: View {
    var body: some View {
        ZStack {
            Color.primaryBackground
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                headerView
                ScrollView {
                    contentView
                }
                .padding(.top, 18)
                Spacer()
            }
            .padding(.top, 13)
        }
        .loadingOverlay(isShowing: viewModel.selectedPay == nil)
        .onAppear {
            // Todo: cache pending transaction status
            pendingSwapViewModel.append(viewModel)
            if viewModel.model.isEmpty {
                viewModel.getWalletData()
            }
        }
        .onChange(of: walletInfo.currentWallet) { _ in
            // Refresh data
            viewModel.model = []
            viewModel.getWalletData()
        }
    }
}

extension SwapView {
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: { dismiss() }) {
                    ZStack {
                        Image.chevronLeft
                            .resizable()
                            .frame(width: 11, height: 20)
                            .foregroundColor(Color.timelessBlue)
                            .padding(.leading, 11)
                    }
                    .frame(width: 33, height: 20, alignment: .leading)
                }
                Spacer()
            }
            Text("Swap")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.white)
            HStack {
                Spacer()
                Button(action: {
                    showConfirmation(.avatar(isHideMenu: true))
                }) {
                    WalletAvatar(wallet: walletInfo.currentWallet, frame: CGSize(width: 30, height: 30))
                }
                .padding(.trailing, 24)
            }
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 23) {
                youPayView
                Divider()
                youGetView
            }
            .padding(.vertical, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .background(Color.autoLockBG.cornerRadius(10))
            .padding(.horizontal, 16)
            .overlay {
                Button {
                    let tempPay = viewModel.selectedPay
                    let tempGet = viewModel.selectedGot
                    viewModel.selectedPay = tempGet
                    viewModel.selectedGot = tempPay
                    viewModel.resetInitialData()
                } label: {
                    Image.arrowTriangleSwap
                        .foregroundColor(Color.timelessBlue)
                        .frame(width: 36, height: 36)
                        .background(Color.timelessBlue.opacity(0.3).cornerRadius(.infinity))
                }
                .disabled(viewModel.loadingState != .none)
            }
            .padding(.bottom, 16)
            ZStack {
                if viewModel.loadingState != .none {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                } else {
                    Text(swapRate)
                        .lineLimit(1)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.white60)
                        .padding(.horizontal, 25)
                }
            }
            .opacity(viewModel.selectedPay != nil && viewModel.selectedGot != nil ? 1 : 0)
            .height(24)
            .padding(.bottom, 12)
            Button {
                if verifyData() {
                    push(ReviewOrderView(swapViewModel: viewModel,
                                         rateUSD: rateUSDPay,
                                         rate: swapRate).hideNavigationBar())
                }
            } label: {
                Text("Review")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color.white)
                    .frame(width: UIScreen.main.bounds.width - 84, height: 41)
                    .background(!reviewButtonEnable ?
                                Color.reviewButtonBackground : Color.timelessBlue)
                    .cornerRadius(20.5)
                    .opacity(!reviewButtonEnable ? 0.3 : 1)
                    .padding(.bottom, 8)
            }
            .disabled(!reviewButtonEnable)
            Text("You’ll be able to review before confirming the transaction")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white40)
                .kerning(-0.5)
                .opacity(0.6)
                .padding(.horizontal, 34)
        }
    }

    private var youPayView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("You Pay")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white60)
                Spacer()
            }
            .padding(.bottom, 10)
            HStack {
                Button {
                    UIApplication.shared.endEditing()
                    present(PayModal(swapViewModel: viewModel))
                } label: {
                    HStack {
                        ZStack {
                            if let icon = viewModel.selectedPay?.icon,
                               let url = URL(string: icon) {
                                MediaResourceView(
                                    for: MediaResource(
                                        for: MediaResourceWebImage(
                                            url: url,
                                            isAnimated: true,
                                            targetSize: TargetSize(
                                                width: 36,
                                                height: 36))),
                                       placeholder: viewModel.loadingIconView,
                                       isPlaying: .constant(true))
                            }
                        }
                        .frame(width: 36, height: 36)
                        .cornerRadius(.infinity)
                        if let symbol = viewModel.selectedPay?.symbol {
                            Text(symbol)
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(Color.white60)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: 70, alignment: .leading)
                        }
                        Image.chevronDown
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color.white)
                    }
                    .frame(width: 140, alignment: .trailing)
                }
                HStack(spacing: 5) {
                    CurrencyTextField(focusState: $viewModel.focusState,
                                      text: $viewModel.payText,
                                      amountState: .constant(.none),
                                      textFieldType: .pay,
                                      placeholder: "0",
                                      formatedCurrency: { formattedCurrency in
                        viewModel.payValue = formattedCurrency
                    })
                        .background(
                            Color.almostClear
                                .padding(.vertical, -10)
                                .padding(.trailing, showClearPayButton ? 0 : -10)
                        )
                        .clipped()
                    if showClearPayButton {
                        Button(action: {
                            viewModel.payValue = 0
                            viewModel.payText = ""
                        }) {
                            Image.closeBackup
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color.white87)
                        }
                    }
                }
                .opacity(viewModel.focusState == .got && viewModel.loadingState == .gotChanged ? 0 : 1)
                .overlay(HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                        .opacity(viewModel.focusState == .got && viewModel.loadingState == .gotChanged ? 1 : 0)
                })
            }
            .padding(.bottom, 8)
            HStack {
                Spacer()
                Text(rateUSDPay)
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white60)
            }
            .opacity(viewModel.focusState == .got && viewModel.loadingState == .gotChanged ? 0 : 1)
        }
    }

    private var youGetView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("You Get (estimated)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white60)
                Spacer()
            }
            .padding(.bottom, 8)
            HStack {
                Button {
                    UIApplication.shared.endEditing()
                    present(ReceiveModal(swapViewModel: viewModel))
                } label: {
                    HStack {
                        ZStack {
                            if let icon = viewModel.selectedGot?.icon,
                               let url = URL(string: icon) {
                                MediaResourceView(
                                    for: MediaResource(
                                        for: MediaResourceWebImage(
                                            url: url,
                                            isAnimated: true,
                                            targetSize: TargetSize(
                                                width: 36,
                                                height: 36))),
                                       placeholder: viewModel.loadingIconView,
                                       isPlaying: .constant(true))

                            }
                        }
                        .frame(width: 36, height: 36)
                        .cornerRadius(.infinity)
                        if let symbol = viewModel.selectedGot?.symbol {
                            Text(symbol)
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(Color.white60)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: 70, alignment: .leading)
                        }
                        Image.chevronDown
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color.white)
                    }
                    .frame(width: 140, alignment: .trailing)
                }
                HStack(spacing: 5) {
                    CurrencyTextField(focusState: $viewModel.focusState,
                                      text: $viewModel.gotText,
                                      amountState: .constant(.none),
                                      textFieldType: .got,
                                      placeholder: "0",
                                      formatedCurrency: { formattedCurrency in
                        viewModel.gotValue = formattedCurrency
                    })
                    .background(
                        Color.almostClear
                            .padding(.vertical, -10)
                            .padding(.trailing, showClearGotButton ? 0 : -10)
                    )
                    .clipped()
                    if showClearGotButton {
                        Button(action: {
                            viewModel.gotValue = 0
                            viewModel.gotText = ""
                        }) {
                            Image.closeBackup
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color.white87)
                        }
                    }
                }
                .opacity(viewModel.focusState == .pay && viewModel.loadingState == .payChanged ? 0 : 1)
                .overlay(HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                        .opacity(viewModel.focusState == .pay && viewModel.loadingState == .payChanged ? 1 : 0)
                })

            }
            .padding(.bottom, 8)
            HStack {
                Spacer()
                Text(viewModel.rateUSDCompare)
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white60)
            }
            .opacity(viewModel.focusState == .pay && viewModel.loadingState == .payChanged ? 0 : 1)
        }
    }
}

extension SwapView {
    private func verifyData() -> Bool {
        if viewModel.selectedPay?.balance ?? 0 < viewModel.payValue {
            showSnackBar(.insufficientBalance(name: viewModel.selectedPay?.symbol ?? ""))
            return false
        }
        UIApplication.shared.endEditing()
        return true
    }
}
