@objc public enum FormbricksSDKErrorType: Int {
    case sdkIsNotInitialized
    case sdkIsAlreadyInitialized
    case invalidAppUrl
    case unableToRefreshEnvironment
    case unableToPersistEnvironment
    case unableToRetrieveEnvironment
    case invalidJavascriptMessage
    
    public var description: String {
        switch self {
        case .sdkIsNotInitialized:
            return "The SDK is not initialized"
        case .sdkIsAlreadyInitialized:
            return "The SDK is already initialized"
        case .invalidAppUrl:
            return "Invalid App URL"
        case .unableToRefreshEnvironment:
            return "Unable to refresh environment object. Will try again in \(Config.Environment.refreshStateOnErrorTimeoutInMinutes) minutes."
        case .unableToPersistEnvironment:
            return "Unable to persist environment object."
        case .unableToRetrieveEnvironment:
            return "Unable to retrieve environment object."
        case .invalidJavascriptMessage:
            return "Invalid Javascript Message"
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
