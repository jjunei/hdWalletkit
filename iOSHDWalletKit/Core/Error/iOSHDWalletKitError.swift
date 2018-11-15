import Foundation

public enum iOSHDWalletKitError: Error {
    public enum CryptoError {
        case failedToEncode(element:Any)
    }
    
    public enum ContractError: Error {
        case containsInvalidCharactor(Any)
        case invalidDecimalValue(Any)
    }
    
    case cryptoError(CryptoError)
    case contractError(ContractError)
    case failedToSign
    case unknownError
}
