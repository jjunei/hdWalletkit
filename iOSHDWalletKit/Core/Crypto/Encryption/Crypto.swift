import CryptoSwift
import secp256k1

final class Crypto {
    public static func sha256ripemd160(_ data: Data) -> Data {
        return RIPEMD160.hash(sha256(data))
    }
    
    static func HMACSHA256(key: Data, data: Data) -> Data {
        let output: [UInt8]
        do {
            output = try HMAC(key: key.bytes, variant: .sha256).authenticate(data.bytes)
        } catch let error {
            fatalError("Error occured. Description: \(error.localizedDescription)")
        }
        return Data(output)
    }
    
    static func HMACSHA512(key: Data, data: Data) -> Data {
        let output: [UInt8]
        do {
            output = try HMAC(key: key.bytes, variant: .sha512).authenticate(data.bytes)
        } catch let error {
            fatalError("Error occured. Description: \(error.localizedDescription)")
        }
        return Data(output)
    }
    
    static func PBKDF2SHA512(password: [UInt8], salt: [UInt8]) -> Data {
        let output: [UInt8]
        do {
            output = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 2048, variant: .sha512).calculate()
        } catch let error {
            fatalError("PKCS5.PBKDF2 faild: \(error.localizedDescription)")
        }
        return Data(output)
    }
    
    static func generatePublicKey(data: Data, compressed: Bool) -> Data {
        return ECDSA.secp256k1.generatePublicKey(with: data, isCompressed: compressed)
    }
    
    static func sha3keccak256(data:Data) -> Data {
        return data.sha3(.keccak256)
    }
    
    static func sign(_ hash: Data, privateKey: Data) throws -> Data {
        let encrypter = EllipticCurveEncrypterSecp256k1()
        guard var signatureInInternalFormat = encrypter.sign(hash: hash, privateKey: privateKey) else {
            throw iOSHDWalletKitError.failedToSign
        }
        return encrypter.export(signature: &signatureInInternalFormat)
    }
    
    public static func sha256(_ data: Data) -> Data {
        return Data.init(Digest.sha256(data.bytes))
    }
    
    public static func sign(_ data: Data, privateKey: PrivateKey) throws -> Data {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }
        
        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate() }
        let status = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            privateKey.raw.withUnsafeBytes { secp256k1_ecdsa_sign(ctx, signature, ptr, $0, nil, nil) }
        }
        guard status == 1 else { throw CryptoError.signFailed }
        
        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate() }
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)
        
        var length: size_t = 128
        var der = Data(count: length)
        guard der.withUnsafeMutableBytes({ return secp256k1_ecdsa_signature_serialize_der(ctx, $0, &length, normalizedsig) }) == 1 else { throw CryptoError.noEnoughSpace }
        der.count = length
        
        return der
    }
}

// MARK: SHA256 of SHA256
extension Data {
    var doubleSHA256: Data {
        return sha256().sha256()
    }
}

public enum CryptoError: Error {
    case signFailed
    case noEnoughSpace
    case signatureParseFailed
    case publicKeyParseFailed
}

