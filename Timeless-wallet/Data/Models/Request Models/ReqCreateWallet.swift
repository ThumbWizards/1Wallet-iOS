//
//  ReqCreateWallet.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 15/11/2021.
//

class ReqCreateWallet {

    // MARK: - Variables
    var title = ""
    var address = ""
    var avatar = ""

    init(title: String, address: String, avatar: String) {
        self.title = title
        self.address = address
        self.avatar = avatar
    }

    // MARK: - Functions
    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["title"] = title
        dictOut["address"] = address
        dictOut["avatar"] = avatar
        if Wallet.allWallets.isEmpty {
            dictOut["onboarding_group_chat"] = true
        }
        return dictOut
    }
}
