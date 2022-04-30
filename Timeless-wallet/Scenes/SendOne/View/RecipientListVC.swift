//
//  RecipientListVC.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 29/11/21.
//

import UIKit
import StreamChat
import SwiftUI
import StreamChatUI

class RecipientListVC: UIViewController {
    
    // MARK: - Variables
    var memberList: ChatChannelMemberListController?
    private var contentView: UIHostingController<SelectRecipientView>?
    var didSelectMember: ((ChatChannelMember) -> Void)?
    
    init(memberList: ChatChannelMemberListController, didSelectMember: ((ChatChannelMember) -> Void)?) {
        self.memberList = memberList
        self.didSelectMember = didSelectMember
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        if let memberObject = memberList {
            let recipientView = SelectRecipientView(channelController: memberObject) { [weak self] member in
                guard let self = self else {
                    return
                }
                self.didSelectMember?(member)
                self.dismiss(animated: true, completion: nil)
            } onDismiss: { [weak self] in
                guard let self = self else {
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
            contentView = UIHostingController(rootView: recipientView)
            view.addSubview(contentView!.view)
            setupConstraints()
        }
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

extension RecipientListVC: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        return .contentHeightIgnoringSafeArea(self.view.bounds.height / 1.8)
    }

    var longFormHeight: PanModalHeight {
        return .contentHeightIgnoringSafeArea(self.view.bounds.height)
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var allowsExtendedPanScrolling: Bool {
        return true
    }
    
    var allowsDragToDismiss: Bool {
        return true
    }
    
    var cornerRadius: CGFloat {
        return 24
    }
}
