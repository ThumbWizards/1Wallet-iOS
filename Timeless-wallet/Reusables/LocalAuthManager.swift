//
//  LocalAuthManager.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 13/04/2022.
//

import Foundation
import LocalAuthentication

public class LocalAuthManager: NSObject {
    public static let shared = LocalAuthManager()
    private let context = LAContext()
    private var error: NSError?

    enum BiometricType: String {
        case none
        case touchID
        case faceID
        case unknown
    }

    // check type of local authentication device currently support
    var biometricType: BiometricType {
        guard self.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .none: return .none
        case .touchID: return .touchID
        case .faceID: return .faceID
        @unknown default: return .unknown
        }
    }
}
