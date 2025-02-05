import Foundation

@objc(FormbricksConfig) public class FormbricksConfig: NSObject {
    let appUrl: String
    let environmentId: String
    let userId: String?
    let attributes: [String:String]?
    let logLevel: LogLevel
    
    init(appUrl: String, environmentId: String, userId: String?, attributes: [String : String]?, logLevel: LogLevel) {
        self.appUrl = appUrl
        self.environmentId = environmentId
        self.userId = userId
        self.attributes = attributes
        self.logLevel = logLevel
    }
    
    @objc(FormbricksConfigBuilder) public class Builder: NSObject {
        var appUrl: String
        var environmentId: String
        var userId: String?
        var attributes: [String:String] = [:]
        var logLevel: LogLevel = .error
        
        @objc public init(appUrl: String, environmentId: String) {
            self.appUrl = appUrl
            self.environmentId = environmentId
        }
        
        @objc public func set(userId: String) -> Builder {
            self.userId = userId
            return self
        }
        
        @objc public func set(attributes: [String:String]) -> Builder {
            self.attributes = attributes
            return self
        }
        
        @objc public func add(attribute: String, forKey key: String) -> Builder {
            self.attributes[key] = attribute
            return self
        }
        
        @objc public func setLogLevel(_ logLevel: LogLevel) -> Builder {
            self.logLevel = logLevel
            return self
        }
        
        @objc public func build() -> FormbricksConfig {
            return FormbricksConfig(appUrl: appUrl, environmentId: environmentId, userId: userId, attributes: attributes, logLevel: logLevel)
        }
    }
}
