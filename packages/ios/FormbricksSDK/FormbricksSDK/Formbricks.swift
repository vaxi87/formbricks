import Foundation

@objc(Formbricks) public class Formbricks: NSObject {
    
    static internal var appUrl: String?
    static internal var environmentId: String?
    static internal var isInitialized: Bool = false
    
    static internal var apiQueue = OperationQueue()
    static internal var logger = Logger()
    static internal var service = FormbricksService()
    
    // make this class not instantiatable outside of the SDK
    internal override init() {}
    
    /**
     Initializes the Formbricks SDK with the given config ``FormbricksConfig``
          
     Example:
     ```swift
     let config = FormbricksConfig.Builder(appUrl: "APP_URL_HERE", environmentId: "TOKEN_HERE")
     .setLogLevel(.debug)
     .build()
      
     Formbricks.setup(with: config)
     ```
     */
    @objc public static func setup(with config: FormbricksConfig) {
        guard !isInitialized else {
            Formbricks.logger.error(FormbricksSDKError(type: .sdkIsAlreadyInitialized).message)
            return
        }
        
        self.appUrl = config.appUrl
        self.environmentId = config.environmentId
        self.logger.logLevel = config.logLevel
        
        SurveyManager.shared.refreshEnvironment()
        
        
        self.isInitialized = true
    }

    @objc public func setUserId(_ userId: String) {
        guard Formbricks.isInitialized else {
            Formbricks.logger.error(FormbricksSDKError(type: .sdkIsNotInitialized).message)
            return
        }
        // TODO: add userid to update queue
    }
    
    @objc public func setAttribute(_ attribute: String, forKey key: String) {
        guard Formbricks.isInitialized else {
            Formbricks.logger.error(FormbricksSDKError(type: .sdkIsNotInitialized).message)
            return
        }
        // TODO: add attribue to update queue
    }
    
    @objc public func setAttributes(_ attributes: [String : String]) {
        guard Formbricks.isInitialized else {
            Formbricks.logger.error(FormbricksSDKError(type: .sdkIsNotInitialized).message)
            return
        }
        // TODO: add attribues to update queue
    }
    
    @objc public func setLanguage(_ language: String) {
        guard Formbricks.isInitialized else {
            Formbricks.logger.error(FormbricksSDKError(type: .sdkIsNotInitialized).message)
            return
        }
        // TODO: add language to update queue
    }
    
    
    @objc public static func track(_ action: String) {
        guard Formbricks.isInitialized else {
            Formbricks.logger.error(FormbricksSDKError(type: .sdkIsNotInitialized).message)
            return
        }
        // TODO: create a survey manager that has the user and the environment and returns a survey id when a survey should be shown
        
        // TODO: init the webview
        
        // TODO: present the webview on the window
    }
    
    @objc public static func logout() {
        guard Formbricks.isInitialized else {
            Formbricks.logger.error(FormbricksSDKError(type: .sdkIsNotInitialized).message)
            return
        }

        // TODO: remove saved user data
    }
    
    @objc public static func test() {
        guard Formbricks.isInitialized else {
            Formbricks.logger.error(FormbricksSDKError(type: .sdkIsNotInitialized).message)
            return
        }
        
        // TODO: remove this once the others are ready
    }
    
}

