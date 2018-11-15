//
//  Coin.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation

public enum Coin {
    case bitcoin
    case bitcointest
    case litecoin
    case dogecoin
    case dash
    case ethereum
    case ethereumclassic
    case zcash
    case ripple
    case bitcoinCash
    case eos
    
    public var privateKeyVersion: UInt32 {
        switch self {
        case .bitcointest:
            return 0x04358394
        case .litecoin:
            return 0x019D9CFE
        case .dogecoin:
            return 0x02fac398
        default:
            return 0x0488ADE4
        }
    }
    
    public var publicKeyVersion: UInt32 {
        switch self {
        case .bitcointest:
            return 0x043587CF
        case .litecoin:
            return 0x019DA462
        case .dogecoin:
            return 0x02facafd
        default:
            return 0x0488B21E
        }
    }
    
    public var publicKeyHash: [UInt8] {
        switch self {
        case .bitcointest:
            return [0x6f]
        case .litecoin:
            return [0x30]
        case .dogecoin:
            return [0x1E]
        case .dash:
            return [0x4C]
        case .zcash:
            return [0x1C,0xB8]
        case .ripple:
            return [0x74]
        default:
            return [0x00]
        }
    }
    
    public var wifPreifx: UInt8 {
        switch self {
        case .bitcointest:
            return 0xEF
        case .litecoin:
            return 0xB0
        case .dogecoin:
            return 0x9E
        case .dash:
            return 0xCC
        default:
            return 0x80
        }
    }
    
    public var addressPrefix:String {
        switch self {
        case .ethereum: fallthrough
        case .ethereumclassic:
            return "0x"
        case .eos:
            return "EOS"
        case .bitcoinCash:
            return "bitcoincash"
        default:
            return ""
        }
    }
    
    
    public var coinType: UInt32 {
        switch self {
        case .bitcoin:
            return 0
        case .bitcointest:
            return 1
        case .litecoin:
            return 2
        case .dogecoin:
            return 3
        case .dash:
            return 5
        case .ethereum:
            return 60
        case .ethereumclassic:
            return 61
        case .zcash:
            return 133
        case .ripple:
            return 144
        case .bitcoinCash:
            return 145
        case .eos:
            return 60
        }
    }
}
