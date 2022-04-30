//
//  SettingsView.swift
//  Timeless-wallet
//
//  Created by Parth Kshatriya on 26/10/21.
//

import SwiftUI

struct SettingsView {
    // MARK: - Variables
    @AppStorage(ASSettings.Setting.requireForTransaction.key)
    private var requireForTransaction = ASSettings.Setting.requireForTransaction.defaultValue
    @AppStorage(ASSettings.Setting.publicProfile.key)
    private var publicProfile = ASSettings.Setting.publicProfile.defaultValue
    @AppStorage(ASSettings.Setting.publicNFTExhibition.key)
    private var publicNFTExhibition = ASSettings.Setting.publicNFTExhibition.defaultValue
    @AppStorage(ASSettings.Settings.lockMethod.key)
    private var lockMethod = ASSettings.Settings.lockMethod.defaultValue
    @AppStorage(ASSettings.Settings.autoLockType.key)
    private var autoLockType = ASSettings.Settings.autoLockType.defaultValue
    @AppStorage(ASSettings.Settings.isShowingWeather.key)
    private var isShowingWeather = ASSettings.Settings.isShowingWeather.defaultValue
    @AppStorage(ASSettings.Settings.selectedWeatherType.key)
    private var selectedWeather = ASSettings.Settings.selectedWeatherType.defaultValue
    @AppStorage(ASSettings.Settings.walletBalance.key)
    private var walletBalance = ASSettings.Settings.walletBalance.defaultValue
    @AppStorage(ASSettings.Settings.acceptNewChatFromAnyOne.key)
    private var acceptNewChatFromAnyOne = ASSettings.Settings.acceptNewChatFromAnyOne.defaultValue
    @AppStorage(ASSettings.Settings.theme.key)
    private var theme = ASSettings.Settings.theme.defaultValue
    @AppStorage(ASSettings.Settings.hexFormat.key)
    private var hexFormat = ASSettings.Settings.hexFormat.defaultValue

    @ObservedObject private var lock = Lock.shared
    @ObservedObject private var walletInfo = WalletInfo.shared

    private var appLockEnable: Bool {
        Lock.shared.passcode != nil && lockMethod != ASSettings.LockMethod.none.rawValue
    }

    private let generator = UINotificationFeedbackGenerator()
}

// MARK: - Body view
extension SettingsView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.primaryBackground
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 0) {
                    settingTitle
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            userName
                            VStack(alignment: .leading, spacing: 0) {
                                sectionField(section: SettingsSection.backupAndRecovery)
                                sectionField(section: SettingsSection.appSecurity)
                                sectionField(section: SettingsSection.preference)
                                sectionField(section: SettingsSection.privacy)
                                sectionField(section: SettingsSection.advanced)
                                sectionField(section: SettingsSection.supportAndFeedback)
                                sectionField(section: SettingsSection.joinHarmonauts)
                            }
                            deleteDataButton
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 17)
                        .padding(.bottom, UIView.hasNotch ? 16 : 25)
                    }
                }
            }
            .hideNavigationBar()
        }
    }
}

