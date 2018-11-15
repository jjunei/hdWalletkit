Pod::Spec.new do |s|
  s.name             = 'iOSHDWalletKit'
  s.version          = '0.0.1'
  s.summary          = 'Hierarchical Deterministic(HD) wallet for cryptocurrencies'

  s.description      = <<-DESC
      WalletKit is a Swift framwork that enables you to create and use bitcoin HD wallet([Hierarchical Deterministic Wallets](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)) in your own app.
                       DESC

  s.homepage         = 'https://github.com/kgthtj/iOSHDWallet.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'JJUNE' => 'kgthtj@gmail.com' }
  s.source           = { :git => 'https://github.com/kgthtj/iOSHDWallet.git', :tag => s.version.to_s }

  s.platform     = :ios, "10.0"
  s.swift_version= '4'
  s.static_framework  = true

  s.ios.deployment_target = '8.0'

  s.module_name   = "iOSHDWalletKit"
  s.source_files = 'iOSHDWalletKit/**/*.{swift}'

  s.dependency 'secp256k1.swift', '~> 0.1.4'
  s.dependency 'CryptoSwift', '~> 0.10.0'
  
end
