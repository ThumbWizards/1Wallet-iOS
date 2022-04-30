//
//  PreviewContextAction.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 27/10/21.
//

import SwiftUI

class PreviewContextAction {
    // MARK: - Variables
    private var type: [ContextActionType]
    var action: ((ContextActionType) -> Void)?

    init(
        _ type: [ContextActionType],
        action: ((ContextActionType) -> Void)? = nil
    ) {
        self.type = type
        self.action = action
    }

    var uiActions: [UIAction] {
        type.map { contextMenuType in
            UIAction(
                title: contextMenuType.title,
                image: contextMenuType.icon,
                attributes: contextMenuType.attributes) { [weak self] _ in
                self?.action?(contextMenuType)
            }
        }
    }
}
