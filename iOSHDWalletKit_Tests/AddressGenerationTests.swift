//
//  AddressGenerationTests.swift
//  iOSHDWalletKit
//
//  Created by kim kwang tae on 04/10/2018.
//  Copyright © 2018 kgthtg@gmail.com. All rights reserved.
//

import XCTest
@testable import iOSHDWalletKit

class AddressGenerationTests: XCTestCase {
    func testBitcoinMainnetChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.bitcoin)

        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )
        
        // m/44'/0'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprvA2QWrMvVn11Cnc8Wv5XH22Phaz1eLLYUtUVCJxjRu3eSbPZk3WphdkqGBnAKiKtg3bxkL48zbf9C8jJKtbDhB4kTJuNfv3KZVRjxseHNNWk"
        )
      
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6FPsFsTPcNZW16Cz274HPALS91r8joGLFhQo7M93TPBRUBttb48xBZ9k34oiG29Bvqfry9QyXPsGXSRE1kjut92Dgik1w6Whm1GU4F122n8"
        )
      
        // m/44'/0'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "128BCBZndgrPXzEgF4QbVR3jnQGwzRtEz5"
        )
      
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "03ce9b978595558053580d557ff40f9f99a4f1a7609c25268863ee64de7e4abbda"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "L35qaFLpbCc9yCzeTuWJg4qWnTs9BaLr5CDYcnJ5UnGmgLo8JBgk"
        )
    }
    
    func testBitcoinTestnetChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.bitcointest)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "tprv8ZgxMBicQKsPdM3GJUGqaS67XFjHNqUC8upXBhNb7UXqyKdLCj6HnTfqrjoEo6x89neRY2DzmKXhjWbAkxYvnb1U7vf4cF4qDicyb7Y2mNa"
        )
        
        // m/44'/1'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "tprv8hJrzKEmbFfBx44tsRe1wHh25i5QGztsawJGmxeqryPwdXdKrgxMgJUWn35dY2nrYmomRWWL7Y9wJrA6EvKJ27BfQTX1tWzZVxAXrR2pLLn"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "tpubDDzu8jH1jdLrqX6gm5JcLhM8ejbLSL5nAEu44Uh9HFCLU1t6V5mwro6NxAXCfR2jUJ9vkYkUazKXQSU7WAaA9cbEkxdWmbLxHQnWqLyQ6uR"
        )
        
        // m/44'/1'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "mq1VMMXiZKLdY2WLeaqocJxXijhEFoQu3X"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "037e63dc23f0f6ecb0b2ab8a649f0e2966e9c6ceb10f901e0e0b712cfed2f78449"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "cMwbkii126fSsPtWBUuUPrKZS5KK3qCjSNuRhcuw6sJ8HmVsrmHq"
        )
    }
    
    func testLitecoinChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.litecoin)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "Ltpv71G8qDifUiNesWTK5oTxZCgsQPmwEK7XDLvxGmLZd9dTCXf85zX6dZ13uLAbfTCzhTgvcSFkm3eZGAAW2sBxce7DYrPwFqPp71VTCrCjfVS"
        )
        
        // m/44'/2'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "Ltpv79U5zPwp3fa7nmyZsUwHfv2AV18wu7XhbX4pEyMbBqaJhM4D1yWjHwi8NoLWHQhfhbujNmCVYDbXZRWGarfxCTcohB9NNVV7UPvsGGCqypV"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "Ltub2aeRbBNMHp75QegQ86RfkVrNvZq8yN6Mg3Aqux7t82MuHiFHLtZAJYpPd9fMBggcYNWD7hjteuMf2j9NtEsqU2P6koBMPEsnLJYAMDc3PRu"
        )
        
        // m/44'/2'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "LV8fThzQw45HT6bCgs1yfvLNzv4aFvjJt1"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "026eeb12b93ab20b32970e2fa0e7fbaa97f9016dc743ad3efc922681ce33adc40d"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "T3d12aqL7XSNqMojMtqBZGhQ6E93dzrdbnNUKMvdmVTa9TQn4L3m"
        )
    }
    
    func testDogecoinChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.dogecoin)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "dgpv51eADS3spNJh8Q6Qzz9L6AABYtvRnEGqvSFKXrxzhwK54fWAHo3NrGHvagERrteHgWo6rifQ9GxswUAYR4Exh9zekTNz6FUhJFAjhae3ptn"
        )
        
        // m/44'/3'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "dgpv5AufugPa1MKZyzejYrvnPMsZPRDrWPQp9DUHmuGwDdNjcZBm9q36NSYW4u4H1GW6tt2jni6iXerZXvuMdKK8bspeZFgwt776CYijo5mPD2s"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "dgub8unhFNKTZVyuGrJtb6YkWDR9qybVLWSXRpFVw1fv1kRkAcJTZbas1jx9eB8dfhxHu2KR76ikLAXsK9zHTa5jejLRu6oRoi9Ap1LjtGMdC58"
        )
        
        // m/44'/3'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "DSsPuTmCThdr1qkgJ49K1mHskypbi2LTrS"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "0372caf38ff987350d04a24cad8436b3c9337d9bc0ebab2a39682d621c34ddc99b"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "QTnRacz8UbyvfETqNggkdicojnAYdY86tNMmh8Gns8EFbZU19NjJ"
        )
    }
    
    func testDashChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.dash)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )

        // m/44'/5'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprvA1NqQQS57G29wPpUuzMybxLSEEQLBFMj8Qk7JuENTAAvXPaGxRaECbb8GYtRvfHnXyJ2yPjJYUKY3Sn3NAPveh3X6azyZg2hwuuBQ6u7sRU"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6ENBouxxwdaT9stx21tyy6HAnGEpai5aVdfi7Hdz1VhuQBuRVxtUkPuc7p5gE56EPSZwEB1GLTZ7ybpLHmztsgd1UskUAJeo2SA6fTVghe6"
        )
        
        // m/44'/5'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "Xud1fZjupDuhndpYtTquDPmSWmehtEbxhy"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "02f1dfce053d0a9aadb8f63ab4490ac84b33ad018c62dbabb9ff2352fe62fc4619"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "XCHbiHeTfzwhryHEZTp3ojAM1nYpKwL575ieLLv7s4q1f5ZEm1vP"
        )
    }
    
    func testEtherChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.ethereum)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )
        
        // m/44'/60'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprv9zZ5CJCDXmdQYwGPc3j33VQYAPi9quxMjTcMD9Vvm9X1gCkPiWZS73BRvebBi1yFZLia21844tvRedJq7mYuWnFBwHzvParmy2U7ns6Nyk2"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6DYRboj7N9BhmRLri5G3QdMGiRYeFNgD6gXx1XuYKV3zZ15YG3sgeqVumtWjhemR3P7x9vmLe9CBKtbVkGH5LK4VxUyaQcuLNJrvdEx5MsU"
        )
        
        // m/44'/60'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "0x83f1caAdaBeEC2945b73087F803d404F054Cc2B7"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "039966a68158fcf8839e7bdbc6b889d4608bd0b4afb358b073bed1d7b70dbe2f4f"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "df02cbea58239744a8a6ba328056309ae43f86fec6db45e5f782adcf38aacadf"
        )
    }
    
    func testEtherClassicChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.ethereumclassic)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )
        
        // m/44'/61'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprvA2G4hFWBeQRoTk7EJo5prBxhHaCZ22FgBRdNt2oHbfP2johzzWbucZd1M8q1mA2YyeqG1jSncpoxmDYX41zKAKXos1dVei9AMdfNCVU4n1z"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6FFR6m35Umz6gEBhQpcqDKuRqc33RUyXYeYygRCu9zv1cc39Y3vAAMwVCRoaZ4CHmobvVYsSXUng6YUKvStdobA6yfVL6PuNsVDu9u3z1fx"
        )
        
        // m/44'/61'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "0x78624D389BA8e77e238496D4A75d7D18a7c388Df"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "03e89ff3d0a71a4b5e6758d1f0869c5e274073609065aa0620ec99c3674751d97b"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "1c650df3d64b3c37928b910adec190571c342ba13361af624f3fa5770d7f5024"
        )
    }
    
    func testZCashChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.zcash)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )
        
        // m/44'/133'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprvA21Yn8PDgWMzCu7ZS7TLxuHgM1XkQFARz1zZXM9UbCA8VVHkmrjmnXBVb69ANhVf4P1htH9YoKrgM9m9PZ8hgehEpjujSiktuoScmYKMekb"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6EzuBdv7WsvHRPC2Y8zML3EQu3NEohtHMEvAKjZ69Xh7NHcuKQ42LKVySPiFCM6zr8NEWVxsN4BZsHJeuid7twAK5Kvjt7sxUrX9LiqB4YL"
        )
        
        // m/44'/133'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "t1K1uJt7phu12WyCHzHqqMdXCJWxeExUgYi"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "02f769f4efdf19380bc311711ec3a21c3c032a81823e582d60bfa2a0f3976e0349"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "L5mKmeA7eGDPjpYqunW27hi6gBroJYvLsuWyKJHCE5H7jCaQdADC"
        )
    }
    
    func testRippleChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.ripple)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )
        
        // m/44'/144'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprv9zvSEeE6Nsr8GJgXud8HUEHJKKPqVjGEhXe67uruFcaUZWb2FbzosjJjrpUfwFV3tw7Hx8HcWEcB1oDeFKpHHGyWZ6cs9rpaPG2bMJDWUWM"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6Dune9kzDFQRUnm11efHqNE2sMEKuBz64kZgvJGWox7TSJvAo9K4RXdDi7MeDKHmTvTJiozyNEYLHv1hhTj911ZyWCNjRwxtva624J6vkwB"
        )
        
        // m/44'/144'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "rJ827UnPxMt1QQmLvoCG7kpikB1p41hB83"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "03dd5e1608f7159ae0d0bb87d8ce0c1ab753a8abea8be0974a9ab53273eaf26a5e"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "c0d3d6a5dc5fa2822933de8c02ef562d9ee729fec16f49d55d6a3922b8ef5292"
        )
    }
    
    func testBitcoinCashChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.bitcoinCash)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )
        
        // m/44'/145'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprvA2Hsqw7xpNHxiyTRuN9unWRm44Phad3XcheaxuTz9wUaQz7C1msejmT17cZCWuLyq53uBtSkcwYmfia1pMXSyQXZhZjBb8K8z9AEmGWpZdd"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6FHEFSerejrFwTXu1Pgv9eNVc6EBz5mNyvaBmHsbiH1ZHnSLZKBuHZmUxtxLzgc7Bc5RMAw6qHKuxpzJDLyLuLUxMooCG5BmbQ3M1cEvmdv"
        )
        
        // m/44'/145'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "bitcoincash:qz0eqtpupzxvx5h2u93tew8mq4qtglyhzyjdq3ezw0"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "030f6c58f37ffe1bf56dd79fac07f339f44d96efaa3d78e1f32fadd41dcd0b7bbc"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "KwgDcj2ZDN5vzRXsTv1F6vzQV7nx7shEYjFBcWng1sH6Fy9rhK2b"
        )
    }
    
    func testBitcoinCashAddressGeneration() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet(seed: seed, coin: Coin.bitcoinCash)
      
        let firstAddress = wallet.generateAddress(at: 0)
        XCTAssertEqual(firstAddress, "bitcoincash:qz0eqtpupzxvx5h2u93tew8mq4qtglyhzyjdq3ezw0")
    
        let cashfirstAddress = try? AddressFactory.create(firstAddress)
        XCTAssertNotNil(cashfirstAddress)
        XCTAssertEqual(cashfirstAddress?.base58, "1FYh9oXWbAzgcX3hPSrRWUodYWt87bMmne")
    
        let secondAddress = wallet.generateAddress(at: 1)
        XCTAssertEqual(secondAddress, "bitcoincash:qpwphvnuxqxxg9z9m4f7vkuyrzu5twjasqyfxl5x3g")
    
        let cashsecondAddress = try? AddressFactory.create(secondAddress)
        XCTAssertNotNil(cashsecondAddress)
        XCTAssertEqual(cashsecondAddress?.base58, "19Q2M5swtorWmL9ZdhtaxBFFuhUuBr9z1Q")
      
        let thirdAddress = wallet.generateAddress(at: 2)
        XCTAssertEqual(thirdAddress, "bitcoincash:qrlf04xqfxaum4w7dsk7s8q5utulazggfunjpz7tes")
    
        let cashthirdAddress = try? AddressFactory.create(thirdAddress)
        XCTAssertNotNil(cashthirdAddress)
        XCTAssertEqual(cashthirdAddress?.base58, "1QDAX8eZXMjVdZxMzHyXr81uWu9ZDWd9vR")
    
        let forthAddress = wallet.generateAddress(at: 3)
        XCTAssertEqual(forthAddress, "bitcoincash:qrqlur3v8zl500w8k5lkas4re7d70zmxtqnqp5htct")
    
        let cashforthAddress = try? AddressFactory.create(forthAddress)
        XCTAssertNotNil(cashforthAddress)
        XCTAssertEqual(cashforthAddress?.base58, "1Jgjm6m4ETPGezaoTBdJCJV7RCjDRR9Ddf")
    }
    
    func testEosChildKeyDerivation() {
        // https://github.com/rudijs/eos-bip39-mnemonic-generator
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.eos)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )
        
        // m/44'/60'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprv9zZ5CJCDXmdQYwGPc3j33VQYAPi9quxMjTcMD9Vvm9X1gCkPiWZS73BRvebBi1yFZLia21844tvRedJq7mYuWnFBwHzvParmy2U7ns6Nyk2"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6DYRboj7N9BhmRLri5G3QdMGiRYeFNgD6gXx1XuYKV3zZ15YG3sgeqVumtWjhemR3P7x9vmLe9CBKtbVkGH5LK4VxUyaQcuLNJrvdEx5MsU"
        )
        
        // m/44'/60'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "EOS7znxBJ9ibQduky1Y17416hWydodg5km8rMisRLrZ3WarYMWycw"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "039966a68158fcf8839e7bdbc6b889d4608bd0b4afb358b073bed1d7b70dbe2f4f"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "5KWW6Y3JABpfek1KPGecq71TmUTQjjvLkyXw359QV8CwqUjMXvT"
        )
        
        let privatekey = try! PrivateKey.init(base58Str: "5KWW6Y3JABpfek1KPGecq71TmUTQjjvLkyXw359QV8CwqUjMXvT")
        XCTAssertEqual(
            privatekey.get(),
            "5KWW6Y3JABpfek1KPGecq71TmUTQjjvLkyXw359QV8CwqUjMXvT"
        )
        
        let publickey = privatekey.publicKey.address
        XCTAssertEqual(
            publickey,
            "EOS7znxBJ9ibQduky1Y17416hWydodg5km8rMisRLrZ3WarYMWycw"
        )
    }
    
    func testTronChildKeyDerivation() {
        let entropy = Data(hex: "000102030405060708090a0b0c0d0e0f")
        let mnemonic = Mnemonic.create(entropy: entropy)
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet.init(seed: seed, coin: Coin.tron)
        
        XCTAssertEqual(
            wallet.privateKey.extended,
            "xprv9s21ZrQH143K2XojduRLQnU8D8K59KSBoMuQKGx8dW3NBitFDMkYGiJPwZdanjZonM7eXvcEbxwuGf3RdkCyyXjsbHSkwtLnJcsZ9US42Gd"
        )
        
        // m/44'/60'/0'/0
        XCTAssertEqual(
            wallet.bip44PrivateKey.extended,
            "xprv9zZ5CJCDXmdQYwGPc3j33VQYAPi9quxMjTcMD9Vvm9X1gCkPiWZS73BRvebBi1yFZLia21844tvRedJq7mYuWnFBwHzvParmy2U7ns6Nyk2"
        )
        
        XCTAssertEqual(
            wallet.bip44PrivateKey.publicKey.extended,
            "xpub6DYRboj7N9BhmRLri5G3QdMGiRYeFNgD6gXx1XuYKV3zZ15YG3sgeqVumtWjhemR3P7x9vmLe9CBKtbVkGH5LK4VxUyaQcuLNJrvdEx5MsU"
        )
        
        // m/44'/60'/0'/0/0
        let firstAccount = wallet.generateAccount(at: 0)
        XCTAssertEqual(
            firstAccount.address,
            "TMzsBAuA8KodJkrGo8TJ5UxMU4z35zJYUg"
        )
        
        XCTAssertEqual(
            firstAccount.rawPublicKey,
            "039966a68158fcf8839e7bdbc6b889d4608bd0b4afb358b073bed1d7b70dbe2f4f"
        )
        
        XCTAssertEqual(
            firstAccount.rawPrivateKey,
            "df02cbea58239744a8a6ba328056309ae43f86fec6db45e5f782adcf38aacadf"
        )
    }
}
