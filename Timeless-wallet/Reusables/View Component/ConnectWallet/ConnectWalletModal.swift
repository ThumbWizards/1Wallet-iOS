//
//  ConnectWalletModal.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 2/8/22.
//

import SwiftUI

struct ConnectWalletModal {

}

extension ConnectWalletModal: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: { hideConfirmationSheet() }) {
                            Image.closeBackup
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 30)
                                .padding(.leading, 24)
                        }
                        Spacer()
                    }
                    Text("Connect my wallet")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white87)
                }
                .padding(.top, 21)
                .padding(.bottom, 25)
                Text("""
                    No Ethereum wallet connected.
                    Connect your Ethereum wallet to connect to your NFT collection.

                    It creates a direct link between your NFT and ownership info.
                    """)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white60)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 41)
                    .padding(.leading, 57)
                    .padding(.trailing, 56)
                Image.metamaskFoxImage
                    .padding(.bottom, 34)
                    .onTapGesture {
                        hideConfirmationSheet()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showConfirmation(.connectSite)
                        }
                    }
                Image.trustwalletImage
                    .padding(.bottom, 41)
                Text("You’ll be requested to sign a message for 1wallet avatar")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white60)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 78)
                    .padding(.bottom, 50)
            }
        }
        .height(465)
    }
}
