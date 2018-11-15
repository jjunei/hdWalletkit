//
//  AddressFactory.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation

public enum AddressError: Error {
    case invalid
    case invalidScheme
    case invalidVersionByte
}

public struct AddressFactory {
    public static func create(_ plainAddress: String) throws -> Address {
        do {
            return try Cashaddr(plainAddress)
        } catch AddressError.invalidVersionByte {
            throw AddressError.invalidVersionByte
        } catch AddressError.invalidScheme {
            throw AddressError.invalidScheme
        } catch AddressError.invalid {
            return try LegacyAddress(plainAddress)
        }
    }
}

public protocol Address {
    var base58: String { get }
    var cashaddr: String { get }
    var data: Data { get }
}

public struct LegacyAddress: Address {
    public let base58: Base58Check
    public let cashaddr: String
    public let data: Data
    public typealias Base58Check = String
    
    public init(_ base58: Base58Check) throws {
        guard let raw = Encoding.decode(base58) else {
            throw AddressError.invalid
        }
        let checksum = raw.suffix(4)
        let pubKeyHash = raw.dropLast(4)
        let checksumConfirm = pubKeyHash.doubleSHA256.prefix(4)
        guard checksum == checksumConfirm else {
            throw AddressError.invalid
        }
        
        let addressPrefix = pubKeyHash[0]
        if addressPrefix != Coin.bitcoinCash.publicKeyHash[0] {
            throw AddressError.invalidVersionByte
        }
        
        self.data = pubKeyHash.dropFirst()
        self.base58 = base58
        let payload = Data([0]) + pubKeyHash.dropFirst()
        self.cashaddr = Bech32.encode(payload, prefix: Coin.bitcoinCash.addressPrefix)
    }
}

extension LegacyAddress: CustomStringConvertible {
    public var description: String {
        return base58
    }
}

public struct Cashaddr: Address {
    public let base58: String
    public let cashaddr: CashaddrWithScheme
    public let data: Data
    
    public typealias CashaddrWithScheme = String
    
    public init(_ cashaddr: CashaddrWithScheme) throws {
        guard let decoded = Bech32.decode(cashaddr) else {
            throw AddressError.invalid
        }
        let (prefix, raw) = (decoded.prefix, decoded.data)
        self.cashaddr = cashaddr
        if Coin.bitcoinCash.addressPrefix != prefix {
            throw AddressError.invalidScheme
        }
        let versionByte = raw[0]
        let hash = raw.dropFirst()
        guard hash.count == VersionByte.getSize(from: versionByte) else {
            throw AddressError.invalidVersionByte
        }
        self.data = hash
        self.base58 = publicKeyHashToAddress(Data(Coin.bitcoinCash.publicKeyHash) + hash)
    }
}

extension Cashaddr: CustomStringConvertible {
    public var description: String {
        return cashaddr
    }
}

func publicKeyHashToAddress(_ hash: Data) -> String {
    let checksum = hash.doubleSHA256.prefix(4)
    let address = Base58.encode(hash + checksum)
    return address
}
