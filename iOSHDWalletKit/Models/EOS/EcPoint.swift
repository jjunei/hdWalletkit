//
//  EcPoint.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import BigInt

class EcPoint{
    private let _curve: EcCurve
    private let _x: EcFieldElement?
    private let _y: EcFieldElement?
    private let _compressed: Bool
    
    init(curve: EcCurve,
         x: EcFieldElement?,
         y: EcFieldElement?) {
        self._curve = curve
        self._x = x
        self._y = y
        self._compressed = false
    }
    
    init(curve: EcCurve,
         x: EcFieldElement?,
         y: EcFieldElement?,
         compressed: Bool) {
        self._curve = curve
        self._x = x
        self._y = y
        self._compressed = compressed
    }
    
    func getCurve() -> EcCurve {
        return _curve
    }
    
    func getX() -> EcFieldElement? {
        return _x
    }
    
    func getY() -> EcFieldElement? {
        return _y
    }
    
    func isInfinity() -> Bool {
        return _x == nil && _y == nil
    }
    
    func isCompressed() -> Bool {
        return _compressed
    }
    
    func getEncoded(tag: String) -> [UInt8]? {
        if self.isInfinity(){
            return [0];
        }
        
        if let x = self._x,
            let y = self._y {
            let length: Int = EcTools.shared.getByteLength(x.getFieldSize())
            if self._compressed {
                var PC: UInt8
                if y.toBigInteger().testBit(0) {
                    PC = 0x03
                }else{
                    PC = 0x02
                }
                
                let X: [UInt8] = EcTools.shared.integerToBytes(x.toBigInteger(),
                                                               length: length)
                var PO: [UInt8] = []
                PO.append(PC)
                PO.append(contentsOf: X)
                
                return PO;
            } else {
                let X = EcTools.shared.integerToBytes(x.toBigInteger(), length: length)
                let Y = EcTools.shared.integerToBytes(y.toBigInteger(), length: length)
                
                var PO: [UInt8] = [];
                PO.append(0x04)
                PO.append(contentsOf: X)
                PO.append(contentsOf: Y)
                
                return PO;
            }
        }
        return nil
    }
    
    func getEncoded() -> [UInt8]? {
        if self.isInfinity(){
            return [0];
        }
        
        if let x = self._x,
            let y = self._y {
            let length: Int = EcTools.shared.getByteLength(x.getFieldSize())
            if self._compressed {
                var PC: UInt8;
                if y.toBigInteger().testBit(0) {
                    PC = 0x03
                } else {
                    PC = 0x02
                }
                let X: [UInt8] = EcTools.shared.integerToBytes(x.toBigInteger(),
                                                               length: length)
                var PO: [UInt8] = [];
                PO.append(PC)
                PO.append(contentsOf: X);
                return PO;
            } else {
                let X = EcTools.shared.integerToBytes(x.toBigInteger(), length: length)
                let Y = EcTools.shared.integerToBytes(y.toBigInteger(), length: length)
                
                var PO: [UInt8] = [];
                PO.append(0x04)
                PO.append(contentsOf: X)
                PO.append(contentsOf: Y)
                return PO;
            }
        }
        return nil;
    }
    
    func add(_ b: EcPoint) -> EcPoint? {
        if self.isInfinity() {
            return b
        }
        
        if b.isInfinity() {
            return self
        }
        
        if let x = self._x,
            let y = self._y,
            let bx = b._x,
            let by = b._y {
            
            if x.equals(bx) {
                if y.equals(by) {
                    return self.twice()
                }
                return self._curve._infinity
            }
            if let gamma = by.subtract(b: y).divide(b: bx.subtract(b: x)) {
                let x3: EcFieldElement = gamma.square().subtract(b: x).subtract(b: bx)
                let y3: EcFieldElement = gamma.multiply(b: x.subtract(b: x3)).subtract(b: y)
                return EcPoint(curve: _curve,
                               x: x3,
                               y: y3)
            }
        }
        return nil
    }
    
    func twice() -> EcPoint? {
        if self.isInfinity() {
            return self;
        }
        
        if let x = self._x,
            let y = self._y,
            let a = self._curve._a {
            
            if x.toBigInteger().signum() == 0 {
                return self._curve._infinity
            }
            
            let TWO: EcFieldElement = self._curve.fromBigInteger(BigInt(2))
            let THREE: EcFieldElement = self._curve.fromBigInteger(BigInt(3))
            
            if let gamma: EcFieldElement = x.square().multiply(b: THREE).add(b: a).divide(b: y.multiply(b: TWO)) {
                
                let temp = x.multiply(b: TWO)
                
                let x3: EcFieldElement = gamma.square().subtract(b: temp)
                let y3: EcFieldElement = gamma.multiply(b: x.subtract(b: x3)).subtract(b: y)
                
                return EcPoint(curve: _curve,
                               x: x3,
                               y: y3,
                               compressed: self._compressed)
            }
        }
        return nil
    }
    
    
    func subtract(b: EcPoint) -> EcPoint? {
        if b.isInfinity() {
            return self;
        }
        if let temp = add(b.negate()) {
            return temp
        }
        return nil
    }
    
    func negate() -> EcPoint {
        return EcPoint(curve: _curve,
                       x: self._x,
                       y: self._y?.negate(),
                       compressed: self._compressed)
    }
    
    
    func equals(other: Any) -> Bool {
        if let o: EcPoint = other as? EcPoint,
            let x = self._x,
            let y = self._y,
            let ox = o._x,
            let oy = o._y{
            if self.isInfinity() {
                return o.isInfinity();
            }
            return x.equals(ox) && y.equals(oy)
        }
        return false
    }
    
    func multiply(n: BigInt) -> EcPoint {
        return EcTools.shared.multiply(self, n)
    }
}
