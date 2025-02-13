import UIKit
import SwiftUI

final class SurveyManager {
    static let shared = SurveyManager()
    private init() { }
    
    private static let environmentResponseObjectKey = "environmentResponseObjectKey"
    private let service = FormbricksService()
    
    private var backingEnvironmentResponse: EnvironmentResponse?
    var environmentResponse: EnvironmentResponse? {
        get {
            if let environmentResponse = backingEnvironmentResponse {
                return environmentResponse
            } else {
                if let data = UserDefaults.standard.data(forKey: SurveyManager.environmentResponseObjectKey) {
                    return try? JSONDecoder().decode(EnvironmentResponse.self, from: data)
                } else {
                    Formbricks.logger.error(FormbricksSDKError(type: .unableToRetrieveEnvironment).message)
                    return nil
                }
            }
        } set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: SurveyManager.environmentResponseObjectKey)
                backingEnvironmentResponse = newValue
            } else {
                Formbricks.logger.error(FormbricksSDKError(type: .unableToPersistEnvironment).message)
            }
        }
    }
    
    func refreshEnvironment() {
        service.getEnvironmentState { [weak self] result in
            switch result {
            case .success(let response):
                self?.environmentResponse = response
                self?.handleEnvironmentChage()
                self?.startRefreshTimer(expiresAt: response.data.expiresAt)
            case .failure:
                Formbricks.logger.error(FormbricksSDKError(type: .unableToRefreshEnvironment).message)
                self?.startErrorTimer()
            }
        }
    }
    
    func postResponse(_ responseUpdate: ResponseUpdate, forSurveyId id: String) {
        service.postResponse(responseUpdate, forSurveyId: id) { [weak self] result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                Formbricks.logger.error(error.message)
            }
        }
    }
}

private extension SurveyManager {
    // TODO: move this to display survey manager
    func handleEnvironmentChage() {
        if let environmentResponse = environmentResponse {
            DispatchQueue.main.async {
                if let window = UIApplication.safeShared?.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first {
                    let view = FormbricksView(viewModel: FormbricksViewModel(environmentResponse: environmentResponse))
                    let vc = UIHostingController(rootView: view)
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.view.backgroundColor = .clear
                    if let presentationController = vc.presentationController as? UISheetPresentationController {
                        presentationController.detents = [.large()]
//                        presentationController.detents = [.medium()]
//                        presentationController.detents = [.custom(resolver: { context in
//                            return 350
//                        })]
                    }
                    window.rootViewController?.present(vc, animated: true, completion: nil)
                }
            }
        }
                    
    }
    
    func startRefreshTimer(expiresAt: Date) {
        let timeout = expiresAt.timeIntervalSinceNow
        refreshEnvironmentAfter(timeout: timeout)
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
