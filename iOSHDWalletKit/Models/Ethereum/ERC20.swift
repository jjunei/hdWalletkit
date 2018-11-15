//
//  ERC20.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation

public struct ERC20: Codable{
    public let contractAddress: String
    public let decimal: Int
    public let symbol: String
    
    public init(contractAddress: String, decimal: Int, symbol: String) {
        self.contractAddress = contractAddress
        self.decimal = decimal
        self.symbol = symbol
    }
    
    private var transferSigniture: Data {
        let method = "transfer(address,uint256)"
        return method.data(using: .ascii)!.sha3(.keccak256)[0...3]
    }
    
    private var lengthOf256bits: Int {
        return 256 / 4
    }
    
    public func generateDataParameter(toAddress: String, amount: String) throws -> Data {
        let method = transferSigniture.toHexString()
        let address = pad(string: toAddress.stripHexPrefix())
        
        let poweredAmount = try power(amount: amount)
        let amount = pad(string: poweredAmount.serialize().toHexString())
        
        return Data(hex: method + address + amount)
    }
    
    private func power(amount: String) throws -> BInt {
        let components = amount.split(separator: ".")

        guard components.count == 1 || components.count == 2 else {
            throw iOSHDWalletKitError.contractError(.containsInvalidCharactor(amount))
        }
        
        guard let integer = BInt(String(components[0]), radix: 10) else {
            throw iOSHDWalletKitError.contractError(.containsInvalidCharactor(amount))
        }
        
        let poweredInteger = integer * (BInt(10) ** decimal)
        
        if components.count == 2 {
            let count = components[1].count
            
            guard count <= decimal else {
                throw iOSHDWalletKitError.contractError(.invalidDecimalValue(amount))
            }
            
            guard let digit = BInt(String(components[1]), radix: 10) else {
                throw iOSHDWalletKitError.contractError(.containsInvalidCharactor(amount))
            }
            
            let poweredDigit = digit * (BInt(10) ** (decimal - count))
            return poweredInteger + poweredDigit
        } else {
            return poweredInteger
        }
    }
    
    /// Pad left spaces out of 256bits with 0
    private func pad(string: String) -> String {
        var string = string
        while string.count != lengthOf256bits {
            string = "0" + string
        }
        return string
    }
}
