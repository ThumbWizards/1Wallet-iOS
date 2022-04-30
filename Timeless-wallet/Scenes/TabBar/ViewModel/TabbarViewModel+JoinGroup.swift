//
//  TabbarViewModel+JoinGroup.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 26/04/22.
//


import UIKit
import StreamChat
import StreamChatUI

extension TabBarView.ViewModel {
    func observeJoinGroup() {
        NotificationCenter.default.removeObserver(self, name: .generalGroupInviteLink, object: nil)
        NotificationCenter.default.removeObserver(self, name: .createPrivateGroup, object: nil)
        NotificationCenter.default.removeObserver(self, name: .joinPrivateGroup, object: nil)
        NotificationCenter.default.removeObserver(self, name: .getPrivateGroup, object: nil)
        NotificationCenter.default.removeObserver(self, name: .joinInviteGroup, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(generalGroupInviteLink(_:)),
            name: .generalGroupInviteLink,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(createPrivateGroup(_:)),
            name: .createPrivateGroup,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(joinPrivateGroup(_:)),
            name: .joinPrivateGroup,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getPrivateGroup(_:)),
            name: .getPrivateGroup,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(joinInviteGroup(_:)),
            name: .joinInviteGroup,
            object: nil)
    }

    @objc private func generalGroupInviteLink(_ notification: NSNotification) {
        if let info = notification.userInfo as? [String: String] {
            if let groupID = info[kInviteGroupID] {
                createGroupInvite(
                    groupId: groupID,
                    completion: ChatClientConfiguration.shared.requestedGeneralGroupDynamicLink)
            }
        }
    }

    @objc private func createPrivateGroup(_ notification: NSNotification) {
        if let info = notification.userInfo as? [String: Any] {
            if let passcode = info[kPrivateGroupPasscode] as? String,
               let long = info[kPrivateGroupLon] as? Float,
               let lat = info[kPrivateGroupLat] as? Float {
                createPrivateGroup(
                    password: passcode,
                    lon: long,
                    lat: lat,
                    completion: nil)
            }
        }
    }

    @objc private func joinPrivateGroup(_ notification: NSNotification) {
        if let info = notification.userInfo as? [String: Any] {
            if let passcode = info[kPrivateGroupPasscode] as? String,
               let groupId = info[kGroupId] as? String {
                joinPrivateGroup(groupId: groupId, password: passcode) {
                    ChatClientConfiguration.shared.joinPrivateGroup?()
                }
            }
        }
    }

    @objc private func getPrivateGroup(_ notification: NSNotification) {
        if let info = notification.userInfo as? [String: Any] {
            if let passcode = info[kPrivateGroupPasscode] as? String,
               let long = info[kPrivateGroupLon] as? Float,
               let lat = info[kPrivateGroupLat] as? Float {
                getPrivateGroup(
                    password: passcode,
                    lon: long,
                    lat: lat) { [weak self] invite in
                        guard let `self` = self else { return }
                        if invite == nil {
                            self.createPrivateGroup(
                                password: passcode,
                                lon: long,
                                lat: lat,
                                completion: ChatClientConfiguration.shared.createPrivateGroup)
                        } else {
                            ChatClientConfiguration.shared.getPrivateGroup?(invite)
                        }
                    }
            }
        }
    }

    @objc private func joinInviteGroup(_ notification: NSNotification) {
        if let info = notification.userInfo as? [String: String] {
            if let groupId = info[kInviteGroupID],
               let inviteCode = info[kInviteId] {
                joinGroup(
                    groupId: groupId,
                    inviteCode: inviteCode,
                    completion: ChatClientConfiguration.shared.joinInviteGroup)
            }
        }
    }
}

// MARK: - API Calls
extension TabBarView.ViewModel {
    func createGroupInvite(groupId: String, completion: callbackGeneralGroupInviteLink?) {
        let req = ReqCreateInvite(groupId: groupId, endTime: nil)
        IdentityService.shared.createInvite(req: req)
            .sink { result in
                switch result {
                case .success(let invite):
                    guard let dynamicLink = invite.dynamicLink else {
                        showSnackBar(.message(text: "Error while creating the invite link"))
                        completion?(nil)
                        return
                    }
                    completion?(URL(string: dynamicLink))
                case .failure:
                    showSnackBar(.message(text: "Error while creating the invite link"))
                    completion?(nil)
                }
            }
            .store(in: &currentNetworkCalls)
    }

    func createPrivateGroup(password: String, lon: Float, lat: Float, completion: ((CreatePrivateGroup) -> Void)?) {
        let req = ReqPrivateGroup(password: password, lon: lon, lat: lat)
        IdentityService.shared.createPrivateGroup(req: req)
            .sink { result in
                switch result {
                case .success(let response):
                    completion?(response)
                case .failure:
                    showSnackBar(.somethingWentWrongRandomText)
                }
            }
            .store(in: &currentNetworkCalls)
    }

    func joinPrivateGroup(groupId: String, password: String, completion: (() -> Void)?) {
        IdentityService.shared.joinPrivateGroup(groupId: groupId, req: .init(password: password))
            .sink { result in
                switch result {
                case .success:
                    completion?()
                case .failure:
                    showSnackBar(.somethingWentWrongRandomText)
                }
            }
            .store(in: &currentNetworkCalls)
    }

    func getPrivateGroup(password: String, lon: Float, lat: Float, completion: ((ChatInviteInfo?) -> Void)?) {
        IdentityService.shared.getPrivateGroup(password: password, lon: lon, lat: lat)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    if error == .groupNotFound {
                        completion?(nil)
                    } else {
                        showSnackBar(.somethingWentWrongRandomText)
                    }
                default: break
                }
            }, receiveValue: { result in
                completion?(result)
            })
            .store(in: &currentNetworkCalls)
    }

    func joinGroup(groupId: String, inviteCode: String, completion: ((Bool) -> Void)?) {
        let req = ReqJoinGroup(groupId: groupId, inviteId: inviteCode)
        IdentityService.shared.joinGroup(req: req)
            .sink { result in
                switch result {
                case .success(let response):
                    completion?(response.isEmpty ? false : true)
                case .failure:
                    showSnackBar(.errorMsg(text: "Wrong invitation link"))
                    completion?(false)
                }
            }
            .store(in: &currentNetworkCalls)
    }
}
