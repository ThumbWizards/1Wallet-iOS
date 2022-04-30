# 1WALLET
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS-blue)](https://developer.apple.com/ios/)

> A non-custodial social wallet for all your web3 journey! Sending crypto is now as easy as sending a message.
>
> 📲️ App Store — Coming soon
>
> 🤖 Play Store — Sign up for Android [Fishfood](https://timeless-space.typeform.com/wallet-waitlist?typeform-source=repo) (pre-alpha)
>
> 🎮 Join the [Discord](https://discord.gg/1wallet) community
>
> 🐦️ Follow us on [Twitter](https://mobile.twitter.com/1walletxyz)


# Quick Start

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
- iOS 15.0+
- Xcode 13.0+
- [CocoaPods](http://cocoapods.org/)
- [Swift Package Manager](https://www.swift.org/package-manager/)

### Swift Style Guide
Code follows [Swift standard library](https://google.github.io/swift/) style guide.
Project uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions before sending a pull request.

### Dependencies
- [Swiftlint](https://github.com/realm/SwiftLint#installation)

    ```sh
    brew install swiftlint
    ```

- [cocoapods-keys](https://github.com/orta/cocoapods-keys#installation)

    ```sh
    gem install cocoapods-keys
    ```

## How to setup project?

1. Clone this repository into a location of your choosing, like your projects folder

2. Open terminal - > Navigate to  the directory containing ``Podfile``

3. Setup Environment Variables

- Set up your .env file, use our env.example as a guide.

NOTE: Certain features (e.g., chat) are currently not accessible while we work with the third-party to provide open source API Keys.

- Resources to generate your own API keys:
  - Weather: [https://openweathermap.org/api](https://openweathermap.org/api)
  - Chat: [https://getstream.io/chat/](https://getstream.io/chat/)
  - Giphy: [https://developers.giphy.com](https://developers.giphy.com)
  - Sticker: [https://developers.stipop.io](https://developers.stipop.io)
  - Fiat-onramp: [https://www.simplex.com/partners](https://www.simplex.com/partners)

4. Setup Firebase configuration.

- Download the GoogleService-Info.plist file from your Firebase Console for debug and release and copy ``GoogleService-Info-debug.plist`` and ``GoogleService-Info-release.plist`` in ``Timeless-wallet/`` folder. This will connect the app to your own Firebase instance.

5. Then install pods into your project by typing in terminal: ```pod install```

6. Once completed, there will be a message that says`"Pod installation complete! There are X dependencies from the Podfile and X total pods installed."`

7. Voila! You are all set now. Open the .xcworkspace file from now on and hit Xcode's 'run' button.  🚀

### Architecture
The project uses SwiftUI+Combine framework with [MVVM architecture](Project-Architecture.md).

### Contributing
There's little supporting documentation yet; as such, we're not yet accepting contributions to the code. This will happen later. We hope to nurture a robust, community-driven active open-source project eventually, but for now the focus of the product team is to bring about delightful product and features to the community for feedback and validation as soon as we can. In the meantime, we’ll update the code periodically to match what’s running on beta.  
