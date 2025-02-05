@objc public enum FormbricksSDKErrorType: Int {
    case sdkIsNotInitialized
    case sdkIsAlreadyInitialized
    case invalidApiHost
    case unableToRefreshEnvironment
    case unableToPersistEnvironment
    case unableToRetrieveEnvironment
    
    public var description: String {
        switch self {
        case .sdkIsNotInitialized:
            return "The SDK is not initialized"
        case .sdkIsAlreadyInitialized:
            return "The SDK is already initialized"
        case .invalidApiHost:
            return "Invalid API host"
        case .unableToRefreshEnvironment:
            return "Unable to refresh environment object. Will try again in \(Config.Environment.refreshStateOnErrorTimeoutInMinutes) minutes."
        case .unableToPersistEnvironment:
            return "Unable to persist environment object."
        case .unableToRetrieveEnvironment:
            return "Unable to retrieve environment object."
        }
    }
}

@objc(FormbricksSDKError) public class FormbricksSDKError: NSObject, LocalizedError {
    @objc public let type: FormbricksSDKErrorType
    public var errorDescription: String
    
    public init(type: FormbricksSDKErrorType) {
        self.type = type
        self.errorDescription = type.description
    }
}
