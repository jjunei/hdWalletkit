//
//  EcSignature.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import BigInt

class EcSignature {
    private static let PREFIX = "SIG";
    var recId: Int = -1
    var r: BigInt;
    var s: BigInt;
    var curveParam: CurveParam;
    
    init(r: BigInt,
         s: BigInt,
         curveParam: CurveParam) {
        self.r = r
        self.s = s
        self.curveParam = curveParam
    }
    
    convenience init(r: BigInt,
                     s: BigInt,
                     curveParam: CurveParam,
                     recId: Int) {
        self.init(r: r, s: s, curveParam: curveParam)
        self.setRecid(recId)
    }
    
    func setRecid(_ recid: Int) {
        self.recId = recid
    }
    
    func toString() -> String? {
        if ( recId < 0 || recId > 3) {
            return "no recovery sig: \(HexUtils.shared.toHex(self.r.toByteArray()))\(HexUtils.shared.toHex(self.s.toByteArray()))"
        }
        return self.eosEncodingHex(true)
    }
    
    
    func eosEncodingHex(_ compressed: Bool )->String? {
        if ( recId < 0 || recId > 3) {
            return nil;
        }
        
        let headerByte = recId + 27 + (compressed ? 4 : 0);
        var sigData = Array<UInt8>(repeating: 0, count: 65)
        sigData[0] = UInt8(headerByte)
        sigData = EcTools.shared.arrayCopy(src: EcTools.shared.integerToBytes(self.r, length: 32),
                                           srcPos: 0,
                                           dest: sigData,
                                           destPos: 1,
                                           length: 32)
        sigData = EcTools.shared.arrayCopy(src: EcTools.shared.integerToBytes(self.s, length: 32),
                                           srcPos: 0,
                                           dest: sigData,
                                           destPos: 33,
                                           length: 32)
        return EosEcUtil.shared.encodeEosCrypto(prefix: EcSignature.PREFIX,
                                                curveParam: curveParam,
                                                data: sigData)
    }
}