// MARK: - Subview
extension SettingsView {
    private var settingTitle: some View {
        ZStack {
            HStack {
                Button(action: { onTapBack() }) {
                    Image.closeBackup
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 30)
                }
                Spacer()
            }
            Text("Settings")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color.white)
        }
        .padding(.vertical, 17)
        .padding(.horizontal, 16)
    }

    private var userName: some View {
        Button(action: {
            present(ProfileModal(wallet: walletInfo.currentWallet), presentationStyle: .fullScreen)
        }) {
            HStack(spacing: 15.5) {
                WalletAvatar(wallet: walletInfo.currentWallet, frame: CGSize(width: 60.5, height: 60.5))
                Text("@\(walletInfo.currentWallet.name ?? "")")
                    .font(.system(size: 17))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                Spacer(minLength: 15.5)
                Image.chevronRight
                    .resizable()
                    .frame(width: 8, height: 14)
                    .foregroundColor(Color.white)
            }
            .padding(.vertical, 18)
            .padding(.leading, 15.5)
            .padding(.trailing, 29)
            .frame(width: UIScreen.main.bounds.width - 32)
            .background(Color.formForeground)
            .cornerRadius(12)
        }
    }

    private func sectionField(section: SettingsSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle(section.title)
            VStack(spacing: 0) {
                settingsList(section.itemList)
                if !section.bottomText.isEmpty {
                    HStack(spacing: 0) {
                        Text(section.bottomText)
                            .font(.system(size: 12))
                            .foregroundColor(Color.white40)
                            .padding(.horizontal, 7)
                            .padding(.top, 10)
                        Spacer(minLength: 0)
                    }
                }
                if section == .joinHarmonauts {
                    VStack(spacing: 1.5) {
                        Text("Built for and by the Community \(Image.person3)")
                            .tracking(-0.2)
                            .font(.system(size: 14))
                            .foregroundColor(Color.white40)
                        Button(action: { onTapWithHarmonyGrant() }) {
                            Text("with \(Image.suitHeartFill) Harmony Grant")
                                .tracking(-0.2)
                                .font(.system(size: 14))
                                .foregroundColor(Color.white40)
                        }
                    }
                    .padding(.top, 34.5)
                    if let version = Bundle.main.appVersionShort,
                       let build = Bundle.main.bundleVersion {
                        Text("Version \(version) Build \(build)")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white40)
                            .padding(.top, 15.5)
                    }
                }
            }
            .padding(.bottom, section == .appSecurity ? (appLockEnable ? 24 : 0) : 0)
            if section == .appSecurity, appLockEnable {
                settingsList([.lockMethod, .autoLock]).padding(.bottom, 24)
                settingsList([.requireForTransaction])
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17))
            .foregroundColor(Color.white)
            .padding(.top, 34)
            .padding(.bottom, 15)
    }

    private func settingsList(_ items: [SettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0 ..< items.count) { index in
                if items[index].toggleValue {
                    toggleItem(items[index])
                } else {
                    buttonItem(items[index])
                }
                if index < items.count - 1 {
                    Rectangle()
                        .foregroundColor(Color.settingDivider)
                        .frame(height: 1)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width - 32)
        .background(Color.formForeground)
        .cornerRadius(12)
    }

    private func buttonItem(_ item: SettingsItem) -> some View {
        var title = ""
        switch item {
        case .lockMethod: title = ASSettings.LockMethod(rawValue: lockMethod)?.title ?? ""
        case .autoLock: title = ASSettings.AutoLockType(rawValue: autoLockType)?.title ?? ""
        case .currency: title = "USD" // TEMP
        case .theme: title = ASSettings.ThemeType(rawValue: theme)?.title ?? ""
        case .weather: title = isShowingWeather ? selectedWeather : "Set up"
        case .guardDog: title = " " // Space text to display chevron icon
        case .acceptNewChatsFrom: title = ASSettings.AcceptNewChatFromType(rawValue: acceptNewChatFromAnyOne)?.title ?? ""
        default: break
        }

        return Button(action: {
            switch item {
            case .googleAuthenticator: onTapGoogleAuthenticator()
            case .iCloudKeychain: onTapiCloudKeychain()
            case .lockMethod: onTapLockMethod()
            case .autoLock: onTapAutoLock()
            case .developerSettings: onTapDeveloperSettings()
            case .requestFeatures: onTapRequestFeatures()
            case .discord: onTapDiscord()
            case .telegram: onTapTelegram()
            case .twitter: onTapTwitter()
            case .theme: onTapTheme()
            case .weather: onTapWeather()
            case .guardDog: onTapGuardDog()
            case .acceptNewChatsFrom: onTapAcceptNewChatsFrom()
            case .upcomingHarmonyEvents: onUpcomingEventTap()
            default: break
            }
        }) {
            SettingItem(toggleValue: .constant(false),
                        selectedValueTitle: title,
                        item: item)
        }
    }

    private func toggleItem(_ item: SettingsItem) -> some View {
        SettingItem(
            toggleValue: Binding<Bool>.init(get: {
                switch item {
                case .appLock: return appLockEnable
                case .requireForTransaction: return requireForTransaction
                case .publicProfile: return publicProfile
                case .publicNFTExhibition: return publicNFTExhibition
                case .walletBalance: return walletBalance
                case .oneFormat: return !hexFormat
                default: return true
                }
            }, set: { value in
                switch item {
                case .appLock:
                    if Lock.shared.appLockEnable {
                        Lock.shared.requireAuthetication { isAuthenticated in
                            guard isAuthenticated else {
                                return
                            }
                            _ = Lock.shared.removePasscode()
                            lockMethod = ASSettings.LockMethod.none.rawValue
                        }
                    } else {
                        present(ChoosePasscodeView(), presentationStyle: .overFullScreen)
                    }
                case .requireForTransaction: requireForTransaction = value
                case .publicProfile: publicProfile = value
                case .publicNFTExhibition: publicNFTExhibition = value
                case .walletBalance: walletBalance = value
                case .oneFormat:
                    hexFormat = !value
                    WalletInfo.shared.generateWalletQRCode()
                default: break
                }
            }),
            item: item
        )
    }

    private var deleteDataButton: some View {
        Button(action: { onTapDeleteData() }) {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(Color.formForeground)
                .frame(height: 41)
                .padding(.horizontal, 27)
                .overlay(
                    Text("Delete All Data")
                        .foregroundColor(Color.timelessRed.opacity(0.87))
                        .font(.system(size: 17))
                )
        }
        .padding(.top, 24)
    }
}

