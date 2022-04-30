//
//  Wallet.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 26/10/2021.
//
// swiftlint:disable identifier_name
import Foundation
import web3swift
import StreamChat
import SwiftUI
import Combine
import Sentry

struct WalletDetailViewModel {
    // Wallet detail view model
    var nftModel: WalletNFTsView.ViewModel
    var trxnModel: WalletTrxnView.ViewModel
    var overviewModel: WalletOverviewView.ViewModel
    var multiSigModel: WalletMultiSigView.ViewModel
}

class WalletInfo: ObservableObject {
    static let shared = WalletInfo()

    @Atomic var merkelTrees: [String: MerkleTree] = [:]
    var detailViewModel: [String: WalletDetailViewModel] = [:]
    var listenCancellables = Set<AnyCancellable>()
    @Published var qrCodeCGImage: [String: CGImage] = [:]
    @Published var didChangedCurrentWallet = false
    @Published var totalOneUSD: Double?
    @Published var totalOne: Double?
    @Published var isShowingAnimation = false
    @Published var activeWalletIndex = -1
    @Published var currentWallet = Wallet.currentWallet! {
        didSet {
            Wallet.setCurrentWallet(currentWallet)
            withAnimation {
                allWallets = Wallet.getAllWallets()
            }
            if oldValue != currentWallet {
                didChangedCurrentWallet.toggle()
                // Todo: need to refactor chat login flow
                TabBarView.ViewModel.shared.syncWithWalletInfo()
                // Pre-generate merkeltree for speeding up transaction
                DispatchQueue.global(qos: .userInitiated).async {
                    _ = Wallet.currentMerkleTree
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isShowingAnimation = false
            }
        }
    }
    @Published var allWallets = Wallet.getAllWallets()
    var carouselWallets: [CarouselItem] {
        return Wallet.allWallets.enumerated().compactMap { CarouselItem(id: $0, wallet: $1)}
    }

    init() {
        $activeWalletIndex
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .subscribe(on: RunLoop.main)
            .sink { [weak self] activeValue in
                guard let self = self,
                      activeValue >= 0,
                      self.carouselWallets.count > activeValue else {
                    return
                }
                if self.currentWallet != self.carouselWallets[activeValue].wallet {
                    let host = UIHostingController(
                        rootView: ChangingWalletView(wallet: self.carouselWallets[activeValue].wallet)
                    )
                    host.modalPresentationStyle = .overFullScreen
                    host.modalTransitionStyle = .crossDissolve
                    present(host, animated: true)
                    self.isShowingAnimation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.currentWallet = self.carouselWallets[activeValue].wallet
                    }
                }
            }
            .store(in: &listenCancellables)
    }

    func refreshWalletData() {
        let refreshGroup = DispatchGroup()
        allWallets.forEach {
            refreshGroup.enter()
            $0.detailViewModel.overviewModel.getWalletAssetInfo {
                refreshGroup.leave()
            }
        }
        refreshGroup.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }
            let updatedTotalONE = Wallet.allWallets.reduce(0) {
                $0 + ($1.detailViewModel.overviewModel.totalONEAmount ?? 0)
            }
            let updatedTotalOneUSD = Wallet.allWallets.reduce(0) {
                $0 + ($1.detailViewModel.overviewModel.totalUSDAmount ?? 0)
            }
            //Only refresh wallet view if balance value is updated
            //Add check to avoid unnecessary reload in walletView
            if updatedTotalONE != self.totalOne || updatedTotalOneUSD != self.totalOneUSD {
                self.totalOne = updatedTotalONE
                self.totalOneUSD = updatedTotalOneUSD
            }
        }
    }

    func generateWalletQRCode(for wallet: Wallet? = nil) {
        if let wallet = wallet {
            DispatchQueue.global(qos: .background).async {
                let qrCode = QRCodeHelper
                    .generateQRCodeCFImage(from: wallet.address.convertToWalletAddress())
                DispatchQueue.main.async {
                    self.qrCodeCGImage[wallet.address] = qrCode
                }
            }
            return
        }
        var qrCodeCGImage: [String: CGImage] = [:]
        DispatchQueue.global(qos: .background).async {
            Wallet.allWallets.forEach { wallet in
                qrCodeCGImage[wallet.address] = QRCodeHelper
                    .generateQRCodeCFImage(from: wallet.address.convertToWalletAddress())
            }
            DispatchQueue.main.async {
                self.qrCodeCGImage = qrCodeCGImage
            }
        }
    }
}

