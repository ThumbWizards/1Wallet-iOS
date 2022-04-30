//
//  AESCTR.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 27/10/2021.
//
// swiftlint:disable identifier_name
import CommonCrypto

class AESCTR {
    let cryptor: CCCryptorRef?
    let key: [UInt8]

    enum AESError: Error {
        case initError
        case encryptError
    }

    init(key: [UInt8]) throws {
        var ccStatus: CCCryptorStatus = 0
        var cryptor: CCCryptorRef?

        var iv = [UInt8](repeating: 0, count: 16)
        iv[15] = 1

        ccStatus = CCCryptorCreateWithMode(CCOperation(kCCEncrypt),
                                           CCMode(kCCModeCTR),
                                           CCAlgorithm(kCCAlgorithmAES),
                                           CCPadding(ccNoPadding),
                                           iv, key,
                                           kCCKeySizeAES128,
                                           nil, 0, 0, // tweak XTS mode, numRounds
                                           CCModeOptions(kCCModeOptionCTR_BE), // CCModeOptions
                                           &cryptor)

        if cryptor == nil || ccStatus != kCCSuccess {
            CCCryptorRelease(cryptor)
            throw AESError.initError
        }
        self.key = key
        self.cryptor = cryptor
    }

    deinit {
        CCCryptorRelease(cryptor)
    }

    func encrypt(bytes dataIn: [UInt8]) throws -> [UInt8] {
        let dataOutLength = CCCryptorGetOutputLength(cryptor, dataIn.count, false)

        var dataOut = [UInt8](repeating: 0, count: dataOutLength)
        var dataOutMoved: size_t = 0
        var ccStatus: CCCryptorStatus = 0

        dataOut.withUnsafeMutableBytes { dataOutPointer in
            ccStatus = CCCryptorUpdate(cryptor,
                                       dataIn, dataIn.count,
                                       dataOutPointer.baseAddress, dataOutLength,
                                       &dataOutMoved)
        }

        if ccStatus != kCCSuccess {
            throw AESError.encryptError
        }
        return dataOut
    }
}
