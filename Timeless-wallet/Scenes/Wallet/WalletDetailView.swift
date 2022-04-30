//
//  WalletDetailView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 25/11/2021.
//

import SwiftUI

struct WalletDetailView: View {
    // MARK: - Input parameters
    var navigationLink = false
    var wallet: Wallet

    // MARK: - Properties
    @AppStorage(ASSettings.Network.network.key)
    private var networkName = ASSettings.Network.network.defaultValue
    @ObservedObject var walletViewModel = WalletView.ViewModel.shared
    @State private var selectedSegment = SegmentType.overView
    @State private var selectedSegmentInt = 1
    @State private var firstTime = true

    enum SegmentType: Int {
        case nfts = 0
        case overView = 1
        case trxn = 2
        case multiSig = 3
    }
}

// MARK: - Body view
extension WalletDetailView {
    var body: some View {
        ZStack(alignment: .top) {
            Color.primaryBackground
            VStack(spacing: 0) {
                header
                segmentView.zIndex(1)
                contentView
            }
        }
        .hideNavigationBar()
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: selectedSegmentInt) { value in
            Utils.playHapticEvent()
            switch value {
            case 0: selectedSegment = .nfts
            case 1: selectedSegment = .overView
            case 2: selectedSegment = .trxn
            case 3: selectedSegment = .multiSig
            default: break
            }
        }
        .onChange(of: selectedSegment) { value in
            withAnimation(.easeInOut) {
                switch value {
                case .nfts: selectedSegmentInt = 0
                case .overView: selectedSegmentInt = 1
                case .trxn: selectedSegmentInt = 2
                case .multiSig: selectedSegmentInt = 3
                }
            }
        }
        .onAppear {
            // Todo: need to refactor
            if firstTime {
                wallet.detailViewModel.nftModel.getNFTsToken()
                DispatchQueue.global(qos: .userInitiated).async {
                    wallet.detailViewModel.trxnModel.getTransactionHistory(isFetchNextPage: false)
                }
                wallet.detailViewModel.overviewModel.getWalletAssetInfo(completion: nil)
                wallet.detailViewModel.overviewModel.getChartData()
                firstTime = false
            }
        }
    }
}

// MARK: - Subview
extension WalletDetailView {
    private var header: some View {
        ZStack {
            HStack(spacing: 7) {
                WalletAvatar(wallet: wallet, frame: CGSize(width: 22, height: 22))
                Text(wallet.name ?? "")
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(Color.walletDetailTitle)
            }
            .frame(width: 150)
            HStack(spacing: 5) {
                Spacer()
                Button {
                    // showConfirmation(.network(totalAmount: wallet.detailViewModel.overviewModel.totalUSDAmount))
                } label: {
                    Text(networkName.isEmpty ? "All Networks" : networkName)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white40)
                    Image.chevronRight
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white40)
                }
                .padding(.trailing, 13)
            }
            HStack {
                Button(action: { onTapClose() }) {
                    Image(navigationLink ? "backSheet" : "closeBackup")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .padding(.leading, 18.5)
                Spacer()
            }
        }
        .padding(.top, 31)
        .padding(.bottom, 33)
    }

    private var segmentView: some View {
        Picker(selection: $selectedSegment, label: EmptyView()) {
            Text("NFTs").tag(SegmentType.nfts)
            Text("Overview").tag(SegmentType.overView)
            Text("Trxn").tag(SegmentType.trxn)
//            Text("MultiSig").tag(SegmentType.multiSig)
        }
        .pickerStyle(SegmentedPickerStyle())
        .introspectSegmentedControl { segment in
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ]
            segment.setTitleTextAttributes(textAttributes, for: .normal)
            segment.setTitleTextAttributes(textAttributes, for: .selected)
            segment.selectedSegmentTintColor = UIColor(Color.segmentSelectedTint)
        }
        .frame(height: 23)
        .padding(.horizontal, 11)
        .padding(.top, 2)
    }

    private var contentView: some View {
        TabView(selection: $selectedSegmentInt) {
            WalletNFTsView(viewModel: wallet.detailViewModel.nftModel).tag(0)
            WalletOverviewView(viewModel: wallet.detailViewModel.overviewModel).tag(1)
            WalletTrxnView(viewModel: wallet.detailViewModel.trxnModel).tag(2)
//            WalletMultiSigView(viewModel: wallet.detailViewModel.multiSigModel).tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

// MARK: - Methods
extension WalletDetailView {
    private func onTapClose() {
        if navigationLink {
            pop()
        } else {
            dismiss()
        }
    }
}