struct Wallet: Codable, Equatable {
    static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.address == rhs.address && lhs.name == rhs.name && lhs.avatarUrl == rhs.avatarUrl
    }

    enum CodingKeys: String, CodingKey {
        case address, name, avatarUrl
    }

    init(address: String) {
        self.address = address
    }

    var address: String
    var name: String?

    var isValid: Bool {
        address != "invalid"
    }

    var nameFullAlias: String {
        if let name = name {
            if name.lowercased() == address.lowercased() {
                return address.trimStringByCount(count: 10)
            } else {
                return name.toCrazyOne() ?? name
            }
        }
        return address.trimStringByCount(count: 10)
    }

    var avatarUrl: String?

    var avatar: String {
        return avatarUrl ?? "\(Constants.URLImageContact.url)/\(self.address)/"
    }

    var fixedAvatar: String {
        return "\(Constants.URLImageContact.url)/\(self.address)/"
    }

    var fixedAvatarURL: URL? {
        return URL(string: "\(Constants.URLImageContact.url)/\(self.address)/")
    }

    var seed: [UInt8]? {
        return Self.allWalletSeeds[address] ?? nil
    }

    var streamChatAccessToken: String? {
        return Self.allStreamChatAccessTokens[address]
    }

    var messageSignature: MessageSignature? {
        return Self.allWalletSignatures[address]
    }

    var merkelTree: MerkleTree? {
        if WalletInfo.shared.merkelTrees[address] == nil {
            if let mTreeFromFile = merkelTreeFromFile {
                WalletInfo.shared.merkelTrees = [address: mTreeFromFile]
                encryptWalletsHandler()
            } else {
                if let mTree = generateMerkelTree() {
                    storeMerkelTreeToFile(mTree)
                    WalletInfo.shared.merkelTrees = [address: mTree]
                } else {
                    SentrySDK.capture(message: "Could not generate MerkelTree for \(address)")
                }
            }
        }
        if rootHex == nil {
            Self.allWalletRootHexes[address] = WalletInfo.shared.merkelTrees[address]?.rootHex
        }
        CryptoHelper.shared.cleanUpEOTP()
        return WalletInfo.shared.merkelTrees[address]
    }

    var effectiveTime: Date? {
        return Self.allEffectiveTimes[address]
    }

    var rootHex: String? {
        Self.allWalletRootHexes[address]
    }

    var googleAuthDeepLink: String? {
        guard let seed = seed else {
            return nil
        }
        var migrationPayload = MigrationPayload()

        var otpParameters = MigrationPayload.OtpParameters()
        otpParameters.issuer = "Harmony"
        otpParameters.secret = Data(seed)
        otpParameters.name = address
        otpParameters.algorithm = .sha1
        otpParameters.digits = .six
        otpParameters.type = .totp

        migrationPayload.otpParameters = [otpParameters]
        migrationPayload.version = 1
        migrationPayload.batchIndex = 0
        migrationPayload.batchSize = 1

        guard let googleAuthDeepLinkData = try? migrationPayload
                .serializedData().base64EncodedString() else {
                    return nil
                }

        var urlComponents = URLComponents()
        urlComponents.scheme = "otpauth-migration"
        urlComponents.host = "offline"
        urlComponents.queryItems = [
            URLQueryItem(name: "data", value: googleAuthDeepLinkData)
        ]
        return urlComponents.url?.absoluteString
    }

    // swiftlint:disable line_length
    var uniqueKey: String {
        "\(address)|\(avatar)|\(nameFullAlias)|\(String(describing: detailViewModel.overviewModel.totalUSDAmount))|\(String(describing: detailViewModel.overviewModel.totalONEAmount))"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? "invalid"
        name = try container.decodeIfPresent(String.self, forKey: .name)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
    }
}

extension Wallet {
    static var allWallets: [Wallet] {
        return KeyChain.shared.retrieve(key: .allWallets, defaultValue: [Wallet]()) ?? []
    }

    static var allWalletSeeds: [String: [UInt8]?] {
        return KeyChain.shared.retrieve(key: .allWalletSeeds, defaultValue: [:]) ?? [:]
    }

