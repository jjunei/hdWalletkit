//
//  PrivateKey.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation
import BigInt

public enum PrivateKeyError: Error {
    case invalidFormat
}

public struct PrivateKey {
    public let raw: Data
    public let chainCode: Data
    public let depth: UInt8
    public let fingerprint: UInt32
    public let index: UInt32
    public let coin: Coin

    private static let PREFIX: String = "PVT";

    private var mCurveParam: CurveParam?;
    
//Kit Test Code
    public init(wif: String) throws {
        guard let decoded = Base58.decode(wif) else {
            throw PrivateKeyError.invalidFormat
        }
        let checksumDropped = decoded.prefix(decoded.count - 4)
        guard checksumDropped.count == (1 + 32) || checksumDropped.count == (1 + 32 + 1) else {
            throw PrivateKeyError.invalidFormat
        }
               
        self.coin = Coin.bitcoinCash
        
        let h = checksumDropped.doubleSHA256
        let calculatedChecksum = h.prefix(4)
        let originalChecksum = decoded.suffix(4)
        guard calculatedChecksum == originalChecksum else {
            throw PrivateKeyError.invalidFormat
        }
        
        // Private key itself is always 32 bytes.
        self.raw = checksumDropped.dropFirst().prefix(32)
        self.chainCode = Data()
        self.depth = 0
        self.fingerprint = 0
        self.index = 0
        self.mCurveParam = EcTools.shared.getCurveParam(curveType: CurveParam.SECP256_K1)
    }
    
    public init(raw: Data, coin: Coin){
        self.raw = raw
        self.chainCode = Data()
        self.depth = 0
        self.fingerprint = 0
        self.index = 0
        self.coin = coin
        self.mCurveParam = EcTools.shared.getCurveParam(curveType: CurveParam.SECP256_K1)
    }
//KitTest End
    public init(seed: Data, coin: Coin) {
        let output = Crypto.HMACSHA512(key: "Bitcoin seed".data(using: .ascii)!, data: seed)
        self.raw = output[0..<32]
        self.chainCode = output[32..<64]
        self.depth = 0
        self.fingerprint = 0
        self.index = 0
        self.coin = coin
        self.mCurveParam = EcTools.shared.getCurveParam(curveType: CurveParam.SECP256_K1)
    }
    
