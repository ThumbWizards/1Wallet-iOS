//
//  ScanQRCodeView.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 29/10/2021.
//

import UIKit
import SwiftUI
import swiftScan

struct ScanQRCodeView: UIViewControllerRepresentable {
    var onScanSuccess: ((String) -> Void)?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ScanQRCodeView>) -> QRCodeView {
        let viewController = QRCodeView(onScanSuccess: onScanSuccess)
        return viewController
    }

    func updateUIViewController(_ uiViewController: QRCodeView, context: UIViewControllerRepresentableContext<ScanQRCodeView>) {
    }
}

class QRCodeView: LBXScanViewController {
    var onScanSuccess: ((String) -> Void)?
    private let generator = UINotificationFeedbackGenerator()

    init(onScanSuccess: ((String) -> Void)?) {
        self.onScanSuccess = onScanSuccess
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setNeedCodeImage(needCodeImg: true)
        setOpenInterestRect(isOpen: true)

        scanStyle?.colorRetangleLine = .clear
        scanStyle?.colorAngle = .clear
        scanStyle?.centerUpOffset = 0
        scanStyle?.xScanRetangleOffset = 0
    }

    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        playHapticEvent()
        for result: LBXScanResult in arrayResult {
            if let str = result.strScanned {
                print(str)
            }
        }

        let result: LBXScanResult = arrayResult[0]

        if !(result.strScanned?.isBlank ?? false) {
            if onScanSuccess != nil {
                onScanSuccess?(result.strScanned ?? "")
                dismiss()
            } else {
                if let url = URL(string: result.strScanned ?? ""), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.startScan()
        }
    }

    private func playHapticEvent() {
        generator.notificationOccurred(.success)
    }
}
