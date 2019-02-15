//
//  PublicKey.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation
import CryptoSwift

public struct PublicKey {
    public let rawCompressed: Data
    public let rawNotCompressed: Data
    public let chainCode: Data
    public let depth: UInt8
    public let fingerprint: UInt32
    public let index: UInt32
    public let coin: Coin
    
    public var pubkeyHash: Data {
        return Crypto.sha256ripemd160(rawCompressed)
    }
    
    init(privateKey: PrivateKey, chainCode: Data, coin: Coin, depth: UInt8, fingerprint: UInt32, index: UInt32) {
        self.rawNotCompressed = Crypto.generatePublicKey(data: privateKey.raw, compressed: false)
        self.rawCompressed = Crypto.generatePublicKey(data: privateKey.raw, compressed: true)
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.index = index
        self.coin = coin
    }
    
    init(data: Data) {
        self.rawCompressed = data
        self.rawNotCompressed = Data()
        self.chainCode = Data()
        self.depth = 0
        self.fingerprint = 0
        self.index = 0
        self.coin = Coin.eos
    }
    
    // NOTE: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
    public var address: String {
        switch self.coin {
        case .bitcoinCash:
            return generateBchAddress()
        case .ethereum: fallthrough
        case .ethereumclassic:
            return generateEthAddress()
        case .eos:
            return generateEosAddress()
        case .tron:
            return generateTrxAddress()
        default :
            return generateCompressedAddress()
        }
    }
    
    private func generateEosAddress() -> String {
        let checksum = RIPEMD160.hash(rawCompressed).prefix(4)
        return coin.addressPrefix + Base58.encode(rawCompressed + checksum)
    }
        
    private func generateBchAddress() -> String {
        let versionByte: Data = Data([0])
        return Bech32.encode(versionByte + pubkeyHash, prefix: coin.addressPrefix)
    }
    
    private func generateBchLegacyAddress() -> String {
        let versionByte: Data = Data(coin.publicKeyHash)
        return publicKeyHashToAddress(versionByte + pubkeyHash)
    }
        
    func generateCompressedAddress() -> String {
        let prefix = Data(coin.publicKeyHash)
        let payload = pubkeyHash
        let checksum = (prefix + payload).doubleSHA256.prefix(4)
        return Base58.encode(prefix + payload + checksum)
    }
    
    func generateTrxAddress() -> String {
        let prefix = Data(coin.publicKeyHash)
        let formattedData = rawNotCompressed.dropFirst()
        let addressData = Crypto.sha3keccak256(data: formattedData).suffix(20)
        let checksum = (prefix + addressData).doubleSHA256.prefix(4)
        return Base58.encode(prefix + addressData + checksum)
    }
    
    func generateEthAddress() -> String {
        let formattedData = (Data(hex: coin.addressPrefix) + rawNotCompressed).dropFirst()
        let addressData = Crypto.sha3keccak256(data: formattedData).suffix(20)
        return coin.addressPrefix + EIP55.encode(addressData)
    }
    
    public var extended: String {
        var extendedPublicKeyData = Data()
        extendedPublicKeyData += coin.publicKeyVersion.bigEndian
        extendedPublicKeyData += depth.littleEndian
        extendedPublicKeyData += fingerprint.littleEndian
        extendedPublicKeyData += index.littleEndian
        extendedPublicKeyData += chainCode
        extendedPublicKeyData += rawCompressed
        let checksum = extendedPublicKeyData.doubleSHA256.prefix(4)
        return Base58.encode(extendedPublicKeyData + checksum)
    }
    
    public func get() -> String {
        return self.rawCompressed.toHexString()
    }
    
    func equals(_ other: Any?)->Bool{
        if let o = other as? PublicKey {
            return EcTools.shared.areEqual([UInt8](self.rawCompressed), [UInt8](o.rawCompressed))
        }
        return false;
    }
}

extension Data {
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to: &number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }
}
