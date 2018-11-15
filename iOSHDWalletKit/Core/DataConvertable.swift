import Foundation

protocol DataConvertable {
    static func +(lhs: Data, rhs: Self) -> Data
    static func +=(lhs: inout Data, rhs: Self)
}

extension DataConvertable {
    static func +(lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return lhs + data
    }
    
    static func +=(lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension UInt8: DataConvertable {}
extension UInt16: DataConvertable {}
extension UInt32: DataConvertable {}
extension UInt64: DataConvertable {}
extension Int8: DataConvertable {}
extension Int16: DataConvertable {}
extension Int32: DataConvertable {}
extension Int64: DataConvertable {}
extension Int: DataConvertable {}

extension Bool: DataConvertable {
    static func +(lhs: Data, rhs: Bool) -> Data {
        return lhs + (rhs ? UInt8(0x01) : UInt8(0x00)).littleEndian
    }
}

extension String: DataConvertable {
    static func +(lhs: Data, rhs: String) -> Data {
        guard let data = rhs.data(using: .ascii) else { return lhs }
        return lhs + data
    }
}

func +(lhs: Data, rhs: OpCodeProtocol) -> Data {
    return lhs + rhs.value
}
func += (lhs: inout Data, rhs: OpCodeProtocol) {
    lhs = lhs + rhs
}

extension Data: DataConvertable {
    static func +(lhs: Data, rhs: Data) -> Data {
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        return data
    }
}

extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    func to(type: String.Type) -> String {
        return String(bytes: self, encoding: .ascii)!.replacingOccurrences(of: "\0", with: "")
    }
}

extension Data {    
    public var hex: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
