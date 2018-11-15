//
//  EcFieldElement.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import BigInt

class EcFieldElement {
    private let TWO: BigInt = BigInt(2)
    private let _x: BigInt
    private let _q: BigInt
    
    init(q: BigInt,
         x: BigInt) {
        self._x = x
        if q > x {
            
        }
        self._q = q
    }
    
    func testBit(_ temp: BigInt,
                 n: BigInt) -> Bool {
        return (temp & (BigInt(1) << n)) != BigInt(0)
    }
    
    func toBigInteger() -> BigInt {
        return _x
    }
    
    func getFieldSize() -> Int {
        return _q.bitLength()
    }
    
    func getQ() -> BigInt {
        return _q
    }
    
    func add(b: EcFieldElement) -> EcFieldElement {
        return EcFieldElement(q: _q,
                              x: _x.add(b.toBigInteger()).mod(_q))
    }
    
    func subtract(b: EcFieldElement) -> EcFieldElement {
        return EcFieldElement(q: _q,
                              x: _x.subtract(b.toBigInteger()).mod(_q))
    }
    
    func multiply(b: EcFieldElement) -> EcFieldElement {
        return EcFieldElement(q: _q,
                              x: _x.multiply(b.toBigInteger().mod(_q)))
    }
    
    func multiply(b: EcFieldElement,
                  tag: String) -> EcFieldElement {
        let B = b.toBigInteger()
        let temp0 = _x.multiply(B)
        let temp1 = temp0.mod(_q)
        return EcFieldElement(q: _q, x: temp1)
    }
    
    func divide(b: EcFieldElement) -> EcFieldElement? {
        if let modInverse = b.toBigInteger().modInverse(_q) {
            return EcFieldElement(q: _q,
                                  x: _x.multiply(modInverse).mod(_q))
        }
        return nil
    }
    
    func negate() -> EcFieldElement {
        var tempX = _x
        tempX.negate()
        return EcFieldElement(q: _q,
                              x: tempX.mod(_q))
    }
    
    func square() -> EcFieldElement {
        return EcFieldElement(q: _q,
                              x: (_x * _x).mod(_q))
    }
    
    func invert() -> EcFieldElement? {
        if let modInverse = _x.modInverse( _q) {
            return EcFieldElement(q: _q,
                                  x: modInverse)
        }
        return nil
    }
    
    
    func toString() -> String {
        return String(self.toBigInteger(), radix: 16)
    }
    
    func equals(_ other: Any) -> Bool {
        if let o = other as? EcFieldElement {
            return _q == o._q && _x == o._x
        }
        return false
    }
    
    func lucasSequence(_ p: BigInt,
                       _ P: BigInt,
                       _ Q: BigInt,
                       _ k: BigInt) -> [BigInt] {
        let n = k.bitLength()
        let s = k.getLowestSetBit()
        
        var Uh: BigInt = BigInt(1)
        var Vl: BigInt = BigInt(2)
        var Vh: BigInt = P
        var Ql: BigInt = BigInt(1)
        var Qh: BigInt = BigInt(1)
        
        var j = n - 1
        while j > s {
            Ql = Ql.multiply(Qh).mod(p)
            
            if k.testBit(j) {
                Qh = Ql.multiply(Q).mod(p)
                Uh = Uh.multiply(Vh).mod(p)
                Vl = Vh.multiply(Vl).subtract(P.multiply(Ql)).mod(p)
                Vh = Vh.multiply(Vh).subtract(Qh.shiftLeft(1)).mod(p)
            } else {
                Qh = Ql
                Uh = Uh.multiply(Vl).subtract(Ql).mod(p)
                Vh = Vh.multiply(Vl).subtract(P.multiply(Ql)).mod(p)
                Vl = Vl.multiply(Vl).subtract(Ql.shiftLeft(1)).mod(p)
            }
            
            j = j - 1
        }
        
        Ql = Ql.multiply(Qh).mod(p)
        Qh = Ql.multiply(Q).mod(p)
        Uh = Uh.multiply(Vl).subtract(Ql).mod(p)
        Vl = Vh.multiply(Vl).subtract(P.multiply(Ql)).mod(p)
        Ql = Ql.multiply(Qh).mod(p)
        
        while j <= s {
            Uh = Uh.multiply(Vl).mod(p)
            Vl = Vl.multiply(Vl).subtract(Ql.shiftLeft(1)).mod(p)
            Ql = Ql.multiply(Ql).mod(p)
        }
        return [Uh, Vl]
    }
    
