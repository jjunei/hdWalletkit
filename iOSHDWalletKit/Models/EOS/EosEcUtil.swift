//
//  EosEcUtil.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 09/11/2018.
//  Copyright © 2018 kgthtj@gmail.com. All rights reserved.
//

import Foundation
import CryptoSwift

class EosEcUtil{
    static let shared = EosEcUtil()
    private init() {}
    
    static let PREFIX_K1: String = "K1";
    static let PREFIX_R1: String = "R1";
    static let EOS_CRYPTO_STR_SPLITTER: String = "_";
    
    func safeSplitEosCryptoString(cryptoStr: String) -> [String] {
        if cryptoStr.count > 0 {
            return cryptoStr.components(separatedBy: EosEcUtil.EOS_CRYPTO_STR_SPLITTER)
        }
        return [cryptoStr]
    }
    
    func getCurveParamFrom(curveType: String) -> CurveParam? {
        return EcTools.shared.getCurveParam(curveType: (EosEcUtil.PREFIX_K1 == curveType) ? CurveParam.SECP256_R1 : CurveParam.SECP256_K1)
    }
    
    func getBytesIfMatchedRipemd160(base58Data: String,
                                    prefix: String?) -> ([UInt8], Int)? {
        let prefixBytes = (prefix == nil || prefix == "") ? [UInt8(0)] : prefix!
            .getBytes()
        
        if let base58 = base58Data.base58DecodedData {
            let data = Array(base58)
            var toHashData = Array<UInt8>(repeating: 0,
                                          count: data.count - 4 + prefixBytes.count)
            toHashData = EcTools.shared.arrayCopy(src: data,
                                                  srcPos: 0,
                                                  dest: toHashData,
                                                  destPos: 0,
                                                  length: (data.count - 4))
            toHashData = EcTools.shared.arrayCopy(src: prefixBytes,
                                                  srcPos: 0,
                                                  dest: toHashData,
                                                  destPos: (data.count - 4),
                                                  length: prefixBytes.count)
            let ripemd160 = RIPEMD160.hash(Data.init(bytes: toHashData))
            let checksumByCal = EcTools.shared.uint32ToLong(buf: [UInt8](ripemd160),
                                                            offset: 0)
            let checksumFromData = EcTools.shared.uint32ToLong(buf: data,
                                                               offset: (data.count - 4 ))
            if ( checksumByCal != checksumFromData ) {
                return nil;
            }
            return (EcTools.shared.copyOfRange(data, 0, (data.count - 4)), checksumFromData)
        }
        return nil
    }
    
    func getBytesIfMatchedSha256(base58Data: String ) -> ([UInt8], Int)? {
        if let base58 = base58Data.base58DecodedData {
            let data = Array(base58)
            let checkOne = Sha256.from(data: data,
                                       offset: 0,
                                       length: (data.count - 4))!;
            let checkTwo = Sha256.from(data: checkOne.getBytes()!)!;
            
            if checkTwo.equalsFromOffset(data, (data.count - 4), 4) ||
                checkOne.equalsFromOffset(data, (data.count - 4), 4){
                return (EcTools.shared.copyOfRange(data, 1, (data.count - 4)),
                        EcTools.shared.uint32ToLong(buf: data,
                                                    offset: (data.count - 4)));
            }
        }
        return nil;
    }
    
    func encodeEosCrypto(prefix: String,
                         curveParam: CurveParam?,
                         data: [UInt8]) -> String {
        var typePart = "";
        if let c = curveParam{
            if c.isType(paramType: CurveParam.SECP256_K1) {
                typePart = EosEcUtil.PREFIX_K1;
            } else if c.isType(paramType: CurveParam.SECP256_R1) {
                typePart = EosEcUtil.PREFIX_R1
            }
        }
        var toHashData = Array<UInt8>(repeating: 0,
                                      count: (data.count + typePart.count))
        toHashData = EcTools.shared.arrayCopy(src: data,
                                               srcPos: 0,
                                               dest: toHashData,
                                               destPos: 0,
                                               length: data.count)
        if typePart.count > 0 {
            toHashData = EcTools.shared.arrayCopy(src: typePart.getBytes(),
                                                   srcPos: 0,
                                                   dest: toHashData,
                                                   destPos: data.count,
                                                   length: typePart.count)
            
        }
        var dataToEncodeBase58 = Array<UInt8>(repeating: 0, count: (data.count + 4))
        let ripemd160 = RIPEMD160.hash(Data.init(bytes: toHashData))
        let checksumBytes = [UInt8](ripemd160)
        dataToEncodeBase58 = EcTools.shared.arrayCopy(src: data,
                                                       srcPos: 0,
                                                       dest: dataToEncodeBase58,
                                                       destPos: 0,
                                                       length: data.count)
        dataToEncodeBase58 = EcTools.shared.arrayCopy(src: checksumBytes,
                                                       srcPos: 0,
                                                       dest: dataToEncodeBase58,
                                                       destPos: data.count,
                                                       length: 4)
        var result = ""
        if typePart.count == 0 {
            result = prefix;
        } else {
            result = "\(prefix)\(EosEcUtil.EOS_CRYPTO_STR_SPLITTER)\(typePart)\(EosEcUtil.EOS_CRYPTO_STR_SPLITTER)"
        }
        let encode = dataToEncodeBase58.base58EncodedString
        return "\(result)\(encode)"
    }
}
