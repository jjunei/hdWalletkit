//
//  EcCurve.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import BigInt

class EcCurve {
    let _q: BigInt
    
    var _a: EcFieldElement?
    var _b: EcFieldElement?
    var _infinity: EcPoint?
    
    init(q: BigInt,
         a: BigInt,
         b: BigInt) {
        self._q = q
        self._a = fromBigInteger(a)
        self._b = fromBigInteger(b)
        self._infinity = EcPoint(curve: self,
                                 x: nil,
                                 y: nil)
    }
    
    func getFieldSize() -> Int {
        return _q.bitLength()
    }
    
    func fromBigInteger(_ x: BigInt) -> EcFieldElement {
        return EcFieldElement(q: _q, x: x)
    }
    
    func decodePoint(_ encodedPoint: [UInt8]) -> EcPoint? {
        var p: EcPoint?
        switch encodedPoint[0] {
        case 0x00:
            p = self._infinity
            break;
        case 0x02, 0x03:
            if let a = self._a,
                let b = self._b {
                let ytilde = encodedPoint[0] & 1
                var i: [UInt8] = Array<UInt8>(repeating: 0, count: encodedPoint.count - 1)
                i = EcTools.shared.arrayCopy(src: encodedPoint,
                                             srcPos: 1,
                                             dest: i,
                                             destPos: 0,
                                             length: i.count)
                let x = EcFieldElement(q: self._q,
                                       x: BigInt(sign: .plus,
                                                 magnitude: BigUInt(Data(bytes: i))))
                let alpha = x.multiply(b: x.square().add(b: a)).add(b: b)
                if let beta = alpha.sqrt() {
                    let bit0 = beta.toBigInteger().testBit(0) ?  1 : 0
                    if (bit0 == ytilde) {
                        p = EcPoint(curve: self,
                                    x: x,
                                    y: beta,
                                    compressed: true)
                    } else {
                        p = EcPoint(curve: self,
                                    x: x,
                                    y: EcFieldElement(q: self._q,
                                                      x: self._q.subtract(beta.toBigInteger())),
                                    compressed: true)
                    }
                }
            }
            break
        case 0x04, 0x06, 0x07:
            var xEnc = Array<UInt8>(repeating: 0, count: (encodedPoint.count - 1) / 2)
            var yEnc = Array<UInt8>(repeating: 0, count: (encodedPoint.count - 1) / 2)
            
            xEnc = EcTools.shared.arrayCopy(src: encodedPoint,
                                            srcPos: 1,
                                            dest: xEnc,
                                            destPos: 0,
                                            length: xEnc.count)
            
            yEnc = EcTools.shared.arrayCopy(src: encodedPoint,
                                            srcPos: xEnc.count + 1,
                                            dest: yEnc,
                                            destPos: 0,
                                            length: yEnc.count)
            
            p = EcPoint(curve: self,
                        x: EcFieldElement(q: self._q,
                                          x: BigInt(sign: .plus,
                                                    magnitude: BigUInt(Data(bytes: xEnc)))),
                        y: EcFieldElement(q: self._q,
                                          x: BigInt(sign: .plus,
                                                    magnitude: BigUInt(Data(bytes: yEnc)))))
            
            break
        default:
            p = nil
            break
        }
        return p
    }
    
    func equals(obj: Any) -> Bool {
        if let o = obj as? EcCurve,
            let a = self._a,
            let b = self._b,
            let oa = o._a,
            let ob = o._b {
            if self._q == o._q &&
                a.equals(oa) &&
                b.equals(ob) {
                return true
            }
        }
        return false
        
    }
}
