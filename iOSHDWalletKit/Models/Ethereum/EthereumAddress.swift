//
//  Address.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import Foundation
/// Represents an address
public struct EthereumAddress: Codable {
    
    /// Address in data format
    public let data: Data
    
    /// Address in string format, EIP55 encoded
    public let string: String
    
    public init(data: Data, string: String) {
        self.data = data
        self.string = string
    }
    
    public init(data: Data) {
        self.data = data
        self.string = "0x" + EIP55.encode(data)
    }
    
    public init(string: String) {
        self.data = Data(hex: string.stripHexPrefix())
        self.string = string
    }
}
