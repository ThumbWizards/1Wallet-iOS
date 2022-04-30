//
//  IdentityService.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 24/10/21.
//

import Foundation
import Combine
import StreamChatUI
import SwiftUI
import StreamChat

class IdentityService: BaseRestAPI<IdentityService.RequestType>, IdentityServiceProtocol {
    @UserDefault(
        key: ASSettings.General.freshInstall.key,
        defaultValue: ASSettings.General.freshInstall.defaultValue
    )
    private var freshInstall: Bool

    static let shared = IdentityService()

    var isAuthenticated: Bool {
        if freshInstall {
            // Use logout func to clear all of the data has been cached in the keychain for the fresh install
            logout()
            freshInstall = false
        }
        return !Wallet.allWallets.isEmpty
    }

    func logout() {
        // Clear all keychain data
        KeyChain.Key.allCasesWithoutBackup.forEach { key in
            _ = KeyChain.shared.clear(key: key)
        }
        KeyChain.shared.encryptKeyInitialize()

        let defaults = UserDefaults.standard
        // Clear all user default data
        defaults.dictionaryRepresentation().keys.forEach { key in
            let persistentKeys = [ASSettings.General.freshInstall.key,
                                  ASSettings.NotificationService.deviceToken.key,
                                  ASSettings.KeyChain.currentVersion.key]
            if !persistentKeys.contains(key) {
                defaults.removeObject(forKey: key)
            }
        }
        // Clear all local db data
        LocalDB.shared.truncate()

        GetStreamChat.shared.logout()
        // Reset app icon
        Utils.setApplicationIconNameWihoutMessage(nil)
        // Clear testnet top red bar
        UIApplication.shared.windows.first?.viewWithTag(100)?.removeFromSuperview()
        // Refreshing the whole app state
        NotificationCenter.default.post(name: .appStateChange, object: nil)
        // Reset app lock to disabled
        Lock.shared.appLockEnable = false
        dismissAll {
            let host = UIHostingController(rootView: SplashVideoView(isPlayingSplash: .constant(true), isLocked: false))
            host.modalPresentationStyle = .overFullScreen
            host.modalTransitionStyle = .crossDissolve
            present(host, animated: false)
        }
    }

