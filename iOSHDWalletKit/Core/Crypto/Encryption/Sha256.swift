//
//  Sha256.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import CryptoSwift

class Sha256{
    static let HASH_LENGTH: Int = 32
    static let ZERO_HASH: Sha256 = Sha256(bytes: Array<UInt8>(repeating: 0,
                                                              count: HASH_LENGTH))
    let mHashBytes: [UInt8]?
    
    init(bytes: [UInt8]) {
        if bytes.count == Sha256.HASH_LENGTH {
            self.mHashBytes = bytes
        } else {
            self.mHashBytes = nil
        }
    }
    
    class func from(data: [UInt8]) -> Sha256? {
        do {
            var digest0 = SHA2(variant: .sha256)
            try digest0.update(withBytes: data)
            let result = try digest0.finish()
            return Sha256(bytes: result)
        } catch { }
        return nil
        
    }
    
    class func from(byte1: [UInt8],
                    byte2: [UInt8]) -> Sha256? {
        do {
            var digest = SHA2(variant: .sha256)
            try digest.update(withBytes: byte1)
            try digest.update(withBytes: byte2)
            let result = try digest.finish()
            return Sha256(bytes: result)
        } catch { }
        return nil
    }
    
    class func from(data: [UInt8],
                    offset: Int,
                    length: Int) -> Sha256? {
        do {
            let bytes = EcTools.shared.arrayCopy(src: data,
                                                 srcPos: offset,
                                                 destLenght: length,
                                                 destPos: 0,
                                                 length: length)
            var digest = SHA2(variant: .sha256)
            try digest.update(withBytes: bytes)
            let result = try digest.finish()
            return Sha256(bytes: result)
        } catch { }
        return nil
    }
    
    class func doubleHash(data: [UInt8],
                          offset: Int,
                          length: Int) -> Sha256? {
        do {
            let bytes = EcTools.shared.arrayCopy(src: data,
                                                 srcPos: offset,
                                                 destLenght: length,
                                                 destPos: 0,
                                                 length: length)
            var digest = SHA2(variant: .sha256)
            try digest.update(withBytes: bytes)
            let result = try digest.finish()
            if let temp = Sha256(bytes: result).getBytes(){
                var digest2 = SHA2(variant: .sha256)
                try digest2.update(withBytes: temp)
                let result2 = try digest2.finish()
                return Sha256(bytes: result2)
            }
        } catch { }
        return nil
    }
    
    func toString() -> String? {
        if let bytes = self.mHashBytes{
            return HexUtils.shared.toHex(bytes: bytes)
        }
        return nil
    }
    
    func getBytes() -> [UInt8]? {
        return self.mHashBytes
    }
    
    
    func equalsFromOffset(_ toCompareData: [UInt8]?,
                          _ offsetInCompareData: Int,
                          _ len: Int ) -> Bool {
        if let data = toCompareData,
            let bytes = mHashBytes {
            if ((offsetInCompareData < 0) ||
                (len < 0) ||
                (bytes.count <= len) ||
                (data.count <= offsetInCompareData) ){
                return false
            }
            for i in 0..<len {
                if bytes[i] != data[ offsetInCompareData + i] {
                    return false
                }
            }
            return true
        }
        return false
    }
}
