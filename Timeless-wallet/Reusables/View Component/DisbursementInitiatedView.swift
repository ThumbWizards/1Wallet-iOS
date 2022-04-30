//
//  DisbursementInitiatedView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 02/02/22.
//

import SwiftUI

struct DisbursementInitiatedView {
    // MARK: - Properties
    var walletAddress: String
    var daoName: String
    var daoUrl: String
    var type: ViewType = .initiate

    var title: String {
        switch type {
        case .approve:
            return "Approved"
        case .reject:
            return "Rejected"
        case .execute:
            return "Executed"
        default:
            return "Disbursement Initiated"
        }
    }

    var details: String {
        switch type {
        case .approve:
            // swiftlint:disable line_length
            return "You have approved the transaction. The transaction will be executed after the required number of confirmations are received from the approved signatories. "
        case .reject:
            // swiftlint:disable line_length
            return "You have rejected the transaction. Note that the transaction may still execute if the required number of confirmations are received from the other signatories. "
        case .execute(let walletName):
            return "The transaction has been successfully executed by the signatory — \(walletName) "
        default :
            return "Disbursement will be executed after the required number of confirmations are received from the approved signatories."
        }
    }

    enum ViewType: Equatable {
        case initiate
        case approve
        case reject
        case execute(String)
    }
}

// MARK: - Body view
extension DisbursementInitiatedView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            detailsView
        }
        .padding(.top, 45)
        .height(470)
    }
}

extension DisbursementInitiatedView {
    private var detailsView: some View {
        VStack(spacing: 5) {
            Text(title)
                .foregroundColor(type == .reject ? Color.timelessRed : Color.white.opacity(0.8))
                .font(.system(size: 28, weight: .bold))
                .frame(width: 300, alignment: .center)
            Text(details)
                .foregroundColor(Color.white.opacity(0.8))
                .font(.system(size: 14, weight: .medium))
                .frame(width: 275, alignment: .center)
            VStack(alignment: .center, spacing: 0) {
                if let url = URL(string: daoUrl) {
                    RemoteImage(url: url)
                        .clipShape(Circle())
                        .frame(width: 74, height: 74)
                } else {
                    Image.charityWater
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 74, height: 74)
                }
                Text(daoName)
                    .foregroundColor(.white)
                    .font(.sfProTextSemibold(size: 18))
                    .padding(.top, 15)
                WalletAddressView(address: walletAddress)
                    .foregroundColor(.white)
                    .font(.sfProText(size: 12))
                    .padding(.top, 5)
                    .opacity(type == .initiate ? 0 : 1)
            }
            .padding(.top, 45)
            Spacer()
            Text("OK")
                .padding(10)
                .font(.sfProText(size: 17))
                .frame(maxWidth: .infinity)
                .background(Color.reviewButtonBackground)
                .clipShape(Capsule())
                .padding(.horizontal, 40)
                .padding(.bottom, 55)
                .onTapGesture {
                    onTapCancel()
                }
        }
    }
}

extension DisbursementInitiatedView {
    private func daoImage(_ size: CGSize, path: String) -> AnyView {
        let image = MediaResourceModel(path: path,
                                       altText: nil,
                                       pathPrefix: nil,
                                       mediaType: nil,
                                       thumbnail: nil)
        return MediaResourceView(for: MediaResource(for: image,
                                                       targetSize: TargetSize(width: Int(size.width),
                                                                              height: Int(size.height))),
                                    placeholder: ProgressView()
                                        .progressViewStyle(.circular)
                                        .eraseToAnyView(),
                                    isPlaying: .constant(true))
            .scaledToFill()
            .frame(size)
            .eraseToAnyView()
    }
}

extension DisbursementInitiatedView {
    private func onTapCancel() {
        hideConfirmationSheet()
    }
}
