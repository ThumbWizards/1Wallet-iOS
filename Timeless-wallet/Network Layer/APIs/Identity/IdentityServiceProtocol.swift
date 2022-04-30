//
//  IdentityService.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import Foundation
import Combine
import StreamChatUI

protocol IdentityServiceProtocol {
    var isAuthenticated: Bool { get }
    func fetchStreamChatToken() -> AnyPublisher<Swift.Result<StreamChatToken, Error>, Never>
    var createWallet: AnyPublisher<Swift.Result<TLWallet, API.APIError>, Never> { get }
    func dropGiftPacket(req: ReqDropGiftPacket) -> AnyPublisher<Swift.Result<GiftPacketDrop, API.APIError>, Never>
    func claimGiftPacket(packetId: String) -> AnyPublisher<ClaimGiftPacket, GiftPacketClaimError>
    func claimGiftPacketSuccessful(req: ReqGiftCardClaimed, packetId: String) -> AnyPublisher<Swift.Result<ClaimedGiftPacket, API.APIError>, Never>
    func updateWalletAvatar(address: String, avatar: String) -> AnyPublisher<Swift.Result<Wallet, Error>, Never>
    func createInvite(req: ReqCreateInvite) -> AnyPublisher<Swift.Result<GroupInvite, API.APIError>, Never>
    func joinGroup(req: ReqJoinGroup) -> AnyPublisher<Swift.Result<JoinGroup, API.APIError>, Never>
}

enum GiftPacketClaimError: Error {
    case packetNotExist
    case packetExpired
    case packetFullyClaimed
    case requestError
    case noInternet
}

enum PrivateGroupError: Error {
    case groupNotFound
    case requestError
}
