import Foundation

public typealias ResultType<T> = Result<T, Error>
public struct VoidResponse: Codable {}

// MARK: - Method types -
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Encoding type -
public enum EncodingType {
    case url
    case json
}

// MARK: - Base API protocol -
public protocol BaseApiRequest {
    var requestEndPoint: String { get }
    var requestType: HTTPMethod { get }
    var encoding: EncodingType { get }
    var headers: [String:String]? { get }
    var requestBody: Data? { get }
}

public extension BaseApiRequest {
  
    var encoding: EncodingType {
        return .json
    }
  
    var requestBody: Data? {
        return nil
    }
  
    var headers: [String:String]? {
        return [:]
    }
}

// MARK: - Codable protocol -
public protocol CodableRequest: BaseApiRequest {
    associatedtype Response: Decodable
    associatedtype ErrorType: Error & Decodable
  
    var baseURL: String? { get }
  
    var decoder: JSONDecoder { get }
  
    var queryParams: [String: String]? { get }
}

public extension CodableRequest {
    typealias ErrorType = RuntimeError
    
    var baseURL: String? {
        return Formbricks.appUrl
    }
  
    var decoder: JSONDecoder {
        return JSONDecoder.iso8601Full
    }
  
    var queryParams: [String: String]? {
        return nil
    }
}

// MARK: - Encodable protocol -
open class EncodableRequest<EncodableObject: Encodable> {
    public let object: EncodableObject
    public let encoder: JSONEncoder
  
    public init(object: EncodableObject, encoder: JSONEncoder = JSONEncoder.iso8601Full) {
        self.object = object
        self.encoder = encoder
    }
  
    public var requestBody: Data? {
        guard let data = try? self.encoder.encode(self.object) else {
            assertionFailure("Unable to encode object: \(self.object)")
            return nil
        }
        return data
    }
}
