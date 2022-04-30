# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

target 'Timeless-wallet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # ignore all warnings from all pods
  inhibit_all_warnings!

  source 'https://cdn.cocoapods.org/'                      # CocoaPods master repo
  # Pods for Timeless-wallet
  pod 'Sentry', '7.12.0'
  pod 'Firebase/Analytics', '8.8.0'
  pod 'Firebase/DynamicLinks', '8.8.0'
  pod 'Kingfisher', '7.2.0'
  pod 'Introspect', '0.1.3'
  pod 'swiftScan', '1.2.1'
  pod 'EFQRCode', '6.2.0'
  pod 'SwiftLint', '0.44.0'
  pod 'SwiftOTP', '3.0.0'
  pod 'SwiftProtobuf', '1.18.0'
  pod 'FilesProvider', '0.26.0'
  pod 'TimelessWeather', :git => 'https://bitbucket.org/teamtimeless/timelessweather/', :branch => 'master'
  pod 'Navajo-Swift', '2.1.0'
  pod 'CollectionViewPagingLayout', :git => 'https://github.com/timeless-space/CollectionViewPagingLayout', :commit => 'bc5d1a26675d58f358bed8f52518caa9862a91f4'
  pod 'YouTubePlayer', '0.7.2'
  pod 'GetStream', '~> 2.0'
  pod 'StreamChat', :git => 'https://github.com/timeless-space/stream-chat-swift.git', :branch => 'develop'
  pod 'StreamChatUI', :git => 'https://github.com/timeless-space/stream-chat-swift.git', :branch => 'develop'
  pod 'SwiftMessages', '9.0.5'
  pod 'web3swift', :git => 'https://github.com/skywinder/web3swift.git', :branch => 'develop'
  pod 'Cloudinary', '~> 3.0'
  pod 'RHLinePlot', '~> 0.1.0'
  pod 'Atributika', '4.10.1'
  pod 'ASCollectionView-SwiftUI', '2.1.1'
  pod 'EllipticCurveKeyPair', :git => 'https://github.com/agens-no/EllipticCurveKeyPair', :branch => 'master'
  pod 'GRDB.swift', '5.23.0'

  plugin 'cocoapods-keys', {
      :project => "Timeless-wallet",
      :keys => [
      "GiphyAPIKey",
      "StipopAPIKey",
      "FirebaseProfileFallBackUrl",
      "FirebaseFallBackUrl",
      "FirebaseAppStoreID",
      "FirebaseDynamicLinkDomain",
      "FirebaseDynamicLinkBaseURL",
      "GetStreamAppId",
      "RpcTestNetUrl",
      "RpcMainNetUrl",
      "OneWalletServiceUrl",
      "GetStreamAPIKey",
      "OpenWeatherApiKey",
      "SimplexApiKey",
      "ServerURL"
      ]
  }

  target 'Timeless-walletTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Timeless-walletUITests' do
    # Pods for testing
  end

end
