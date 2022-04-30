//
//  Crypto+Helper.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 26/10/2021.
//
// swiftlint:disable identifier_name
// swiftlint:disable force_try

import Combine
import web3swift
import CryptoKit
import EllipticCurveKeyPair
import GRDB
import Sentry

enum OnboardWalletState {
    case generatingOTP
    case generatingMerkleTree
    case pingingHarmonyChain
    case chainPinged(wallet: Wallet, seed: [UInt8], t0: Int)
    case created(wallet: TLWallet)
    case imported
    case error(OneWalletService.NewWalletError)

    var stepIndex: Int {
        switch self {
        case .generatingOTP:
            return 0
        case .generatingMerkleTree:
            return 1
        case .pingingHarmonyChain:
            return 2
        case .chainPinged:
            return 3
        case .created, .imported:
            return 4
        case .error:
            return -1
        }
    }
}

struct CryptoHelper {
    static var shared = CryptoHelper()

    var viewModel = ViewModel()
    var newWalletSeed: [UInt8]?
    var newWalletReq: ReqNewWallet?
    var newWalletName: String?

    func generateWalletPayloadSilent() {
        CryptoHelper.shared.cleanUpEOTP()
        CryptoHelper.shared.newWalletSeed = nil
        CryptoHelper.shared.newWalletReq = nil
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                CryptoHelper.shared.viewModel.onboardWalletState = .generatingOTP
            }
            guard let seed = try? generateSeed() else {
                DispatchQueue.main.async {
                    CryptoHelper.shared.viewModel.onboardWalletState =
                        .error(OneWalletService.NewWalletError.couldNotGenerateSeed)
                }
                return
            }
            guard let req = try? generateWalletPayload(secret: seed) else {
                CryptoHelper.shared.viewModel.onboardWalletState =
                    .error(OneWalletService.NewWalletError.couldNotGenerateWalletPayload)
                return
            }

            CryptoHelper.shared.newWalletSeed = seed
            CryptoHelper.shared.newWalletReq = req
        }
    }
}

extension CryptoHelper {
    func generateEotp(otp: UInt32, hseed: [UInt8], rand: UInt32) -> [UInt8] {
        // 22 bytes: hseed - sha256(seed), then get first 22 bytes
        // 2 bytes: nonce - always 0 for now
        // 4 bytes: otp - big endian
        // 4 bytes: ctr randomness
        var otpBigEndian = otp.bigEndian

        var input: [UInt8] = []
        input += hseed
        input += [0, 0]
        input += otpBigEndian.byteArray()

        var randBigEndian = rand.bigEndian
        input += randBigEndian.byteArray()
        return input.fastSHA256()
    }

    func generateMerkleTree(secret: [UInt8], effectiveTime: Date, height: Int) throws -> MerkleTree {
        let input = try generateMerkleTreeInput(secret: secret, effectiveTime: effectiveTime, height: height)
        let mTree = MerkleTree(input)
        cacheMerkelTree(input: input, mTree: mTree)
        return mTree
    }

    private func cacheMerkelTree(input: [[UInt8]], mTree: MerkleTree) {
        Task.init(priority: .high) {
            guard let encryptKeyData = KeyChain.shared.encryptKey else {
                return
            }
            let encryptKey = SymmetricKey(data: encryptKeyData)
            let rootHex = mTree.rootHex
            try? Tables.EOTP.dynamicInitialize(mTreeRootHex: rootHex)
            let eotpModels = input.enumerated().map { index, eotp -> Tables.EOTP in
                let encryptedEOTP = try! ChaChaPoly.seal(eotp, using: encryptKey)
                return Tables.EOTP(otpIndex: index, encryptedEOTP: encryptedEOTP.combined.base64EncodedString())
            }
            do {
                try Tables.EOTP.batchInsert(elements: eotpModels, mTreeRootHex: rootHex)
            } catch {
                SentrySDK.capture(error: error)
                try? Tables.EOTP.drop(mTreeRootHex: rootHex)
            }
        }
    }

    func cleanUpEOTP() {
        Task.init(priority: .high) {
            LocalDB.shared.cleanUp()
        }
    }
}

private extension CryptoHelper {
    func generateWalletPayload(secret: [UInt8]) throws -> ReqNewWallet {
        let now = Date()
        let height = 21 // corresponding with duration of around 1 year
        let merkleTree = try generateMerkleTree(secret: secret, effectiveTime: now, height: height)
        let publicKey = Web3.Utils.privateToPublic(Data(secret), compressed: false)!
        // TODO: Store the merkle tree in keychain together with our secret as we will need it for all wallet operations
        return ReqNewWallet(
            root: merkleTree.rootHex,
            height: height,
            interval: 30,
            t0: Int(floor(now.timeIntervalSince1970 / 30)),
            lifespan: (3600 * 24 * 364) / 30,
            slotSize: 1,
            lastResortAddress: "0x7534978F9fa903150eD429C486D1f42B7fDB7a61",
            spendingLimit: "5000000000000000000000", // 5000 * 10^18
            spendingInterval: 86_400,
            backlinks: [],
            merkleTree: merkleTree,
            innerCores: [],
            identificationKeys: ["0x" + publicKey.suffix(from: 1).bytes.toHexString()],
            lastLimitAdjustmentTime: 0,
            highestSpendingLimit: "5000000000000000000000" // 5000 * 10^18
        )
    }

    func generateSeed() throws -> [UInt8] {
        let count = 32
        var bytes = [UInt8](repeating: 0, count: count)

        // Fill bytes with secure random data
        let status = SecRandomCopyBytes(
            kSecRandomDefault,
            count,
            &bytes
        )

        // A status of errSecSuccess indicates success
        if status == errSecSuccess {
            return bytes
        } else {
            throw OneWalletService.NewWalletError.couldNotGenerateSeed
        }
    }

    func otps(secret: [UInt8], startCounter: UInt32, count: Int) -> [UInt32] {
        var result: [UInt32] = []
        var counter = UInt64(startCounter)
        let totp = TOTP(secret: secret)

        for _ in 0..<count {
            let otp = totp.generateCode(counter: counter)
            result.append(otp)
            counter += 1
        }

        return result
    }

    func generateMerkleTreeInput(secret: [UInt8], effectiveTime: Date, height: Int) throws -> [[UInt8]] {
        let count = 1 << (height - 1)

        var result: [[UInt8]] = [[UInt8]](repeating: [], count: count)

        let hseed = Array(secret.fastSHA256().prefix(22))
        let encryptor = try AESCTR(key: Array(secret.prefix(16)))
        var counter = UInt32(floor(effectiveTime.timeIntervalSince1970 / 30))
        let aesInput = counter.byteArray()
        let otps = otps(secret: secret, startCounter: counter, count: count)

        DispatchQueue.main.async {
            CryptoHelper.shared.viewModel.onboardWalletState = .generatingMerkleTree
        }

        for idx in 0..<count {
            let r = try encryptor.encrypt(bytes: aesInput).prefix(4)
            let data = Data(Array(r))
            let randomNumber = UInt32(bigEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) }) >> 14

            let input = generateEotp(otp: otps[idx], hseed: hseed, rand: randomNumber)
            result[idx] = input
        }
        return result
    }
}

extension CryptoHelper {
    class ViewModel: ObservableObject {
        @Published var onboardWalletState: OnboardWalletState?
    }
}
