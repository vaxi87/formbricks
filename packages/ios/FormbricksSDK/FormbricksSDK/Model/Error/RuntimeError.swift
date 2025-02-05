public struct RuntimeError: Error, Codable {
    let message: String
    
    public var localizedDescription: String {
        return message
    }
}
