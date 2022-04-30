//
//  ConfirmationType.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 16/11/2021.
//

import Foundation
import SwiftUI
import StreamChatUI
import FilesProvider
import StreamChat

enum ConfirmationType {
    case none
    case createWallet
    case importWallet
    case verifyingEmail
    case manageBackups
    case walletPrivacyView
    case scanWalletAddress(callback: ((String) -> Void)?)
    case avatar(isHideMenu: Bool = false)
    case moreAction(wallet: Wallet)
    case transaction(swapViewModel: SwapView.ViewModel)
    case exchange
    case sendOneConfirmation(walletData: SendOneWallet? = nil,
                             transferOne: TransferOne? = nil,
                             screenType: SendOneConfirmationView.ViewModel.ScreenType,
                             channel: ChatChannelController?,
                             token: Web3Service.Erc20Token? = nil,
                             param: [AnyObject]? = nil)
    case qrOptions(result: String)
    case sendOneSuccessful(walletData: SendOneWallet, symbol: String = "ONE")
    case redPacketConfirmation(redPacket: RedPacket)
    case disconnectAndRemove(wallet: Wallet)
    case installGoogleAuthenticator
    case addNewWallet
    case floorPrice(avgColor: Color = Color.clear)
    case network(totalAmount: Double?)
    case assets
    case backupFileList(backupFiles: [FileObject])
    case restoringBackupView(appData: AppData, backupFile: FileObject, backupPassword: String)
    case deleteAllData
    case disbursementConfirm(
        wallet: String,
        type: DisbursementInitiatedView.ViewType,
        daoName: String,
        daoUrl: String
    )
    case daoTemplates
    case connectWallet
    case connectSite
    case exchangeWarning
}

extension ConfirmationType {
    @ViewBuilder
    var view: some View {
        ZStack(alignment: .top) {
            Color.confirmationBG
                .cornerRadius(radius: 34, corners: [.topLeft, .topRight])
                .padding(.horizontal, 5)
            switch self {
            case .createWallet:
                CreateWalletView()

            case .addNewWallet:
                AddWalletView()

            case .importWallet:
                ImportWalletView()

            case .walletPrivacyView:
                WalletPrivacyView()

            case .scanWalletAddress(let callback):
                GotWalletByQRCodeView { result in
                    callback?(result)
                }

            case .avatar(let bool):
                AccountViewModal(isHideMenu: bool)

            case .moreAction(let wallet):
                MoreActionModal(wallet: wallet)

            case .manageBackups:
                ManageICloudBackupView()

            case .transaction(let viewModel):
                TransactionConfirmModal(swapViewModel: viewModel)

            case .exchange:
                ExchangeModal()

            case let .sendOneConfirmation(walletData, transferOne, screenType, channel, token, param):
                if transferOne != nil {
                    SendOneConfirmationView(viewModel: .init(transferOne: transferOne))
                } else {
                    SendOneConfirmationView(viewModel: .init(walletData: walletData ?? .init(),
                                                             screenType: screenType,
                                                             channel: channel,
                                                             token: token,
                                                             parameters: param))
                }
            case let .sendOneSuccessful(walletData: walletData, symbol: symbol):
                ZStack(alignment: .top) {
                    SendOneSuccessfulView(viewModel: .init(walletData: walletData), symbol: symbol)
                }

            case .disconnectAndRemove(let wallet):
                ZStack(alignment: .top) {
                    DisconnectAndRemoveView(wallet: wallet)
                }

            case .redPacketConfirmation(let redPacket):
                RedPacketConfirmationView(viewModel: .init(redPacket: redPacket))

            case .installGoogleAuthenticator:
                InstallGoogleAuthenticatorView()

            case .backupFileList(let backupFiles):
                BackupFileListView(viewModel: .init(backupFiles: backupFiles))

            case .floorPrice(let avgColor):
                FloorPriceView(avgColor: avgColor)

            case .network(let totalAmount):
                NetworkViewModal(totalAmount: totalAmount)

            case .assets:
                AssetsViewModal()

            case let .restoringBackupView(appData, backupFile, backupPassword):
                RestoringBackupView(viewModel: .init(appData: appData,
                                                     backupFile: backupFile,
                                                     backupPassword: backupPassword))
            case .deleteAllData:
                DeleteAllDataView()
            case let .disbursementConfirm(walletAddress, type, daoName, daoUrl):
                DisbursementInitiatedView(walletAddress: walletAddress, daoName: daoName, daoUrl: daoUrl, type: type)

            case .daoTemplates:
                DAOTemplates()
            case .connectWallet:
                ConnectWalletModal()

            case .connectSite:
                ConnectSiteModal()

            case .qrOptions(let result):
                QROptionView(viewModel: .init(address: result))

            case .exchangeWarning:
                ExchangeWarningModal()

            default:
                EmptyView()
            }
        }
    }
}
