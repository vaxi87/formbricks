final class EnvironmentManager {
    static let shared = EnvironmentManager()
    private init() { }
    
    private static let environmentObjectKey = "environmentObjectKey"
    private let service = FormbricksService()
    private var timer: Timer?
    private var backingEnvironment: EnvironmentData?

    var environment: EnvironmentData? {
        get {
            if let environment = backingEnvironment {
                return environment
            } else {
                if let data = UserDefaults.standard.data(forKey: EnvironmentManager.environmentObjectKey) {
                    return try? JSONDecoder().decode(EnvironmentData.self, from: data)
                } else {
                    Formbricks.logger.error(FormbricksSDKError(type: .unableToRetrieveEnvironment).message)
                    return nil
                }
            }
        } set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: EnvironmentManager.environmentObjectKey)
                backingEnvironment = newValue
            } else {
                Formbricks.logger.error(FormbricksSDKError(type: .unableToPersistEnvironment).message)
            }
        }
    }
    
    func refreshEnvironment() {
        service.getEnvironmentState { [weak self] result in
            switch result {
            case .success(let response):
                self?.environment = response.data
                self?.startRefreshTimer()
            case .failure:
                Formbricks.logger.error(FormbricksSDKError(type: .unableToRefreshEnvironment).message)
                self?.startErrorTimer()
            }
        }
    }
}

private extension EnvironmentManager {
    func startRefreshTimer() {
        refreshEnvironmentAfter(timeout: Double(Config.Environment.refreshStateIntervalInMinutes) * 60.0)
    }
    
    func startErrorTimer() {
        refreshEnvironmentAfter(timeout: Double(Config.Environment.refreshStateOnErrorTimeoutInMinutes) * 60.0)
    }
    
    func refreshEnvironmentAfter(timeout: Double) {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            Formbricks.logger.debug("Refreshing environment state.")
            self.refreshEnvironment()
        }
    }
}