    private init(privateKey: Data, chainCode: Data, depth: UInt8, fingerprint: UInt32, index: UInt32, coin: Coin) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.index = index
        self.coin = coin
        self.mCurveParam = EcTools.shared.getCurveParam(curveType: CurveParam.SECP256_K1)
    }
    
    init(base58Str: String) throws {
        let split = EosEcUtil.shared.safeSplitEosCryptoString(cryptoStr: base58Str)
        var keyBytes: [UInt8]?
        if split.count == 1 {
            self.mCurveParam = EcTools.shared.getCurveParam(curveType: CurveParam.SECP256_K1)
            keyBytes = EosEcUtil.shared.getBytesIfMatchedSha256(base58Data: base58Str)?.0
        }else{
            if ( split.count < 3 ) {
            }
            self.mCurveParam = EosEcUtil.shared.getCurveParamFrom(curveType: split[1])
            keyBytes = EosEcUtil.shared.getBytesIfMatchedRipemd160( base58Data: split[2],
                                                                    prefix: split[1])?.0
        }
        
        if let keys = keyBytes,
            keys.count >= 5 {
            self.raw = Data(bytes: keys)
            self.chainCode = Data()
            self.depth = 0
            self.fingerprint = 0
            self.index = 0
            self.coin = Coin.eos
        } else {
            throw PrivateKeyError.invalidFormat
        }
    }
    
    func getAsBigInteger() -> BigInt?{
        let v = [UInt8](self.raw)
        if (((v[0]) & 0x80) != 0) {
            return BigInt(sign: .plus, magnitude: BigUInt(Data(v)))
        }
        return BigInt(BigUInt(Data(v)))
    }
    
    func getCurveParam() -> CurveParam? {
        return self.mCurveParam
    }
    
    public var publicKey: PublicKey {
        return PublicKey(privateKey: self, chainCode: chainCode, coin: coin, depth: depth, fingerprint: fingerprint, index: index)
    }

    public var extended: String {
        var extendedPrivateKeyData = Data()
        extendedPrivateKeyData += coin.privateKeyVersion.bigEndian
        extendedPrivateKeyData += depth.littleEndian
        extendedPrivateKeyData += fingerprint.littleEndian
        extendedPrivateKeyData += index.littleEndian
        extendedPrivateKeyData += chainCode
        extendedPrivateKeyData += UInt8(0)
        extendedPrivateKeyData += raw
        let checksum = extendedPrivateKeyData.doubleSHA256.prefix(4)
        return Base58.encode(extendedPrivateKeyData + checksum)
    }
    
    public func wif() -> String {
        var data = Data()
        data += coin.wifPreifx
        data += raw
        data += UInt8(0x01)
        data += data.doubleSHA256.prefix(4)
        return Base58.encode(data)
    }
    
    public func eosWif() -> String {
        var data = Data()
        data += coin.wifPreifx
        data += Data(hex: raw.toHexString())
        data += data.doubleSHA256.prefix(4)
        return Base58.encode(data)
    }
    
    public func get() -> String {
        switch self.coin {
        case .ethereum: fallthrough
        case .ethereumclassic: fallthrough
        case .tron:
            return self.raw.toHexString()
        case .eos:
            return self.eosWif()
        default:
            return self.wif()
        }
    }
        
    public func derived(at node:DerivationNode) -> PrivateKey {
        let edge: UInt32 = 0x80000000
        guard (edge & node.index) == 0 else { fatalError("Invalid child index") }

        var data = Data()
        switch node {
        case .hardened:
            data += UInt8(0)
            data += raw
        case .notHardened:
            data += Crypto.generatePublicKey(data: raw, compressed: true)
        }
        
        let derivingIndex = CFSwapInt32BigToHost(node.hardens ? (edge | node.index) : node.index)
        data += derivingIndex
        
        let digest = Crypto.HMACSHA512(key: chainCode, data: data)
        let factor = BInt(data: digest[0..<32])
        
        let curveOrder = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
        let derivedPrivateKey = ((BInt(data: raw) + factor) % curveOrder).data
        
        let derivedChainCode = digest[32..<64]
        let fingurePrint: UInt32 = RIPEMD160.hash(publicKey.rawCompressed.sha256()).withUnsafeBytes { $0.pointee }
        
        return PrivateKey(
            privateKey: derivedPrivateKey,
            chainCode: derivedChainCode,
            depth: depth + 1,
            fingerprint: fingurePrint,
            index: derivingIndex,
            coin: coin
        )
    }
    
    public func signatureETH_ETC(rawTransaction: EthereumRawTransaction, chainId: Int) throws -> String {
        let signer = EIP155Signer(chainId: chainId)
        let rawData = try signer.sign(rawTransaction, privateKey: self)
        let hash = rawData.toHexString().addHexPrefix()
        return hash
    }
    
    public func signatureTron(rawTransaction: Data) throws -> String {
        let signer = EIP155Signer(chainId: 0)
        let rawData = try signer.sign(rawTransaction, privateKey: self)
        let hash = rawData.toHexString()
        return hash
    }
    
    public func signature(tosign: Data) throws -> Data {
        return try Crypto.sign(tosign, privateKey: self)
    }
    
    public func signatureEOS(tosign: String) throws -> String {
        let len = tosign.count;
        var bytes = Array<UInt8>(repeating: 0, count: 32);
        var index = 0;
        while index < len {
            let start = tosign.index(tosign.startIndex, offsetBy: index)
            let end = tosign.index(tosign.startIndex, offsetBy: index + 2)
            let strIte = tosign[start..<end]
            if let n = Int(strIte, radix: 16){
                let temp = (n & 0xFF);
                bytes[index/2] = UInt8(temp);
            }
            index = index + 2;
        }
        let writer = EosByteWriter(capacity: 255)
        writer.putBytes(value: bytes)
        if let signature = ECDSA.secp256k1.sign(hash: Sha256.from(data: writer.toBytes())!,
                                                key: self) {
            return signature.toString()!
        }
        return ""
    }
    
    public func signatureBCH(toAddress: Address, amount: Int64, changeAddress: Address, utxos: [UtxoUnspentTransaction]) -> UtxoTransaction {
        let fees = Fee.calculate(nIn: utxos.count, nOut: 2)
        let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
        let change: Int64 = totalAmount - amount - fees
        
        var utxoTransactionOutput : [UtxoTransactionOutput] = [UtxoTransactionOutput]()
        
        let toPubKeyHash: Data = toAddress.data
        let lockingScriptTo = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
        utxoTransactionOutput.append(UtxoTransactionOutput(value: amount, lockingScript: lockingScriptTo))
        if change > 0 {
            let changePubkeyHash: Data = changeAddress.data
            let lockingScriptChange = Script.buildPublicKeyHashOut(pubKeyHash: changePubkeyHash)
            utxoTransactionOutput.append(UtxoTransactionOutput(value: change, lockingScript: lockingScriptChange))
        }
        
        // この後、signatureScriptやsequenceは更新される
        let unsignedInputs = utxos.map { UtxoTransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        let tx = UtxoTransaction(version: 1, inputs: unsignedInputs, outputs: utxoTransactionOutput, lockTime: 0)
        let unsignedTx = UtxoUnsignedTransaction(tx: tx, utxos: utxos)
    
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: UtxoTransaction {
            return UtxoTransaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
        }
        
        let hashType = SighashType.BCH.ALL
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            print("Value of signing txout : \(utxo.output.value)")
            let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: hashType)
            let signature: Data = try! Crypto.sign(sighash, privateKey: self)
            let txin = inputsToSign[i]
            let pubkey = self.publicKey
            let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
            inputsToSign[i] = UtxoTransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
        }
        return transactionToSign
    }
}
