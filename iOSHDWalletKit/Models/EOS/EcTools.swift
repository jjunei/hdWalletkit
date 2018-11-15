//
//  EcTools.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import BigInt

class EcTools {
    static let shared = EcTools()
    private init() {}
    
    private var sCurveParams: [CurveParam?] = Array<CurveParam?>(repeating: nil, count: 2)

    func getByteLength(_ fieldSize: Int) -> Int{
        return (fieldSize + 7) / 8
    }
    
    func integerToBytes(_ s: BigInt,
                        length: Int) -> [UInt8] {
        let bi: BigInt = BigInt(s)
        let temp0 = BigUInt(bi)
        let temp1 = temp0.serialize();
        let bytes = Array(temp1)
        
        var tmp = Array<UInt8>(repeating: 0,
                               count: length)
        if (length < bytes.count) {
            tmp = EcTools.shared.arrayCopy(src: bytes,
                                           srcPos: (bytes.count - tmp.count),
                                           dest: tmp,
                                           destPos: 0,
                                           length: tmp.count)
            return tmp
        }else if (length > bytes.count) {
            tmp = EcTools.shared.arrayCopy(src: bytes,
                                           srcPos: 0,
                                           dest: tmp,
                                           destPos: tmp.count - bytes.count,
                                           length: bytes.count)
            return tmp
        }
        return bytes
    }
    
    func multiply(_ p: EcPoint,
                  _ k: BigInt) -> EcPoint{
        let e = k
        let h = e.multiply(BigInt(3))
        
        let neg = p.negate()
        var R = p
        
        var index = (h.bitLength() - 1)
        
        while index > 1{
            index = index - 1
            R = R.twice()!
            let hBit = h.testBit(index)
            let eBit = e.testBit(index)
            if (hBit != eBit){
                R = R.add(hBit ? p : neg)!
            }
        }
        return R
    }
    
    func getCurveParam(curveType: Int ) -> CurveParam? {
        if curveType < 0 ||
            self.sCurveParams.count < curveType {
            return nil
        }

        if ( self.sCurveParams[curveType] == nil ) {
            if (CurveParam.SECP256_K1 == curveType) {
                sCurveParams[CurveParam.SECP256_K1] =
                    CurveParam(
                        curveParamType: CurveParam.SECP256_K1,
                        pInHex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F",
                        aInHex: "0" ,
                        bInHex: "7",
                        GxInHex: "79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",
                        GyInHex: "483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8",
                        nInHex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
            }else if (CurveParam.SECP256_R1 == curveType){
                sCurveParams[CurveParam.SECP256_R1] =
                    CurveParam(
                        curveParamType: CurveParam.SECP256_R1,
                        pInHex: "ffffffff00000001000000000000000000000000ffffffffffffffffffffffff",
                        aInHex: "ffffffff00000001000000000000000000000000fffffffffffffffffffffffc",
                        bInHex: "5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b",
                        GxInHex: "6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296",
                        GyInHex: "4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5",
                        nInHex: "ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551")
            }
        }
        return self.sCurveParams[curveType]
    }
    
    func decompressKey(param: CurveParam,
                       x: BigInt,
                       firstBit: Bool) -> EcPoint? {
        if let fieldSize = param.getCurve()?.getFieldSize() {
            let size = 1 + getByteLength(fieldSize)
            var dest = integerToBytes(x, length: size)
            dest[0] = firstBit ? 0x03 : 0x02
            return param.getCurve()?.decodePoint(dest)
        }
        return nil
    }
    
    func sumOfTwoMultiplies(P: EcPoint,
                            k: BigInt,
                            Q: EcPoint,
                            l: BigInt) -> EcPoint? {
        let m = max(k.bitLength(), l.bitLength())
        if let Z = P.add(Q),
            let tempR = (P.getCurve()._infinity){
            var R: EcPoint? = tempR
            var index = m - 1
            while index >= 0{
                R = R?.twice()
                if k.testBit(index) {
                    if l.testBit(index) {
                        R = R?.add(Z)
                    }else{
                        R = R?.add(P)
                    }
                } else {
                    if l.testBit(index) {
                        R = R?.add(Q)
                    }
                }
                index = index - 1
            }
            return R
        }
        return nil
    }
    
    func arrayCopy(src: [UInt8],
                   srcPos: Int,
                   dest: [UInt8],
                   destPos: Int,
                   length: Int) -> [UInt8] {
        
        var result = dest;
        
        
        var index = destPos
        
        for i in srcPos ..< (length + srcPos) {
            result[index] = src[i]
            index = index + 1
        }
        
        return result
    }
    
    func arrayCopy(src: [UInt8],
                   srcPos: Int,
                   destLenght: Int,
                   destPos: Int,
                   length: Int)->[UInt8] {
        var result = Array<UInt8>(repeating: 0, count: destLenght)
        var index = destPos
        for i in srcPos ..< (length + srcPos){
            result[index] = src[i]
            index = index + 1
        }
        return result
    }
    
    func copyOfRange(_ src: [UInt8],
                     _ start: Int,
                     _ end: Int) -> [UInt8] {
        return Array(src[start..<end])
    }
    
    func uint16ToLong(buf: [Int8],
                      offset: Int) -> Int {
        return ((Int(buf[offset]) & 0xFF)) |
            ((Int(buf[offset + 1]) & 0xFF) << 8)
    }
    
    func uint32ToLong(buf: [UInt8],
                      offset: Int) -> Int {
        return ((Int(buf[offset]) & 0xFF)) |
            ((Int(buf[offset + 1]) & 0xFF) << 8) |
            ((Int(buf[offset + 2]) & 0xFF) << 16) |
            ((Int(buf[offset + 3]) & 0xFF) << 24)
    }
    
    func areEqual(_ a: [UInt8]?,
                  _ b: [UInt8]?)->Bool{
        if a == nil &&
            b == nil {
            return true;
        }
        if a == nil ||
            b == nil {
            return false;
        }
        if let a0 = a,
            let b0 = b{
            if a0.count != b0.count {
                return false;
            }
            for i in 0..<a0.count{
                if (a0[i] != b0[i]) {
                    return false;
                }
            }
        }
        return true;
    }
}
