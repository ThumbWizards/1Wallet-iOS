//
//  QRCodeReaderView.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 11/11/21.
//

import UIKit
import SwiftUI
import swiftScan
import AVFoundation

class QRCodeReaderView: LBXScanViewController {
    var onScanSuccess: ((String) -> Void)?
    private let generator = UINotificationFeedbackGenerator()
    var screenType: QRReaderType = .moneyORAddToContact

    struct OverlayView: View {
        @State var isFlash = false
        @State var disableFlash = true
        var onDismiss: (() -> Void)
        var openPhotoAlbum: (() -> Void)
        var onTapFlash: (() -> Void)
        var screenType: QRReaderType
        var desctiptionText: String {
            switch screenType {
            case .privateGroup:
                return "Join private group quickly"
            case .moneyORAddToContact:
                return "Send money or Add to contact"
            case .addSigners:
                return "Add signer by scanning QR Code"
            case .joinGroup:
                return "Join group quickly"
            }
        }

        var body: some View {
            VStack {
                HStack {
                    Button(action: { onDismiss() }) {
                        Image.closeBackup
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 30)
                    }
                    .offset(y: -1)
                    Spacer()
                    Button {
                        openPhotoAlbum()
                    } label: {
                        HStack {
                            Image.photo
                                .resizable()
                                .frame(width: 25, height: 19)
                                .foregroundColor(Color.white)
                            Text("Album")
                                .foregroundColor(Color.white)
                                .font(.system(size: 15, weight: .regular))
                        }
                        .frame(width: 100, height: 30)
                        .background(Color.qrItemBackground.opacity(0.24).cornerRadius(18.5))
                    }
                }
                .padding(.leading, 29)
                .padding(.trailing, 21)
                .padding(.top, UIView.safeAreaTop)
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if !disableFlash {
                            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                                isFlash.toggle()
                                onTapFlash()
                            }
                        }
                    }) {
                        ZStack {
                            Image.boltFill
                                .foregroundColor(Color.white)
                                .frame(width: 30, height: 30)
                                .background(Color.qrItemBackground.opacity(0.24).cornerRadius(.infinity))
                                .opacity(isFlash ? 1 : 0)
                            Image.boltSlashFill
                                .foregroundColor(Color.white)
                                .frame(width: 30, height: 30)
                                .background(Color.qrItemBackground.opacity(0.24).cornerRadius(.infinity))
                                .opacity(!isFlash ? 1 : 0)
                        }
                    }
                    .disabled(disableFlash)
                    .opacity(disableFlash ? 0.5 : 1)
                    .padding(.bottom, 10)
                    .padding(.trailing, 27)
                }
                VStack(spacing: 0) {
                    Text("Scan QR code")
                        .foregroundColor(Color.white)
                        .font(.system(size: 22, weight: .regular))
                        .padding(.top, 20)
                        .padding(.bottom, 9)
                    Text(desctiptionText)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.white)
                    Spacer()
                    Button {
                        Timeless_wallet.present(ProfileModal(wallet: WalletInfo.shared.currentWallet,
                                                             onDismiss: { dismiss in
                            if dismiss {
                                onDismiss()
                            }
                        }), presentationStyle: .fullScreen)
                    } label: {
                        HStack(spacing: 3) {
                            Image.qrcode
                            Text("SHOW MY QR")
                        }
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.showQRButtonBG.cornerRadius(21.5))
                    }
                    .padding(.bottom, UIView.safeAreaBottom + 27)
                }
                .frame(width: UIScreen.main.bounds.width, height: 227)
                .background(Color.primaryBackground)
            }
            .onAppear {
                DispatchQueue.main.async {
                    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                        disableFlash = false
                    } else {
                        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                            if granted == true {
                                disableFlash = false
                            } else {
                                disableFlash = true
                            }
                        })
                    }
                }
            }
            .onDisappear { isFlash = false }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedCodeImage(needCodeImg: true)
        setOpenInterestRect(isOpen: true)
        scanStyle?.colorRetangleLine = .clear
        scanStyle?.colorAngle = .white
        scanStyle?.centerUpOffset += 70
        scanStyle?.xScanRetangleOffset = 45
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        guard self.isBeingPresented || self.isMovingToParent else { return }
        self.view.fit(subview: OverlayView(
            onDismiss: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.dismiss()
            },
            openPhotoAlbum: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.openPhotoAlbum()
            },
            onTapFlash: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.scanObj?.changeTorch()
                strongSelf.generator.notificationOccurred(.success)
            }, screenType: screenType
        ))
    }

    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        Utils.playHapticEvent()
        guard let result: LBXScanResult = arrayResult.first else { return }
        if result.strScanned?.isBlank != false {
            // failed
        } else {
            if onScanSuccess != nil {
                onScanSuccess?(result.strScanned ?? "")
                dismiss()
            } else {
                if let url = URL(string: result.strScanned ?? ""),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    // failed
                }
            }
        }
        self.startScan()
    }
}

// MARK: - enums
extension QRCodeReaderView {
    enum QRReaderType {
        case privateGroup
        case moneyORAddToContact
        case addSigners
        case joinGroup
    }
}
