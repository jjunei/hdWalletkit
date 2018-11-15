//
//  Script.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation

public struct VarInt: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt64
    public let underlyingValue: UInt64
    let length: UInt8
    let data: Data
    
    public init(integerLiteral value: UInt64) {
        self.init(value)
    }
    
    public init(_ value: UInt64) {
        underlyingValue = value
        
        switch value {
        case 0...252:
            length = 1
            data = Data() + UInt8(value).littleEndian
        case 253...0xffff:
            length = 2
            data = Data() + UInt8(0xfd).littleEndian + UInt16(value).littleEndian
        case 0x10000...0xffffffff:
            length = 4
            data = Data() + UInt8(0xfe).littleEndian + UInt32(value).littleEndian
        case 0x100000000...0xffffffffffffffff:
            fallthrough
        default:
            length = 8
            data = Data() + UInt8(0xff).littleEndian + UInt64(value).littleEndian
        }
    }
    
    public init(_ value: Int) {
        self.init(UInt64(value))
    }
    
    public func serialized() -> Data {
        return data
    }
    
    public static func deserialize(_ data: Data) -> VarInt {
        return data.to(type: self)
    }
}

extension VarInt: CustomStringConvertible {
    public var description: String {
        return "\(underlyingValue)"
    }
}

public protocol OpCodeProtocol {
    var name: String { get }
    var value: UInt8 { get }
}

public struct OpDuplicate: OpCodeProtocol {
    public var value: UInt8 { return 0x76 }
    public var name: String { return "OP_DUP" }
}

public struct OpHash160: OpCodeProtocol {
    public var value: UInt8 { return 0xa9 }
    public var name: String { return "OP_HASH160" }
}

public struct OpEqualVerify: OpCodeProtocol {
    public var value: UInt8 { return 0x88 }
    public var name: String { return "OP_EQUALVERIFY" }
}

public struct OpCheckSig: OpCodeProtocol {
    public var value: UInt8 { return 0xac }
    public var name: String { return "OP_CHECKSIG" }
}

public class Script {
    public static func buildPublicKeyHashOut(pubKeyHash: Data) -> Data {
        let count: UInt8  = UInt8(pubKeyHash.count)
        let tmp: Data = Data() + OpDuplicate() + OpHash160() + count + pubKeyHash + OpEqualVerify()
        return tmp + OpCheckSig()
    }
    
    public static func buildPublicKeyUnlockingScript(signature: Data, pubkey: PublicKey, hashType: SighashType) -> Data {
        var data: Data = Data([UInt8(signature.count + 1)]) + signature + UInt8(hashType)
        data += VarInt(pubkey.rawCompressed.count).serialized()
        data += pubkey.rawCompressed
        return data
    }
}