    func fetchStreamChatToken() -> AnyPublisher<Swift.Result<StreamChatToken, Error>, Never> {
        self.call(type: .chatToken, params: nil)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(StreamChatToken.self)
            .receive(on: DispatchQueue.main)
            .map { token in
                return .success(token)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func checkWalletTitle(walletName: String) -> AnyPublisher<Swift.Result<CheckAlias, API.APIError>, Never> {
        return self.call(type: .checkWalletTitle(walletName: walletName), params: nil)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(CheckAlias.self)
            .receive(on: DispatchQueue.main)
            .map { alias in
                return .success(alias)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func checkWalletAddress(address: String) -> AnyPublisher<Swift.Result<CheckAddress, API.APIError>, Never> {
        return self.call(type: .checkWalletAddress(address: address), params: nil)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(CheckAddress.self)
            .receive(on: DispatchQueue.main)
            .map { wallet in
                return .success(wallet)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func dropGiftPacket(req: ReqDropGiftPacket) -> AnyPublisher<Swift.Result<GiftPacketDrop, API.APIError>, Never> {
        return self.call(type: .dropGiftPacket, params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(GiftPacketDrop.self)
            .map { giftPacket in
                if giftPacket.data?.id == nil {
                    return .failure(.requestError)
                } else {
                    return .success(giftPacket)
                }
            }
            .catch({ (error) -> Just<Swift.Result<GiftPacketDrop, API.APIError>> in
                if error.code == HTTPStatusCode.noInternetConnection.rawValue {
                    return Just(.failure((error as? API.APIError) ?? .noInternet))
                } else {
                    return Just(.failure((error as? API.APIError) ?? .requestError))
                }
            })
                    .eraseToAnyPublisher()
    }

    func claimGiftPacket(packetId: String) -> AnyPublisher<ClaimGiftPacket, GiftPacketClaimError> {
        return self.call(type: .claimGiftPacket(packetId: packetId), params: nil)
            .unwrapResultJSONFromAPI()
            .tryMap { res in
                if let response = res.response as? HTTPURLResponse {
                    if response.statusCode == 410 {
                        throw GiftPacketClaimError.packetExpired
                    } else if response.statusCode == 404 {
                        throw  GiftPacketClaimError.packetNotExist
                    } else if response.statusCode == 400 {
                        throw GiftPacketClaimError.packetFullyClaimed
                    } else if response.statusCode == HTTPStatusCode.noInternetConnection.rawValue {
                        throw GiftPacketClaimError.noInternet
                    } else {
                        return res.data
                    }
                } else {
                    return res.data
                }
            }
            .decodeFromJson(ClaimGiftPacket.self)
            .receive(on: DispatchQueue.main)
            .tryMap { packet in
                if packet.data?.id == nil {
                    throw GiftPacketClaimError.requestError
                } else {
                    return packet
                }
            }
            .mapError { error in
                return error as? GiftPacketClaimError ?? .requestError
            }
            .eraseToAnyPublisher()
    }

    func claimGiftPacketSuccessful(req: ReqGiftCardClaimed, packetId: String) -> AnyPublisher<Swift.Result<ClaimedGiftPacket, API.APIError>, Never> {
        return self.call(type: .claimedGiftPacket(packetId: packetId), params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(ClaimedGiftPacket.self)
            .receive(on: DispatchQueue.main)
            .map { response in
                if response.id == nil {
                    return .failure(.requestError)
                } else {
                    return .success(response)
                }
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    var createWallet: AnyPublisher<Swift.Result<TLWallet, API.APIError>, Never> {
        guard case let .chainPinged(wallet: rawWallet, seed: seed, t0: t0) = CryptoHelper.shared.viewModel.onboardWalletState else {
            return Just(.failure(API.APIError.requestError)).eraseToAnyPublisher()
        }
        return self.call(type: .createWallet, params: ReqCreateWallet(
            title: CryptoHelper.shared.newWalletName ?? rawWallet.address,
            address: rawWallet.address, avatar: ProfileListModal.listAvatar.randomElement() ?? ""
        )
            .toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(TLWallet.self)
            .receive(on: DispatchQueue.main)
            .map { tlWallet in
                var newWallet = rawWallet
                newWallet.name = tlWallet.title
                newWallet.avatarUrl = tlWallet.avatar
                if !Wallet.addWallet(newWallet, seed: seed, t0: t0) {
                    // TODO: Better error naming, should we move this logic to the view model?
                    return .failure(.requestError)
                }
                return .success(tlWallet)
            }
            .catch { error in
                 Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func updateWalletAvatar(address: String,
                            avatar: String) -> AnyPublisher<Swift.Result<Wallet, Error>, Never> {
        var req = [String: Any]()
        req["avatar"] = avatar
        return self.call(type: .update(address: address), params: req)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(Wallet.self)
            .receive(on: DispatchQueue.main)
            .map { wallet in
                return .success(wallet)
            }
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }

    func updateWalletTitle(
        address: String,
        title: String
    ) -> AnyPublisher<Swift.Result<Wallet, Error>, Never> {
        var req = [String: Any]()
        req["title"] = title
        return self.call(type: .update(address: address), params: req)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(Wallet.self)
            .receive(on: DispatchQueue.main)
            .map { wallet in
                return .success(wallet)
            }
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }

    func createInvite(req: ReqCreateInvite) -> AnyPublisher<Swift.Result<GroupInvite, API.APIError>, Never> {
        return call(type: .createInvite, params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(GroupInvite.self)
            .receive(on: DispatchQueue.main)
            .map { invite in
                return .success(invite)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func joinGroup(req: ReqJoinGroup) -> AnyPublisher<Result<JoinGroup, API.APIError>, Never> {
        return call(type: .joinGroup, params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(JoinGroup.self)
            .receive(on: DispatchQueue.main)
            .map { wallet in
                return .success(wallet)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func getChatInvite(req: ReqJoinGroup) -> AnyPublisher<Result<ChatInviteInfo, API.APIError>, Never> {
        return call(type: .getChatInvite(inviteId: req.inviteId ?? "", groupId: req.groupId ?? ""), params: nil)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(ChatInviteInfo.self)
            .receive(on: DispatchQueue.main)
            .map { inviteInfo in
                return .success(inviteInfo)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func createPrivateGroup(req: ReqPrivateGroup) -> AnyPublisher<Result<CreatePrivateGroup, API.APIError>, Never> {
        return call(type: .createPrivateGroup, params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(CreatePrivateGroup.self)
            .receive(on: DispatchQueue.main)
            .map { inviteInfo in
                return .success(inviteInfo)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func joinPrivateGroup(groupId: String, req: ReqPrivateGroup) -> AnyPublisher<Result<CreatePrivateGroup, API.APIError>, Never> {
        return call(type: .joinPrivateGroup(groupId: groupId), params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(CreatePrivateGroup.self)
            .receive(on: DispatchQueue.main)
            .map { inviteInfo in
                return .success(inviteInfo)
            }
            .catch { error in
                Just(.failure((error as? API.APIError) ?? .requestError))
            }
            .eraseToAnyPublisher()
    }

    func getPrivateGroup(password: String, lon: Float, lat: Float) -> AnyPublisher<ChatInviteInfo, PrivateGroupError> {
        return call(type: .getPrivateGroup(password: password, lon: lon, lat: lat), params: nil)
            .unwrapResultJSONFromAPI()
            .tryMap { res in
                if let response = res.response as? HTTPURLResponse {
                    if response.statusCode == 404 {
                        throw  PrivateGroupError.groupNotFound
                    } else {
                        return res.data
                    }
                } else {
                    return res.data
                }
            }
            .decodeFromJson(ChatInviteInfo.self)
            .receive(on: DispatchQueue.main)
            .tryMap { groupInfo in
                if groupInfo.channel.cid == nil {
                    throw PrivateGroupError.requestError
                } else {
                    return groupInfo
                }
            }
            .mapError { error in
                return (error as? PrivateGroupError) ?? .requestError
            }
            .eraseToAnyPublisher()
    }

    override func createPublisher(
        for request: URLRequest,
        type: RequestType,
        requestModifier:@escaping RequestModifier) -> URLSession.ErasedDataTaskPublisher {
            Future<URLRequest, Error> { promise in
                promise(.success(request))
                // There is no authentication requires for now
                // promise(.failure(API.APIError.unauthorized))
            }.eraseToAnyPublisher()
                .flatMap { [self] in
                    urlSession.erasedDataTaskPublisher(for: requestModifier($0))
                }
                .eraseToAnyPublisher()
        }
}

extension IdentityService {
    enum RequestType: EndPointType {
        case chatToken
        case createWallet
        case checkWalletTitle(walletName: String)
        case checkWalletAddress(address: String)
        case dropGiftPacket
        case claimGiftPacket(packetId: String)
        case claimedGiftPacket(packetId: String)
        case update(address: String)
        case createInvite
        case joinGroup
        case getChatInvite(inviteId: String, groupId: String)
        case getPrivateGroup(password: String, lon: Float, lat: Float)
        case createPrivateGroup
        case joinPrivateGroup(groupId: String)

        // MARK: Vars & Lets
        var baseURL: String {
            return AppConstant.serverURL
        }

        var version: String {
            return "v2/"
        }

        var path: String {
            switch self {
            case .chatToken:
                return "chat/token/"
            case .createWallet:
                return "wallets/"
            case .dropGiftPacket:
                return "gift_packets/"
            case .claimGiftPacket(packetId: let packetId):
                return "gift_packets/\(packetId)/"
            case .claimedGiftPacket(packetId: let packetId):
                return "gift_packets/\(packetId)/claim_successful/"
            case .checkWalletTitle(walletName: let name):
                return "wallets/title_checking/\(name)/"
            case .checkWalletAddress(address: let address):
                return "wallets/\(address)/"
            case .update(address: let address):
                return "wallets/\(address)/"
            case .createInvite:
                return "chat/invites/"
            case .joinGroup:
                return "chat/join/"
            case let .getChatInvite(inviteId, groupId):
                return "chat/invites/\(inviteId)/?group_id=\(groupId)"
            case let .getPrivateGroup(password, lon, lat):
                return "chat/private_group/?password=\(password)&lon=\(lon)&lat=\(lat)"
            case .createPrivateGroup:
                return "chat/private_group/"
            case .joinPrivateGroup(let groupId):
                return "chat/private_group/\(groupId)/"
            }
        }

        var httpMethod: HTTPMethod {
            switch self {
            case .createWallet, .dropGiftPacket, .claimGiftPacket,
                    .claimedGiftPacket, .createInvite, .joinGroup,
                    .createPrivateGroup, .joinPrivateGroup:
                return .post
            case .update:
                return .put
            case .chatToken, .checkWalletTitle, .checkWalletAddress, .getChatInvite,
                    .getPrivateGroup:
                return .get
            }
        }

        var headers: [String: String] {
            switch self {
            case .createWallet:
                return NetworkHelper.httpVersionHeader
            default:
                return NetworkHelper.httpWalletHeader
            }
        }
    }
}
