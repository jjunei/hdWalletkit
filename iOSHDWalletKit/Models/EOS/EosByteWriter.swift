//
//  EosByteWriter.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import BigInt

class EosByteWriter {
    var _buf: [UInt8]
    var _index: Int
    
    init(capacity: Int) {
        self._buf = Array<UInt8>(repeating: 0, count: capacity)
        self._index = 0
    }
    
    init(buf: [UInt8]) {
        self._buf = buf
        self._index = buf.count
    }
    
    func ensureCapacity(capacity: Int) {
        if (self._buf.count - self._index) < capacity{
            var temp = Array<UInt8>(repeating: 0, count: _buf.count * 2 + capacity)
            temp = EcTools.shared.arrayCopy(src: _buf,
                                            srcPos: 0,
                                            dest: temp,
                                            destPos: 0,
                                            length: self._index)
            self._buf = temp
        }
    }
    
    func put(b: UInt8){
        ensureCapacity(capacity: 1)
        self._buf[self._index] = b
        self._index = self._index + 1
    }
    
    func putShortLE(value: Int64) {
        ensureCapacity(capacity: 2)
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value)))
        self._index = self._index + 1
        
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 8)))
        self._index = self._index + 1
    }
    
    func putIntLE(value: Int64) {
        ensureCapacity(capacity: 4)
        _buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value)))
        self._index = self._index + 1
        
        _buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 8)))
        self._index = self._index + 1
        
        _buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 16)))
        self._index = self._index + 1
        
        _buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 24)))
        self._index = self._index + 1
    }
    
    func putLongLE(value: Int64) {
        ensureCapacity(capacity: 8)
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value)))
        self._index = self._index + 1
        
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 8)))
        self._index = self._index + 1
        
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 16)))
        self._index = self._index + 1
        
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 24)))
        self._index = self._index + 1
        
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 32)))
        self._index = self._index + 1
        
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 40)))
        self._index = self._index + 1
        
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 48)))
        self._index = self._index + 1
        
        self._buf[_index] = (0xFF & UInt8(truncating: NSNumber(value: value >> 56)))
        self._index = self._index + 1
    }
    
    func putBytes(value: [UInt8]) {
        ensureCapacity(capacity: value.count)
        self._buf = EcTools.shared.arrayCopy(src: value,
                                             srcPos: 0,
                                             dest: self._buf,
                                             destPos: self._index,
                                             length: value.count)
        self._index = self._index + value.count
    }
    
    func toBytes() -> [UInt8] {
        return Array(self._buf[0..<self._index])
    }
    
    func length() -> Int {
        return self._index
    }
    
    func putString(value: String?) {
        if let val = value {
            putVariableUInt(val: val.count)
            putBytes(value: val.bytes)
            return
        } else {
            putVariableUInt(val: 0)
        }
    }
    
    func putVariableUInt(val: Int) {
        var value = val
        var index = 0;
        repeat {
            var b: UInt8 = (UInt8(truncating: NSNumber(value: value)) & 0x7f)
            value >>= 7
            b |= (((value > 0) ? 1 : 0) << 7)
            put(b: b)
            index = index + 1;
            
        }while value != 0
    }
}
