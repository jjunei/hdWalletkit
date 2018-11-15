//
//  HexUtils.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation

class HexUtils {

    static let shared = HexUtils()
    private init() {}
    
    func toHex(bytes: [UInt8]) -> String{
        return toHex(bytes: bytes, separator: nil)
    }
    
    func toHex(bytes: [UInt8],
               separator: String?) -> String{
        return toHex(bytes: bytes,
                     offset: 0,
                     length: bytes.count,
                     separator: separator)
    }
    
    func toHex(bytes: [UInt8],
               offset: Int,
               length: Int) -> String{
        return toHex(bytes: bytes,
                     offset: offset,
                     length: length,
                     separator: nil)
    }
    
    func toHex(b: UInt8)-> String{
        return appendByteAsHex(b)
    }
    
    
    func appendByteAsHex(_ b: UInt8) -> String{
        var result = "";
        let unsignedByte = UInt(b) & 0xFF;
        if (unsignedByte < 16) {
            result = "\(result)0"
        }
        result = "\(result)\(String(unsignedByte, radix: 16, uppercase: false))"
        return result
    }
    
    func toHex(bytes: [UInt8],
               offset: Int,
               length: Int,
               separator: String?) -> String{
        var result = ""
        for i in 0..<length {
            let unsignedByte: UInt = UInt(bytes[i+offset]) & 0xff
            if (unsignedByte < 16) {
                result = "\(result)0"
            }
            
            result = "\(result)\(String(unsignedByte, radix: 16, uppercase: false))"
            if let sep = separator,
                (i + 1) < length {
                result = "\(result)\(sep)"
            }
        }
        return result
    }
    
    func toBytes(hexString: String?) -> [UInt8]? {
        if let hex = hexString,
            hex.count % 2 == 0 {
            var hexs = Array(hex)
            let length = hexs.count / 2;
            var raw: [UInt8] = []
            for i in 0..<length {
                if let high = Int(String(hexs[i * 2]), radix: 16),
                    let low = Int(String(hexs[i * 2 + 1]), radix: 16),
                    high >= 0,
                    low >= 0 {
                    let value = (high << 4) | low
                    raw.append(UInt8(value))
                }else{
                    return nil
                }
            }
            return raw
        }
        return nil
    }
    
    func toBytesReversed(hexString: String) -> [UInt8]? {
        if let rawBytes = toBytes(hexString: hexString){
            var bytes = rawBytes
            for i in 0..<bytes.count{
                let temp = bytes[bytes.count - i - 1]
                bytes[bytes.count - i - 1 ] = bytes[i]
                bytes[i] = temp
            }
            return bytes
        }
        return nil
    }
    
    func toHex(_ bytes: [UInt8]) -> String {
        return self.toHex(bytes, nil)
    }
    
    func toHex(_ bytes: [UInt8],
               _ separator: String?) -> String {
        return self.toHex(bytes, 0, bytes.count, separator)
    }
    
    func toHex(_ bytes: [UInt8],
               _ offset: Int,
               _ length: Int,
               _ separator: String?) -> String {
        var result = ""
        for i in 0..<length {
            let unsignedByte = bytes[i+offset] & 0xff
            if unsignedByte < 16 {
                result = "\(result)0"
            }
            result = "\(result)\(String(unsignedByte, radix: 16))"
            if let s = separator,
                (i + 1) < length{
                result = "\(result)\(s)"
            }
        }
        return result;
    }
    
    
}
