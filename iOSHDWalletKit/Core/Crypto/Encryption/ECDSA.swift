import Foundation
import CryptoSwift
import secp256k1
import BigInt

class SigChecker {
    
    let e: BigInt;
    let privKey: BigInt;
    var r: BigInt?;
    var s: BigInt?;
    
    init(hash: [UInt8],
         privKey: BigInt){
        self.e = BigInt(sign: .plus, magnitude: BigUInt(Data(bytes: hash)))
        self.privKey = privKey;
    }
    
    func checkSignature(curveParam: CurveParam,
                        k: BigInt)->Bool{
        if let g = curveParam.getG(),
            let n = curveParam.getN(){
            let Q = EcTools.shared.multiply(g, k)
            if Q.isInfinity() {
                return false;
            }
            self.r = Q.getX()?.toBigInteger().mod(n)
            if let R = self.r,
                R.signum() != BigInt(0) {
                self.s = k.modInverse(n)?.multiply(e.add(privKey.multiply(R))).mod(n)
                if let S = self.s,
                    S.signum() != 0{
                    return true;
                }
            }
        }
        return false;
    }
    
    func isRSEachLength(_ length: Int) ->Bool{
        if let R = self.r,
            let S = self.s{
            return (R.toByteArray().count == length) &&
                (S.toByteArray().count == length)
        }
        return false;
    }
}

public final class ECDSA {
    public static let secp256k1 = ECDSA()
    
    public func generatePublicKey(with privateKey: Data, isCompressed: Bool) -> Data {
        return generatePublicKey(privateKeyData: privateKey, isCompression: isCompressed)!
    }
    
    func generatePublicKey(privateKeyData: Data, isCompression: Bool) -> Data? {
        
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        
        let prvKey = privateKeyData.bytes
        var pKey = secp256k1_pubkey()
        
        var result = SecpResult(secp256k1_ec_pubkey_create(context, &pKey, prvKey))
        if result == .failure {
            return nil
        }
        let compressedKeySize = 33
        let decompressedKeySize = 65
        
        let keySize = isCompression ? compressedKeySize : decompressedKeySize
        let serealizedKey = UnsafeMutablePointer<UInt8>.allocate(capacity: keySize)

        var keySizeT = size_t(keySize)
        let copressingKey = isCompression ? UInt32(SECP256K1_EC_COMPRESSED) : UInt32(SECP256K1_EC_UNCOMPRESSED)
        
        result = SecpResult(secp256k1_ec_pubkey_serialize(context,
                                               serealizedKey,
                                               &keySizeT,
                                               &pKey,
                                               copressingKey))
        if result == .failure {
            return nil
        }
        
        secp256k1_context_destroy(context)
        
        let data = Data(bytes: serealizedKey, count: keySize)
        free(serealizedKey)
        return data
    }
    
    func deterministicGenerateK(curveParam: CurveParam,
                                hash: [UInt8],
                                d: BigInt,
                                checker: inout SigChecker,
                                nonce: Int ) -> BigInt? {
        var h = hash
        if nonce > 0 {
            h = (Sha256.from(byte1: hash,
                             byte2: BigInt(nonce).toByteArray())!.getBytes())!;
        }
        
        let dBytes: [UInt8] = d.toByteArray();
        var v = Array<UInt8>(repeating: 0x01, count: 32);
        var k = Array<UInt8>(repeating: 0x00, count: 32);
        let bwD = EosByteWriter(capacity: (32 + 1 + 32 + 32))
        bwD.putBytes(value: v)
        bwD.put(b: 0x00)
        bwD.putBytes(value: dBytes)
        bwD.putBytes(value: h)
        
        do {
            k = try HMAC(key: k, variant: .sha256).authenticate(bwD.toBytes())
            v = try HMAC(key: k, variant: .sha256).authenticate(v)
            let bwF = EosByteWriter(capacity: (32 + 1 + 32 + 32))
            bwF.putBytes(value: v)
            bwF.put(b: 0x01)
            bwF.putBytes(value: dBytes)
            bwF.putBytes(value: h)
            k = try HMAC(key: k, variant: .sha256).authenticate(bwF.toBytes())
            v = try HMAC(key: k, variant: .sha256).authenticate(v)
            v = try HMAC(key: k, variant: .sha256).authenticate(v)
            var t = BigInt(sign: .plus, magnitude: BigUInt(Data(bytes: v)))
            if let n = curveParam.getN() {
                while t.signum() <= BigInt(0) ||
                    (t.compareTo(n) >= 0) ||
                    (checker.checkSignature(curveParam: curveParam, k: t) == false){
                        let bwH = EosByteWriter(capacity: (32 + 1))
                        bwH.putBytes(value: v)
                        bwH.put(b: 0x00)
                        k = try HMAC(key: k, variant: .sha256).authenticate(bwH.toBytes())
                        v = try HMAC(key: k, variant: .sha256).authenticate(v)
                        v = try HMAC(key: k, variant: .sha256).authenticate(v)
                        t = BigInt(BigUInt(Data(bytes: v)))
                }
                return t
            }
        } catch {
            
        }
        return nil
    }
    