// MARK: - Methods
extension SettingsView {
    private func onTapBack() {
        dismiss()
        pop()
    }

    private func onTapGoogleAuthenticator() {
        present(BackupGoogleAuthView(),
                presentationStyle: .overCurrentContext)
    }

    private func onTapiCloudKeychain() {
        present(BackupICloudView(),
                presentationStyle: .overCurrentContext)
    }
    private func onUpcomingEventTap() {
        present(UpComingEventView(shouldDismiss: .constant(true), isPopup: true).hideNavigationBar(),
                presentationStyle: .overFullScreen)
    }
    private func onTapTheme() { push(ThemeSettingsView().hideNavigationBar()) }
    private func onTapWeather() { push(WeatherSettingsView().hideNavigationBar()) }
    private func onTapGuardDog() { push(GuardDogSettingsView().hideNavigationBar()) }
    private func onTapAcceptNewChatsFrom() { push(AcceptChatSettingsView().hideNavigationBar()) }
    private func onTapLockMethod() { push(LockMethodView().hideNavigationBar()) }
    private func onTapAutoLock() { push(AutoLockView().hideNavigationBar()) }
    private func onTapDeveloperSettings() { push(DeveloperSettingsView().hideNavigationBar()) }
    private func onTapRequestFeatures() {
        // swiftlint:disable line_length
        MailObject.shared.sendMail(subject: "Feature Request (Timeless Wallet, iOS)",
                                   recipients: ["hello@timeless.space"],
                                   body: "Hi guys\n\nI’d love to see the following feature in the future release:\n\n\n—\nVersion: 1.0.1\nDevice: \(UIDevice.modelName) (\(UIDevice.current.systemVersion))",
                                   presentingVC: UIApplication.shared.topmostViewController)
    }
    private func onTapDiscord() { Utils.openURLinApp("https://harmony.one/discord") }
    private func onTapTelegram() { Utils.openURLinApp("https://harmony.one/telegram") }
    private func onTapTwitter() { Utils.openURLinApp("https://harmony.one/twitter") }
    private func onTapWithHarmonyGrant() { Utils.openURLinApp("https://open.harmony.one/300m-on-bounties-grants-daos") }
    private func onTapDeleteData() {
        generator.notificationOccurred(.success)
        showConfirmation(.deleteAllData)
    }

    private func onTapUser() {

    }
}

struct SettingsHeaderView: View {
    var title: String

    var body: some View {
        ZStack {
            HStack {
                Button(action: { pop() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: .infinity)
                            .foregroundColor(Color.xmarkBackground)
                            .frame(width: 30, height: 30)
                        Image.chevronLeft
                            .resizable()
                            .frame(width: 10, height: 16)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.white)
                            .offset(x: -2)
                    }
                }
                Spacer()
            }
            .padding(.leading, 19)
            Text(title)
                .tracking(-0.2)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.white)
        }
        .padding(.top, 7)
        .padding(.bottom, 10)
        .background(Color.primaryBackground)
    }
}