    static var allEffectiveTimes: [String: Date] {
        get {
            return KeyChain.shared.retrieve(key: .allEffectiveTimes,
                                            defaultValue: [:]
            ) ?? [:]
        }
        set {
            _ = KeyChain.shared.store(key: .allEffectiveTimes,
                                    obj: newValue
            )
            Backup.shared.sync(newBackup: false) { _ in }
        }
    }

    static var allWalletSignatures: [String: MessageSignature] {
        get {
            return KeyChain.shared.retrieve(
                key: .allWalletSignaturesV1,
                defaultValue: [String: MessageSignature]()
            ) ?? [String: MessageSignature]()
        }
        set {
            _ = KeyChain.shared.store(
                key: .allWalletSignaturesV1,
                obj: newValue
            )
            Backup.shared.sync(newBackup: false) { _ in }
        }
    }

    private static var currentWalletSignature: [UInt8]? {
        return Wallet.currentWallet?.messageSignature?.signature
    }

    static var currentEncodedSignature: String? {
        guard let currentWalletSignature = currentWalletSignature else {
            return nil
        }
        return Data(currentWalletSignature).base64EncodedString()
    }

    static var allStreamChatAccessTokens: [String: String] {
        get {
            return KeyChain.shared.retrieve(
                key: .allStreamChatAccessTokens,
                defaultValue: [String: String]()
            ) ?? [String: String]()
        }
        set {
            _ = KeyChain.shared.store(
                key: .allStreamChatAccessTokens,
                obj: newValue
            )
            Backup.shared.sync(newBackup: false) { _ in }
        }
    }

    static var allWalletRootHexes: [String: String] {
        get {
            return KeyChain.shared.retrieve(
                key: .allWalletRootHexes,
                defaultValue: [String: String]()
            ) ?? [String: String]()
        }
        set {
            _ = KeyChain.shared.store(
                key: .allWalletRootHexes,
                obj: newValue
            )
            Backup.shared.sync(newBackup: false) { _ in }
        }
    }

    static var currentStreamChatAccessTokens: String? {
        return allStreamChatAccessTokens[Wallet.currentWallet?.address ?? ""]
    }
}

extension Wallet {
    static func addWallet(_ wallet: Wallet, seed: [UInt8]?, t0: Int) -> Bool {
        var allWallet = Wallet.allWallets
        allWallet.append(wallet)
        guard KeyChain.shared.store(key: .allWallets, obj: allWallet) == errSecSuccess else {
            return false
        }
        var currentSeeds = Self.allWalletSeeds
        currentSeeds[wallet.address] = seed
        guard KeyChain.shared.store(key: .allWalletSeeds, obj: currentSeeds) == errSecSuccess else {
            return false
        }
        var currentEffectiveTimes = Self.allEffectiveTimes
        currentEffectiveTimes[wallet.address] = Date(timeIntervalSince1970: TimeInterval(t0 * 30))
        guard KeyChain.shared.store(key: .allEffectiveTimes, obj: currentEffectiveTimes) == errSecSuccess else {
            return false
        }
        setCurrentWallet(wallet)

        WalletInfo.shared.generateWalletQRCode(for: wallet)

        // Backup Wallet
        Backup.shared.sync(newBackup: false) { _ in }
        return true
    }

    func createWalletSignature(completion: @escaping ((MessageSignature?) -> Void)) {
        Task.init(priority: .high, operation: {
            if let signature = messageSignature {
                DispatchQueue.main.async {
                    completion(signature)
                }
                return
            }
            let message = "1wallet-address:\(address)"
            let messageHash = [UInt8](message.utf8).sha3(.keccak256)
            guard let hash = Web3.Utils.hashPersonalMessage(message.utf8.data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let (signature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: seed?.data ?? Data())
            guard let signatureBytes = signature?.bytes else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let messageSignature = MessageSignature(message: message, hash: messageHash, signature: signatureBytes, expiry: nil)
            Wallet.allWalletSignatures[self.address] = messageSignature
            DispatchQueue.main.async {
                completion(messageSignature)
            }
        })
    }

    static func updateWallet(wallet: Wallet? = currentWallet, title: String? = nil, avatar: String? = nil) {
        guard let currentWallet = wallet else { return }
        if var selectedWallet = allWallets.first(where: { $0.address == currentWallet.address }) {
            if let walletTitle = title {
                selectedWallet.name = walletTitle
            } else if let walletAvatar = avatar {
                selectedWallet.avatarUrl = walletAvatar
            }
            var wallets = Wallet.allWallets
            if let selectedWalletIndex = wallets.firstIndex(where: { $0.address == selectedWallet.address }) {
                wallets.remove(at: selectedWalletIndex)
                wallets.insert(selectedWallet, at: selectedWalletIndex)
            }
            _ = KeyChain.shared.store(key: .allWallets, obj: wallets)

            // Update getStream user
            GetStreamChat.shared.updateLoginUser(wallet: selectedWallet)
        }
    }
}

extension Wallet {
    static var currentWalletAddress: String {
        get {
            // swiftlint:disable line_length
            UserDefaults.standard.value(forKey: ASSettings.UserInfo.currentWalletAddress.key) as? String ?? ASSettings.UserInfo.currentWalletAddress.defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ASSettings.UserInfo.currentWalletAddress.key)
        }
    }
}

