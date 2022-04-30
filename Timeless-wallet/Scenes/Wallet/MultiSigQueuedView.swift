//
//  MultiSigQueuedView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 28/01/2022.
//

import SwiftUI

struct MultiSigQueuedView {
    // MARK: - Input Parameters
    let data: [MultiSigQueue]
    var viewModel: WalletMultiSigView.ViewModel
    @State private var isRefreshUI = false
}

// MARK: - Bodyview
extension MultiSigQueuedView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 37.5) {
                ForEach(data.indices, id: \.self) { index in
                    let item = data[index]
                    ExpandCollapseView(
                        title: item.startDateString,
                        subTitle: Formatters.Date.MMMd.string(from: item.createDate)) {
                            queueItem(item)
                        }
                }
            }
            .padding(.top, 17)
            .padding(.bottom, UIView.hasNotch ? UIView.safeAreaBottom : 35)
        }
    }
}

// MARK: - Methods
extension MultiSigQueuedView {
    private func queueItem(_ item: MultiSigQueue) -> some View {
        return VStack(spacing: 0) {
            daoName(item)
            transactionView(item)
            awaitingView(item)
            inititationView(item)
            confirmationView(item)
            executionView(item)
            advancedView()
            if !(isOptionSelected(item)) &&
                (item.pendingCount != 0) {
                checkmarkQueuedView(item)
            }
            if item.canExecute {
                executeTransferView(item)
            }
        }
        .overlay(isRefreshUI ? EmptyView() : EmptyView())
        .background(Color.sendTextFieldBG)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.sendTextFieldBG)
                .padding(.horizontal, 10), alignment: .bottom
        )
        .cornerRadius(9)
        .padding(.horizontal, 13)
    }

    private func daoName(_ item: MultiSigQueue) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 11) {
                if item.daoImage != nil {
                    mediaView(item)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.daoText)
                        .lineLimit(1)
                        .font(.system(size: 20))
                        .foregroundColor(Color.white.opacity(0.87))
                    Text(item.daoURLStr ?? "")
                        .tracking(0.2)
                        .lineLimit(1)
                        .font(.system(size: 15))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                .offset(y: -1)
                Spacer(minLength: 0)
            }
            .padding(.top, 23)
            .padding(.horizontal, 10)
            .padding(.bottom, 22)
            divider
        }
    }

    private func mediaView(_ item: MultiSigQueue) -> some View {
        let image = MediaResourceModel(path: item.daoImage ?? "",
                                       altText: nil,
                                       pathPrefix: nil,
                                       mediaType: nil,
                                       thumbnail: nil)
        return MediaResourceView(for: MediaResource(for: image,
                                                       targetSize: TargetSize(width: 73,
                                                                              height: 73)),
                                    placeholder: ProgressView()
                                        .progressViewStyle(.circular)
                                        .eraseToAnyView(),
                                    isPlaying: .constant(true))
            .scaledToFill()
            .frame(width: 73, height: 73)
            .cornerRadius(.infinity)
            .eraseToAnyView()
    }

    private func transactionView(_ item: MultiSigQueue) -> some View {
        VStack(spacing: 0) {
            Button(action: { onTapBlockExplorer() }) {
                HStack(alignment: .top ) {
                    Image.transactionPig
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .cornerRadius(.infinity)
                    VStack(alignment: .leading, spacing: 0) {
                        firstLineView(item)
                        secondLineView(item)
                    }
                }
                .padding(.top, 29.5)
                .padding(.bottom, 18.5)
                .padding(.leading, 10)
                .padding(.trailing, 18)
            }
            divider
        }
    }

    private var titleView: some View {
        return Text("\(Image.paperPlane) Send")
            .tracking(0.2)
            .font(.system(size: 15))
            .foregroundColor(Color.white.opacity(0.87))
    }

    private func firstLineView(_ item: MultiSigQueue) -> some View {
        HStack(spacing: 0) {
            titleView
            Spacer(minLength: 5)
            if let amountString = item.oneAmountStr {
                DisplayCurrencyView(
                    value: "-\(amountString)",
                    type: "ONE",
                    isSpacing: true,
                    valueAfterType: false,
                    font: .system(size: 15),
                    color: Color.white.opacity(0.4),
                    tracking: 0.2
                )
            }
        }
        .padding(.bottom, 1)
    }

    private func secondLineView(_ item: MultiSigQueue) -> some View {
        HStack(spacing: 0) {
            Text(item.recipient?.convertToWalletAddress().trimStringByCount(count: 10) ?? "")
                .font(.system(size: 15))
                .foregroundColor(Color.white.opacity(0.4))
            Spacer(minLength: 5)
            DisplayCurrencyView(
                value: (Utils.formatCurrency((item.oneAmount * viewModel.oneToUSDValue))),
                type: "$",
                isSpacing: false,
                valueAfterType: true,
                font: .system(size: 15),
                color: Color.white.opacity(0.4),
                tracking: 0.2
            )
        }
        .padding(.bottom, 4)
    }

    private func awaitingText(_ text: String) -> some View {
        Text(text)
            .lineLimit(1)
            .font(.system(size: 13))
            .foregroundColor(Color.signWalletText)
    }

    private func awaitingView(_ item: MultiSigQueue) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image.signWallet
                    .resizable()
                    .frame(width: 22, height: 16)
                    .offset(y: 0.5)
                    .padding(.trailing, 13)
                if item.canExecute {
                    awaitingText("Awaiting execution")
                    Spacer()
                } else if !item.approvals.contains(viewModel.wallet.address) &&
                            !item.rejections.contains(viewModel.wallet.address) {
                    awaitingText("Awaiting your confirmation")
                    Spacer(minLength: 5)
                    Text("\(Image.person3) \(item.approvals.count) of \(item.safe.threshold)")
                        .lineLimit(1)
                        .font(.system(size: 13))
                        .foregroundColor(Color.person3Text)
                } else {
                    if (item.safe.threshold - item.approvals.count) <= 1 {
                        awaitingText("Awaiting confirmation")
                    } else {
                        awaitingText("Awaiting confirmations")
                    }
                    Spacer(minLength: 5)
                    Text("\(Image.person3) \(item.approvals.count) of \(item.safe.threshold)")
                        .lineLimit(1)
                        .font(.system(size: 13))
                        .foregroundColor(Color.person3Text)
                }
            }
            .padding(.top, 21.5)
            .padding(.leading, 17)
            .padding(.trailing, 15)
            .padding(.bottom, 21)
            divider
        }
    }

    private func inititationView(_ item: MultiSigQueue) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("\(Image.plusCircle) initiation")
                    .lineLimit(1)
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.87))
                    .padding(.trailing, 8)
                Text(Formatters.Date.MMMdyyyyhhmmssaz.string(from: item.createDate))
                    .lineLimit(1)
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
                Spacer(minLength: 0)
            }
            .padding(.leading, 18)
            .padding(.trailing, 11)
            .padding(.top, 23)
             initiationItem(item.creator)
            .padding(.top, 9)
            .padding(.leading, 40)
            .padding(.trailing, 11)

        }
        .padding(.bottom, 19)
    }

    // swiftlint:disable line_length
    private func initiationItem(_ item: String) -> some View {
        HStack(spacing: 0) {
            Image.transactionPig
                .resizable()
                .frame(width: 26, height: 26)
                .padding(.trailing, 7)
            Text("\(item.convertToWalletAddress().trimStringByFirstLastCount(firstCount: 6, lastCount: 5))\(item == viewModel.wallet.address ? " (You)" : "")")
                .tracking(0.2)
                .font(.system(size: 15))
                .foregroundColor(Color.white.opacity(0.4))
            Spacer(minLength: 0)
        }
    }

    private func confirmationView(_ item: MultiSigQueue) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("\(Image.checkmarkCircle) Confirmation")
                    .lineLimit(1)
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.87))
                Spacer(minLength: 0)
            }
            .padding(.leading, 18)
            .padding(.trailing, 11)
            if !item.transaction.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(0 ..< item.transaction.count) { idx in
                        confirmationItem(item.transaction[idx])
                    }
                }
                .padding(.top, 9)
                .padding(.leading, 40)
                .padding(.trailing, 41)
            }
        }
        .padding(.bottom, 19)
    }

    private func confirmationItem(_ item: QueuedConfirmationType) -> some View {
        HStack(spacing: 0) {
            Image.transactionPig
                .resizable()
                .frame(width: 26, height: 26)
                .padding(.trailing, 7)
            Text("\(item.walletAddress.convertToWalletAddress().trimStringByFirstLastCount(firstCount: 6, lastCount: 5))\(item.walletAddress == viewModel.wallet.address ? " (You)" : "")")
                .tracking(0.2)
                .font(.system(size: 15))
                .foregroundColor(Color.white.opacity(0.4))
            Spacer(minLength: 0)
            switch item.status {
            case .accept:
                Image.personFillCheckmark
                    .resizable()
                    .frame(width: 15.5, height: 11)
                    .foregroundColor(Color.positiveColor)
            case .decline:
                Image.personFillXmark
                    .resizable()
                    .frame(width: 15.5, height: 11)
                    .foregroundColor(Color.confirmationNo)
            case .maybe:
                Image.personFillQuestionmark
                    .resizable()
                    .frame(width: 14, height: 12.5)
                    .foregroundColor(Color.signWalletText)
                    .offset(x: -1.5)
            }
        }
    }

    private func executionView(_ item: MultiSigQueue) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if item.pendingCount == 0 {
                    Text("\(Image.checkmarkCircle) Execution")
                        .lineLimit(1)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.87))
                        .padding(.trailing, 9)
                } else {
                    Text("\(Image.circle) Execution")
                        .lineLimit(1)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.87))
                        .padding(.trailing, 9)
                    Text("(\(item.pendingCount) more confirmation needed)")
                        .tracking(0.1)
                        .lineLimit(1)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                Spacer(minLength: 0)
            }
            .padding(.leading, 18)
            .padding(.trailing, 11)
            divider
                .padding(.top, 24)
        }
    }

    private func advancedView() -> some View {
        VStack(spacing: 0) {
            Button(action: { onTapAdvanced() }) {
                Color.almostClear
                    .frame(height: 62)
                    .overlay(
                        HStack {
                            Text("Advanced")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.87))
                            Spacer()
                            Image.chevronRight
                                .resizable()
                                .frame(width: 7, height: 12)
                                .foregroundColor(Color.white.opacity(0.87))
                        }
                        .padding(.leading, 18)
                        .padding(.trailing, 28)
                    )
            }
            divider
        }
    }

    // swiftlint:disable function_body_length
    private func checkmarkQueuedView(_ item: MultiSigQueue) -> some View {
        return VStack(spacing: 0) {
            Button(action: { onTapCheckmark(item) }) {
                ZStack {
                    HStack(alignment: .top, spacing: 9) {
                        if item.isCheck {
                            Image.squareFill
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 11.5, height: 11.5)
                                .offset(y: 2)
                        } else {
                            Image.square
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 11.5, height: 11.5)
                                .offset(y: 2)
                        }
                        // swiftlint:disable line_length
                        Text("I have thoroughly reviewed the transaction and understand that my action to confirm or reject cannot be undone.")
                            .tracking(-0.7)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .offset(x: -4)
                }
                .padding(.top, 27)
                .padding(.leading, 38)
                .padding(.trailing, 26)
                .padding(.bottom, 7)
                .background(Color.almostClear)
            }
            HStack(spacing: 8) {
                Button(action: { onTapReject(item) }) {
                    Rectangle()
                        .frame(width: 89, height: 41)
                        .foregroundColor(item.isCheck ? Color.rejectBG : Color.queuedDisableBG)
                        .cornerRadius(.infinity)
                        .overlay(
                            Text("Reject")
                                .font(.system(size: 17))
                                .foregroundColor(item.isCheck ? Color.rejectText : Color.queuedDisableText)
                        )
                }
                Button(action: { onTapConfirm(item) }) {
                    Rectangle()
                        .frame(height: 41)
                        .foregroundColor(item.isCheck ? Color.timelessBlue : Color.queuedDisableBG)
                        .cornerRadius(.infinity)
                        .overlay(
                            Text("Confirm")
                                .font(.system(size: 17))
                                .foregroundColor(item.isCheck ? Color.white : Color.queuedDisableText)
                        )
                }
            }
            .disabled(!item.isCheck)
            .padding(.top, 10)
            .padding(.leading, 32)
            .padding(.trailing, 27)
            .padding(.bottom, 50)
        }
    }

    private func executeTransferView(_ item: MultiSigQueue) -> some View {
        return VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 8) {
                Button(action: { onTapExecution(item) }) {
                    Rectangle()
                        .frame(height: 41)
                        .cornerRadius(.infinity)
                        .overlay(
                            Text("Execute Transaction")
                                .font(.system(size: 17))
                                .foregroundColor(Color.white)
                                .foregroundColor(Color.queuedDisableBG)
                        )
                }
            }
            .padding(.top, 10)
            .padding(.leading, 32)
            .padding(.trailing, 27)
            .padding(.bottom, 10)
            Spacer()
        }
    }


    // MARK: - Methods
    private func onTapCheckmark(_ item: MultiSigQueue) {
        withAnimation(.easeInOut(duration: 0.2)) {
            Utils.playHapticEvent()
            isRefreshUI.toggle()
            item.isCheck.toggle()
        }
    }

    private func onTapReject(_ queue: MultiSigQueue) {
        Utils.playHapticEvent()
        viewModel.rejectTransaction(queue) { error in
            guard error == nil else {
                return
            }
            dismissAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfirmation(
                    .disbursementConfirm(wallet: queue.safe.address ?? "",
                                         type: .reject,
                                         daoName: queue.daoText,
                                         daoUrl: queue.daoImage ?? "")
                )
            }
        }
    }

    private func onTapConfirm(_ queue: MultiSigQueue) {
        Utils.playHapticEvent()
        if queue.pendingCount == 1 {
            viewModel.approvedTransaction(queue) { error in
                guard error == nil else {
                    return
                }
                queue.approvals.append(viewModel.wallet.address)
                isRefreshUI.toggle()
            }
        } else {
            viewModel.approvedTransaction(queue) { error in
                guard error == nil else {
                    return
                }
                dismissAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showConfirmation(
                        .disbursementConfirm(wallet: queue.safe.address ?? "",
                                             type: .approve,
                                             daoName: queue.daoText,
                                             daoUrl: queue.daoImage ?? "")
                    )
                }
            }
        }
    }

    private func onTapExecution(_ queue: MultiSigQueue) {
        viewModel.executeTransfer(queue) { error in
            guard error == nil else {
                return
            }
            dismissAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfirmation(
                    .disbursementConfirm(wallet: queue.safe.address ?? "",
                                         type: .execute(viewModel.wallet.nameFullAlias),
                                         daoName: queue.daoText,
                                         daoUrl: queue.daoImage ?? "")
                )
            }
        }
    }

    private func isOptionSelected(_ queue: MultiSigQueue) -> Bool {
       return (queue.approvals.contains(viewModel.wallet.address) || queue.rejections.contains(viewModel.wallet.address))
    }

    private var divider: some View {
        Rectangle()
            .frame(height: 1)
            .padding(.horizontal, 10)
            .foregroundColor(Color.dividerQueue)
    }
}

// MARK: - Methods
extension MultiSigQueuedView {
    private func onTapAdvanced() {
    }

    private func onTapBlockExplorer() {
    }
}