    func sqrt() -> EcFieldElement? {
        if !_q.testBit(0) {
            return nil
        }
        
        if _q.testBit(1) {
            let z = EcFieldElement(q: _q,
                                   x: _x.power((_q.shiftRight(2) + BigInt(1)), modulus: _q))
            return z.square().equals(self) ? z : nil
        }
        
        let qMinusOne = _q - BigInt(1)
        let legendreExponent = qMinusOne.shiftRight(1)
        
        if !(_x.power(legendreExponent, modulus: _q) == BigInt(1)) {
            return nil;
        }
        
        let u = qMinusOne.shiftRight(2);
        let k = u.shiftLeft(1) + BigInt(1)
        
        let Q = self._x
        let fourQ = Q.shiftRight(2).mod(_q)
        
        
        var U: BigInt
        var V: BigInt
        
        repeat {
            var P: BigInt
            repeat {
                P = BigInt(BigUInt.randomInteger(withMaximumWidth: _q.bitLength()))
            } while P.compareTo(_q) >= 0 ||
                !(((P * P) - fourQ).power(legendreExponent, modulus: _q) == qMinusOne)
            
            var result = self.lucasSequence(_q, P, Q, k);
            U = result[0];
            V = result[1];
            
            if V.multiply(V).mod(_q) == fourQ{
                
                if V.testBit(0) {
                    V = V.add(_q);
                }
                
                V = V.shiftRight(1);
                return EcFieldElement(q: _q, x: V)
            }
        } while (U == BigInt(1) || U == qMinusOne)
        return nil;
    }
}


extension BigInt{
    func bitLength() -> Int {
        return self == 0 ? 0 : (self.bitWidth - 1)
    }
    
    func add(_ n: BigInt) -> BigInt {
        return self + n
    }
    
    func subtract(_ n: BigInt) -> BigInt {
        return self - n
    }
    
    func multiply(_ n: BigInt)->BigInt{
        return self * n
    }
    
    func mod(_ n: BigInt)->BigInt{
        return self.modulus(n)
    }
    
    func modInverse(_ b: BigInt) -> BigInt? {
        return self.inverse(b)
    }
    
    func toByteArray() -> [UInt8] {
        var result: [UInt8] = []
        let temp: [UInt8] = [UInt8(truncating: NSNumber(value: -128)),0,0,0,0,0,0,0,0,0,
                             0,0,0,0,0,0,0,0,0,0,
                             0,0,0,0,0,0,0,0,0,0,
                             0,0]
        if self >= BigInt(BigUInt(Data(temp))) {
            result.append(0)
        }
        result.append(contentsOf: Array(BigUInt(self).serialize()))
        return result
    }
    
    func shiftLeft(_ n: Int) -> BigInt {
        return self << n
    }
    
    func shiftRight(_ n: Int) -> BigInt {
        return self >> n
    }
    
    func testBit(_ n: Int) -> Bool {
        return (self & (BigInt(1) << n)) != BigInt(0);
    }
    
    func compareTo(_ n: BigInt) -> Int{
        if self > n {
            return 1
        } else if self < n {
            return -1
        } else {
            return 0
        }
    }
    
    func getLowestSetBit() -> Int {
        var s = self
        let temp = Double(s & -s)
        return self == BigInt(0) ? -1 : Int(log2(temp))
    }
}
