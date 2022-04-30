//
//  SendAmountToolbar.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/26/22.
//

import SwiftUI

struct SendAmountToolbar {
    var viewModel: SendView.ViewModel
    var onTapUseMax: () -> Void
    @Binding var tokenToggle: Bool
    @Binding var disableUseMax: Bool
    @State private var forceRefresh = false
}

extension SendAmountToolbar: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Button(action: { onTapUseMax() }) {
                ZStack {
                    Color.almostClear
                        .frame(height: 44)
                    HStack(spacing: 6) {
                        Image.hourglassBottomhalfFilled
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 10, height: 16)
                        Text("Use max")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                    }
                    .opacity(disableUseMax ? 0.3 : 1)
                    .offset(x: -1, y: 2)
                }
            }
            .disabled(disableUseMax)
            Rectangle()
                .frame(width: 1, height: 24)
                .foregroundColor(Color.keyboardVerticalDivider)
                .offset(y: -6)
            Button(action: {
                tokenToggle.toggle()
            }) {
                ZStack {
                    Color.almostClear
                        .frame(height: 44)
                    HStack(spacing: 6) {
                        Image.arrowTriangleSwap
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 16, height: 15)
                        Text(tokenToggle ? "USD" : viewModel.selectedToken?.symbol ?? "")
                            .font(.system(size: 17))
                            .foregroundColor(Color.white)
                    }
                    .offset(x: -1, y: 2)
                }
            }
        }
        .overlay(forceRefresh ? EmptyView() : EmptyView())
        .onReceive(viewModel.$selectedToken) { _ in
            forceRefresh.toggle()
        }
    }
}
