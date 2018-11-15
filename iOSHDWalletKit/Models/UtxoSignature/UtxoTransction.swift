//
//  UtxoTransction.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation

private let zero: Data = Data(repeating: 0, count: 32)
private let one: Data = Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)

public struct UtxoTransactionOutput{
    public var value : Int64
    public let lockingScript: Data
    
    public var scriptLength: VarInt {
        return VarInt(lockingScript.count)
    }
    
    public init(value: Int64, lockingScript: Data) {
        self.value = value
        self.lockingScript = lockingScript
    }
    
    public func serialized() -> Data {
        var data = Data()
        data += value
        data += scriptLength.serialized()
        data += lockingScript
        return data
    }
    
    public func scriptCode() -> Data {
        var data = Data()
        data += scriptLength.serialized()
        data += lockingScript
        return data
    }
    
    public init() {
        self.init(value: 0, lockingScript: Data())
    }
}

public struct UtxoTransactionOutPoint{
    public let hash: Data
    public let index: UInt32
    
    public init(hash: Data, index: UInt32) {
        self.hash = hash
        self.index = index
    }
    
    public func serialized() -> Data {
        var data = Data()
        data += hash
        data += index
        return data
    }
    
    public init() {
        self.init(hash: Data(), index: 0)
    }
}

public struct UtxoUnspentTransaction {
    public let output: UtxoTransactionOutput
    public let outpoint: UtxoTransactionOutPoint
    
    public init() {
        self.output = UtxoTransactionOutput()
        self.outpoint = UtxoTransactionOutPoint()
    }
    
    public init(output: UtxoTransactionOutput, outpoint: UtxoTransactionOutPoint) {
        self.output = output
        self.outpoint = outpoint
    }
}

public struct UtxoTransactionInput {
    public let previousOutput: UtxoTransactionOutPoint
    public let signatureScript: Data
    public let sequence: UInt32
    
    public var scriptLength: VarInt {
        return VarInt(signatureScript.count)
    }
    
    public init(previousOutput: UtxoTransactionOutPoint, signatureScript: Data, sequence: UInt32) {
        self.previousOutput = previousOutput
        self.signatureScript = signatureScript
        self.sequence = sequence
    }
    
    public func serialized() -> Data {
        var data = Data()
        data += previousOutput.serialized()
        data += scriptLength.serialized()
        data += signatureScript
        data += sequence
        return data
    }
}

public struct UtxoTransaction {
    public let version: Int32
    public let inputs: [UtxoTransactionInput]
    public let outputs: [UtxoTransactionOutput]
    public let lockTime: UInt32
    
    public var txHash: Data {
        return serialized().doubleSHA256
    }
    
    public var txID: String {
        return Data(txHash.reversed()).hex
    }
    
    public var txInCount: VarInt {
        return VarInt(inputs.count)
    }
    
    public var txOutCount: VarInt {
        return VarInt(outputs.count)
    }
    
    public init(version: Int32, inputs: [UtxoTransactionInput], outputs: [UtxoTransactionOutput], lockTime: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
    }
    
    public func serialized() -> Data {
        var data = Data()
        data += version
        data += txInCount.serialized()
        data += inputs.flatMap { $0.serialized() }
        data += txOutCount.serialized()
        data += outputs.flatMap { $0.serialized() }
        data += lockTime
        return data
    }
    
    internal func getPrevoutHash(hashType: SighashType) -> Data {
        if !hashType.isAnyoneCanPay {
            let serializedPrevouts: Data = inputs.reduce(Data()) { $0 + $1.previousOutput.serialized() }
            return serializedPrevouts.doubleSHA256
        } else {
            return zero
        }
    }
    
    internal func getSequenceHash(hashType: SighashType) -> Data {
        if !hashType.isAnyoneCanPay
            && !hashType.isSingle
            && !hashType.isNone {
            let serializedSequence: Data = inputs.reduce(Data()) { $0 + $1.sequence }
            return serializedSequence.doubleSHA256
        } else {
            return zero
        }
    }
    
    internal func getOutputsHash(index: Int, hashType: SighashType) -> Data {
        if !hashType.isSingle
            && !hashType.isNone {
            let serializedOutputs: Data = outputs.reduce(Data()) { $0 + $1.serialized() }
            return serializedOutputs.doubleSHA256
        } else if hashType.isSingle && index < outputs.count {
            let serializedOutput = outputs[index].serialized()
            return serializedOutput.doubleSHA256
        } else {
            return zero
        }
    }
        
    public func signatureHash(for utxo: UtxoTransactionOutput, inputIndex: Int, hashType: SighashType) -> Data {
        let txin = inputs[inputIndex]
        
        var data = Data()
        data += version
        data += getPrevoutHash(hashType: hashType)
        data += getSequenceHash(hashType: hashType)
        data += txin.previousOutput.serialized()
        data += utxo.scriptCode()
        data += utxo.value
        data += txin.sequence
        data += getOutputsHash(index: inputIndex, hashType: hashType)
        data += lockTime
        data += UInt32(hashType)
        let hash = data.doubleSHA256
        return hash
    }
}

public struct UtxoUnsignedTransaction {
    public let tx: UtxoTransaction
    public let utxos: [UtxoUnspentTransaction]
    
    public init(tx: UtxoTransaction, utxos: [UtxoUnspentTransaction]) {
        self.tx = tx
        self.utxos = utxos
    }
}
