//
//  KeyPair.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 20/04/2022.
//

import EllipticCurveKeyPair

struct KeyPair {
    static let manager: EllipticCurveKeyPair.Manager = {
        let publicAccessControl = EllipticCurveKeyPair
            .AccessControl(protection: kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags: [])
        let privateAccessControl = EllipticCurveKeyPair
            .AccessControl(protection: kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags: .privateKeyUsage)
        let config = EllipticCurveKeyPair.Config(
            publicLabel: "1wallet.encrypt.public",
            privateLabel: "1wallet.encrypt.private",
            operationPrompt: "Decrypt",
            publicKeyAccessControl: publicAccessControl,
            privateKeyAccessControl: privateAccessControl,
            token: .secureEnclaveIfAvailable)
        return EllipticCurveKeyPair.Manager(config: config)
    }()
}
