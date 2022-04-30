//
//  GotWalletByQRCodeView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/3/21.
//

import SwiftUI
import AVFoundation

struct GotWalletByQRCodeView {
    @State private var isFlash = false
    @State private var showQR = false
    @State private var hideCameraLoading = true
    @State private var disableFlash = true
    var sizeQRCode: CGFloat = 226
    var rect: CGRect {
        CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 10, height: sizeQRCode)
    }
    var onScanSuccess: ((String) -> Void)?
}

extension GotWalletByQRCodeView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: isFlash ? "bolt.fill" : "bolt.slash.fill")
                    .frame(width: 25, height: 25)
                    .background(Color.xmarkBackground.cornerRadius(.infinity))
                    .foregroundColor(Color.white)
                    .padding(7)
                    .background(Color.almostClear)
                    .opacity(disableFlash ? 0.5 : 1)
                    .onTapGesture {
                        if !disableFlash {
                            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                                self.isFlash.toggle()
                                toggleTorch(onTorch: self.isFlash)
                            }
                        }
                    }
                    .disabled(disableFlash)
                Spacer()
            }
            .padding(.leading, 22)
            .padding(.bottom, 24)
            Text("Scan QR Code")
                .tracking(0.9)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.bottom, 48)
            ZStack {
                Circle()
                    .fill(Color.black)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: sizeQRCode)
                if showQR {
                    ScanQRCodeView(onScanSuccess: { strScanned in onScanSuccess?(strScanned) })
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: sizeQRCode)
                }
                Circle()
                    .fill(Color.black)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: sizeQRCode)
                    .opacity(hideCameraLoading ? 1 : 0)
                Rectangle()
                    .fill(Color.confirmationBG)
                    .frame(width: rect.width, height: rect.height)
                    .mask(holeShapeMask(in: rect).fill(style: FillStyle(eoFill: true)))
            }
            .overlay(
                Circle()
                    .stroke(Color.chevronAccountName, lineWidth: 4)
            )
            .padding(.bottom, 60)
            Text("Send money, add as a contact, or connect to a Dapp")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white60)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 31)
            Spacer()
        }
        .padding(.top, 26)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showQR = true
                if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                    disableFlash = false
                    AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                        if granted == true {
                            hideCameraLoading = false
                            disableFlash = false
                        } else {
                            disableFlash = true
                        }
                    })
                } else {
                    hideCameraLoading = false
                    disableFlash = false
                }
            }
        }
        .height(534)
    }
}

extension GotWalletByQRCodeView {
    private func toggleTorch(onTorch: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if onTorch == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}
