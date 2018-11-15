import Foundation

fileprivate var hexPrefix = "0x"

extension String {
    
    public func stripHexPrefix() -> String {
        var hex = self
        if hex.hasPrefix(hexPrefix) {
            hex = String(hex.dropFirst(hexPrefix.count))
        }
        return hex
    }
    
    public func addHexPrefix() -> String {
        return hexPrefix.appending(self)
    }
    
    public func toHexString() -> String {
        guard let data = data(using: .utf8) else {
            return ""
        }
        return data.map { String(format: "%02x", $0) }.joined()
    }
    
    func getBytes() -> [UInt8] {
        return Array(self.utf8)
    }
    
    func getSubString(_ beginIndex: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: beginIndex)
        let end = self.index(self.startIndex, offsetBy: self.count)
        return String(self[start..<end])
    }
    
    func getSubString(_ beginIndex: Int, endIndex: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: beginIndex)
        let end = self.index(self.startIndex, offsetBy: endIndex)
        return String(self[start..<end])
    }
}
