//
//  Fee.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation

public struct Fee {
    public static let feePerByte: Int64 = 1 // ideally get this value from Bitcoin node
    public static let dust: Int64 = 3 * 182 * feePerByte
    
    // size for txin(P2PKH) : 148 bytes
    // size for txout(P2PKH) : 34 bytes
    // cf. size for txin(P2SH) : not determined to one
    // cf. size for txout(P2SH) : 32 bytes
    // cf. size for txout(OP_RETURN + String) : Roundup([#characters]/32) + [#characters] + 11 bytes
    public static func calculate(nIn: Int, nOut: Int = 2, extraOutputSize: Int = 0) -> Int64 {
        var txsize: Int {
            return ((148 * nIn) + (34 * nOut) + 10) + extraOutputSize
        }
        return Int64(txsize) * feePerByte
    }
}