    func sign(hash: Sha256,
              key: PrivateKey) -> EcSignature? {
        if let curveParam = key.getCurveParam(),
            let h = hash.getBytes(),
            let privAsBI = key.getAsBigInteger() {
            let pubKey = key.publicKey
            var checker: SigChecker = SigChecker(hash: h,
                                                 privKey: privAsBI)
            var nonce = 0;
            while true {
                self.deterministicGenerateK(curveParam: curveParam,
                                            hash: h,
                                            d: privAsBI,
                                            checker: &checker,
                                            nonce: nonce)
                nonce = nonce + 1
                if checker.s!.compareTo(curveParam.halfCurveOrder()!) > 0 {
                    checker.s = curveParam.getN()!.subtract(checker.s!)
                }
                if  checker.isRSEachLength(32) {
                    break
                }
            }
            let signature = EcSignature(r: checker.r!,
                                        s: checker.s!,
                                        curveParam: curveParam)
            let data = h
            for i in 0..<4 {
                if let key = recoverPubKey(curveParam: curveParam,
                                           messageSigned: data,
                                           signature: signature,
                                           recId: i){
                    if pubKey.equals(key) {
                        signature.setRecid(i)
                        break
                    }
                }
            }
            if signature.recId < 0 {
                return nil
            }
            return signature
        }
        return nil
    }
    
    func recoverPubKey(messageSigned: [UInt8]?,
                       signature: EcSignature) -> PublicKey? {
        return recoverPubKey(curveParam: signature.curveParam,
                             messageSigned: messageSigned,
                             signature: signature,
                             recId: signature.recId);
    }
    
    func recoverPubKey(curveParam: CurveParam,
                       messageSigned: [UInt8]?,
                       signature: EcSignature,
                       recId: Int) -> PublicKey? {
        if recId >= 0,
            signature.r.compareTo(BigInt(0)) >= 0,
            signature.s.compareTo(BigInt(0)) >= 0,
            let signed = messageSigned,
            let n = curveParam.getN(),
            let curve = curveParam.getCurve() {
            let i = BigInt(recId/2)
            let x = signature.r.add(i.multiply(n))
            let prime = curve._q
            if (x.compareTo(prime) >= 0) {
                return nil
            }
            
            if let R = EcTools.shared.decompressKey(param: curveParam,
                                                    x: x,
                                                    firstBit: (recId & 1) == 1) {
                if !(R.multiply(n: n).isInfinity()) {
                    return nil
                }
                
                let e = BigInt(sign: .plus, magnitude: BigUInt(Data(signed)))
                let eInv: BigInt = BigInt(0).subtract(e).mod(n)
                let rInv: BigInt = signature.r.modInverse(n)!
                let srInv: BigInt = rInv.multiply(signature.s).mod(n)
                let eInvrInv: BigInt = rInv.multiply(eInv).mod(n)
                if let sub = EcTools.shared.sumOfTwoMultiplies(P: curveParam.getG()!,
                                                               k: eInvrInv,
                                                               Q: R,
                                                               l: srInv) {
                    let q = EcPoint(curve: curve,
                                    x: sub.getX(),
                                    y: sub.getY(),
                                    compressed: true)
                    if let encoded = q.getEncoded() {
                        return PublicKey(data: Data(bytes: encoded))
                    }
                }
            }
        }
        return nil
    }
}
