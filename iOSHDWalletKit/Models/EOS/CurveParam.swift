//
//  CurveParam.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import BigInt

class CurveParam{
    
    private let curveParamType: Int
    
    static let SECP256_K1 = 0
    static let SECP256_R1 = 1
    
    private var curve: EcCurve?
    private var G: EcPoint?
    private var n: BigInt?
    
    private var HALF_CURVE_ORDER: BigInt?
    
    init(curveParamType: Int,
         pInHex: String,
         aInHex: String,
         bInHex: String,
         GxInHex: String,
         GyInHex: String,
         nInHex: String) {
        self.curveParamType = curveParamType
        if let p = BigInt(pInHex, radix: 16),
            let b = BigInt(bInHex, radix: 16),
            let a = BigInt(aInHex, radix: 16) {
            self.curve = EcCurve(q: p,
                                 a: a,
                                 b: b)
            if let bytes = HexUtils.shared.toBytes(hexString: "04\(GxInHex)\(GyInHex)") {
                G = self.curve?.decodePoint(bytes)
            }
            n = BigInt(nInHex, radix: 16)
            HALF_CURVE_ORDER = n!.shiftRight(1)
        }
    }
    
    func isType(paramType: Int) -> Bool {
        return (curveParamType == paramType)
    }
    
    func getCurveParamType() -> Int {
        return curveParamType
    }
    
    func getG() -> EcPoint? {
        return self.G
    }
    
    func getN() -> BigInt? {
        return self.n
    }
    
    func halfCurveOrder() -> BigInt? {
        return HALF_CURVE_ORDER
    }
    
    func getCurve() -> EcCurve? {
        return curve
    }
}
