//
//  CryptoTests.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import XCTest
@testable import iOSHDWalletKit

class TransactionTests: XCTestCase {
    
    func testBitcoinTransaction() {
    }
    
    func testLiteCoinTransaction() {
    }
    
    func testBitcoinCashTransaction() {
        // Transaction on Bitcoin Cash Mainnet
        // TxID : 96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
        // https://explorer.bitcoin.com/bch/tx/96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
        let toAddress: Address = try! AddressFactory.create("1Bp9U1ogV3A14FMvKbRJms7ctyso4Z4Tcx")
        let changeAddress: Address = try! AddressFactory.create("1FQc5LdgGHMHEN9nwkjmz6tWkxhPpxBvBU")
        
        let unspentOutput = UtxoTransactionOutput(value: 5151, lockingScript: Data(hex: "76a914aff1e0789e5fe316b729577665aa0a04d5b0f8c788ac"))
        let hash = Data(Data(hex: "050d00e2e18ef13969606f1ceee290d3f49bd940684ce39898159352952b8ce2").reversed())
        let unspentOutpoint = UtxoTransactionOutPoint(hash: hash, index: 2)
        let utxo = UtxoUnspentTransaction(output: unspentOutput, outpoint: unspentOutpoint)
        let privatekey = try! PrivateKey(wif: "L1WFAgk5LxC5NLfuTeADvJ5nm3ooV3cKei5Yi9LJ8ENDfGMBZjdW")
        
        let signedTx = privatekey.signatureBCH(toAddress: toAddress, amount: 600, changeAddress: changeAddress, utxos: [utxo])
        XCTAssertEqual(signedTx.txID, "96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4")
        XCTAssertEqual(signedTx.serialized().hex, "0100000001e28c2b955293159898e34c6840d99bf4d390e2ee1c6f606939f18ee1e2000d05020000006b483045022100b70d158b43cbcded60e6977e93f9a84966bc0cec6f2dfd1463d1223a90563f0d02207548d081069de570a494d0967ba388ff02641d91cadb060587ead95a98d4e3534121038eab72ec78e639d02758e7860cdec018b49498c307791f785aa3019622f4ea5bffffffff0258020000000000001976a914769bdff96a02f9135a1d19b749db6a78fe07dc9088ace5100000000000001976a9149e089b6889e032d46e3b915a3392edfd616fb1c488ac00000000")
    }
    
    func testTronMainNetTransaction() {
        let privatekey = PrivateKey(raw: Data(hex: "8e812436a0e3323166e1f0e8ba79e19e217b2c4a53c970d4cca0cfb1078979df"), coin: Coin.tron)
        XCTAssertEqual(
            try! privatekey.signatureTron(rawTransaction: Data(hex: "159817a085f113d099d3d93c051410e9bfe043cc5c20e43aa9a083bf73660145")),
            "38b7dac5ee932ac1bf2bc62c05b792cd93c3b4af61dc02dbb4b93dacb758123f08bf123eabe77480787d664ca280dc1f20d9205725320658c39c6c143fd5642d00"
        )
    }
    
    func testEthereumMainNetTransaction() {
        let rawTransaction = EthereumRawTransaction(
            value: Wei("5000000000000000000")!,
            to: "0xfc9d3987f7fcd9181393084a94814385b28cEf81",
            gasPrice: 99000000000,
            gasLimit: 200000,
            nonce: 0
        )
        let privatekey = PrivateKey(raw: Data(hex: "db173e58671248b48d2494b63a99008be473268581ca1eb78ed0b92e03b13bbc"), coin: Coin.ethereum)
        XCTAssertEqual(
            try! privatekey.signatureETH_ETC(rawTransaction: rawTransaction, chainId: 1),
            "0xf86d8085170cdc1e0083030d4094fc9d3987f7fcd9181393084a94814385b28cef81884563918244f400008025a07f47866c109ce1fbc0b4c9d4c5825bcd9be13903a082256d70c8cf6c05a59bfca045f6b0407996511b30f72fbb567e0b0dbaa367b9b920f73ade435f8e0e2776b6"
        )
    }
    
