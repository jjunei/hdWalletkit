//
//  EthereumRawTransaction.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation
/// RawTransaction constructs necessary information to publish transaction.
public struct EthereumRawTransaction: Codable {
    
    /// Amount value to send, unit is in Wei
    public let value: Wei
    
    /// Address to send ether to
    public let to: EthereumAddress
    
    /// Gas price for this transaction, unit is in Wei
    /// you need to convert it if it is specified in GWei
    /// use Converter.toWei method to convert GWei value to Wei
    public let gasPrice: Wei
    
    /// Gas limit for this transaction
    /// Total amount of gas will be (gas price * gas limit)
    public let gasLimit: Wei
    
    /// Nonce of your address
    public let nonce: Int
    
    /// Data to attach to this transaction
    public let data: Data
    
    public init(value: Wei, to: String, gasPrice: Wei, gasLimit: Wei, nonce: Int, data: Data = Data()) {
        self.value = value
        self.to = EthereumAddress(string:to)
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.nonce = nonce
        self.data = data
    }
}