extension Wallet {
    static var currentWallet: Wallet? {
        if !currentWalletAddress.isEmpty {
            return allWallets.first { $0.address == currentWalletAddress }
        }
        return allWallets.first
    }

    static var currentMerkleTree: MerkleTree? {
        return Wallet.currentWallet?.merkelTree
    }

    private func generateMerkelTree() -> MerkleTree? {
        guard NetworkHelper.shared.reachability?.connection != Reachability.Connection.none,
              let walletAddress = EthereumAddress(address.convertBech32ToEthereum()) else {
            return nil
        }
        if CryptoHelper.shared.newWalletReq?.merkleTree != nil && CryptoHelper.shared.newWalletSeed == seed {
            return CryptoHelper.shared.newWalletReq!.merkleTree
        }
        do {
            let walletInfo = try OneWalletService.shared.getWalletInfo(address: walletAddress)
            let effectiveTime = Date(timeIntervalSince1970: TimeInterval(walletInfo.t0 * 30))
            let mTree = try CryptoHelper.shared.generateMerkleTree(secret: seed ?? [],
                                                                   effectiveTime: effectiveTime,
                                                                   height: walletInfo.height)
            return mTree
        } catch {
            return nil
        }
    }
}

extension Wallet {
    var detailViewModel: WalletDetailViewModel {
        if WalletInfo.shared.detailViewModel[address] == nil {
            WalletInfo.shared.detailViewModel[address] =
            WalletDetailViewModel(nftModel: WalletNFTsView.ViewModel(wallet: self),
                                  trxnModel: WalletTrxnView.ViewModel(wallet: self),
                                  overviewModel: WalletOverviewView.ViewModel(wallet: self),
                                  multiSigModel: WalletMultiSigView.ViewModel(wallet: self)
            )
        }
        return WalletInfo.shared.detailViewModel[address]!
    }

    static func setCurrentWallet(_ wallet: Wallet) {
        Wallet.currentWalletAddress = wallet.address
        StickerApi.userId = wallet.address
    }
}

extension Wallet {
    static func getAllWallets() -> [Wallet] {
        if let currentWallet = currentWallet {
            var allWallet = Wallet.allWallets
            if let selectWalletIndex = allWallet.firstIndex(where: { $0.address == currentWallet.address }) {
                allWallet.swapAt(0, selectWalletIndex)
            }
            return allWallet
        }
        return Wallet.allWallets
    }
}

extension Wallet {
    private var merkelTreeFilePath: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return documentDirectory[0].appendingPathComponent("\(address).merkelTree")
    }

    private var merkelTreeFromFile: MerkleTree? {
        do {
            let data = try Data(contentsOf: merkelTreeFilePath)
            let obj = try MerkleTree.decode(data: data.bytes)
            return obj
        } catch {
            return nil
        }
    }

    private func storeMerkelTreeToFile(_ mTree: MerkleTree) {
        do {
            try mTree.encode().write(to: merkelTreeFilePath)
        } catch {
            SentrySDK.capture(error: error)
        }
    }
}

extension Wallet: Identifiable {
    var id: String {
        return address
    }
}


extension Wallet {
    func encryptWalletsHandler() {
        Task.init(priority: .high) {
            if let rootHex = rootHex ?? merkelTree?.rootHex {
                let tableName = Tables.EOTP.tableName(rootHex)
                guard !LocalDB.shared.allTables().contains(tableName) || Tables.EOTP.eotpCount(mTreeRootHex: rootHex) == 0 else {
                    return
                }
                _ = generateMerkelTree()
            }
        }
    }
}