    func testEthereumClassictTransaction() {
        let rawTransaction = EthereumRawTransaction(
            value: Wei("5000000000000000000")!,
            to: "0xfc9d3987f7fcd9181393084a94814385b28cEf81",
            gasPrice: 99000000000,
            gasLimit: 200000,
            nonce: 0
        )
        let privatekey = PrivateKey(raw: Data(hex: "db173e58671248b48d2494b63a99008be473268581ca1eb78ed0b92e03b13bbc"), coin: Coin.ethereumclassic)
        XCTAssertEqual(
            try! privatekey.signatureETH_ETC(rawTransaction: rawTransaction, chainId: 0),
            "0xf86d8085170cdc1e0083030d4094fc9d3987f7fcd9181393084a94814385b28cef81884563918244f40000801ca056c97be14a853f1700ed34cacf7c17e8ec0c2bf1cce56f73646c78b22718e8a7a05a6819fdf1da87dcb97cc07d76f30cf3851cb630bb2c029125baf93003384eb0"
        )
    }
    
    func testEthereumTestNetTransaction() {
        // RINKEBY
        let rawTransaction = EthereumRawTransaction(
            value: Wei("1000000000000000")!,
            to: "0x88b44BC83add758A3642130619D61682282850Df",
            gasPrice: 99000000000,
            gasLimit: 21000,
            nonce: 0
        )
        
        let privatekey = PrivateKey(raw: Data(hex: "0ac03c260512582a94295185cfa899e0cb8067a89a61b7b5435ec524c088203c"), coin: Coin.ethereum)
        XCTAssertEqual(
            try! privatekey.signatureETH_ETC(rawTransaction: rawTransaction, chainId: 4),
            "0xf86b8085170cdc1e008252089488b44bc83add758a3642130619d61682282850df87038d7ea4c68000802ca003737eaec6d92a570c34d31167759b695e76ffd27bee3c6ddcd614bcf3e682a6a00e8e0139edd8045d3772e3d20f213acf03c4ee5d1e7797e1d9617fd443ea9e65"
        )
    }
    
    func testErhereumERC20Transaction() {
        
        let erc20Token = ERC20(contractAddress: "test", decimal: 18, symbol: "TEST")
        
        let address = "0x88b44BC83add758A3642130619D61682282850Df"
        let data1 = try! erc20Token.generateDataParameter(toAddress: address, amount: "3")
        XCTAssertEqual(
            data1.toHexString().addHexPrefix(),
            "0xa9059cbb00000000000000000000000088b44bc83add758a3642130619d61682282850df00000000000000000000000000000000000000000000000029a2241af62c0000"
        )
        
        let data2 = try! erc20Token.generateDataParameter(toAddress: address, amount: "0.25")
        XCTAssertEqual(
            data2.toHexString().addHexPrefix(),
            "0xa9059cbb00000000000000000000000088b44bc83add758a3642130619d61682282850df00000000000000000000000000000000000000000000000003782dace9d90000"
        )
        
        let data3 = try! erc20Token.generateDataParameter(toAddress: address, amount: "0.155555")
        XCTAssertEqual(
            data3.toHexString().addHexPrefix(),
            "0xa9059cbb00000000000000000000000088b44bc83add758a3642130619d61682282850df0000000000000000000000000000000000000000000000000228a472c6093000"
        )
        
        let data4 = try! erc20Token.generateDataParameter(toAddress: address, amount: "3000")
        XCTAssertEqual(
            data4.toHexString().addHexPrefix(),
            "0xa9059cbb00000000000000000000000088b44bc83add758a3642130619d61682282850df0000000000000000000000000000000000000000000000a2a15d09519be00000"
        )
        
        let data5 = try! erc20Token.generateDataParameter(toAddress: address, amount: "9000")
        XCTAssertEqual(
            data5.toHexString().addHexPrefix(),
            "0xa9059cbb00000000000000000000000088b44bc83add758a3642130619d61682282850df0000000000000000000000000000000000000000000001e7e4171bf4d3a00000"
        )
    }
    
    func testEOSTransaction(){
        let privatekey = try! PrivateKey.init(base58Str: "5KWW6Y3JABpfek1KPGecq71TmUTQjjvLkyXw359QV8CwqUjMXvT")
        XCTAssertEqual(
            try privatekey.signatureEOS(tosign: "aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906"),
            "SIG_K1_KgLRcMwgDq3GxagVUfr7NvfCTsruv7hkS95T22Df3tAki3BvCpWCisDWTXSbpuKjx82FGHC5RVSuBn3hYpWanQBCynzABg"
        )
    }
}
