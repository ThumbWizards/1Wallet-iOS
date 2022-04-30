//
//  SendPaymentVC.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 02/12/21.
//

import UIKit
import SwiftUI
import StreamChatUI

class SendPaymentVC: UIViewController {

    // MARK: - Variables
    private var contentView: UIHostingController<SendPaymentView>?
    private var isRedPacket = false
    var walletData: SendOneWallet?
    var redPacket: RedPacket?

    // MARK: - Init
    init(oneWallet: SendOneWallet) {
        self.walletData = oneWallet
        self.isRedPacket = false
        super.init(nibName: nil, bundle: nil)
    }

    init(redPacket: RedPacket) {
        self.redPacket = redPacket
        isRedPacket = true
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        let sendPaymentView: SendPaymentView
        if isRedPacket {
            guard let redPacket = redPacket else { return }
            sendPaymentView = SendPaymentView(viewModel: .init(redPacket: redPacket),
                                              onDismiss: { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.dismiss(animated: true, completion: nil)
            })
        } else {
            guard let oneWallet = walletData else { return }
            sendPaymentView = SendPaymentView(viewModel: .init(walletData: oneWallet),
                                              onDismiss: { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.dismiss(animated: true, completion: nil)
            })
        }
        contentView = UIHostingController(rootView: sendPaymentView)
        view.addSubview(contentView!.view)
        setupConstraints()
        /*navigationController?.navigationBar.isHidden = true
        guard let oneWallet = walletData else { return }
        let sendPaymentView = SendPaymentView(viewModel: .init(walletData: oneWallet,
                             isRedPacket: self.isRedPacket)) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.dismiss(animated: true, completion: nil)
        }
        contentView = UIHostingController(rootView: sendPaymentView)
        view.addSubview(contentView!.view)
        setupConstraints()*/
    }

    // MARK: - Functions
    private func setupConstraints() {
        contentView?.view.translatesAutoresizingMaskIntoConstraints = false
        contentView?.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView?.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView?.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView?.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
