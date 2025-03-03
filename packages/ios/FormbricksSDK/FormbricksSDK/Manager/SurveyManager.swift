import SwiftUI

/// The SurveyManager is responsible for managing the surveys that are displayed to the user.
/// Filtering surveys based on the user's segments, responses, and displays.
final class SurveyManager {
    static let shared = SurveyManager()
    private init() { }
    
    private static let environmentResponseObjectKey = "environmentResponseObjectKey"
    private let service = FormbricksService()
    private var backingEnvironmentResponse: EnvironmentResponse?
    /// The view controller that will present the survey window.
    private weak var viewController: UIViewController?
    /// Stores the id of the current display.
    private var displayId: String?
    /// Stores the id of the current response.
    private var responseId: String?
    /// Stores the surveys that are filtered based on the defined criteria, such as recontact days, display options etc.
    private var filteredSurveys: [Survey] = []
    
    /// Fills up the `filteredSurveys` array
    func filterSurveys() {
        guard let environment = environmentResponse else { return }
        guard let surveys = environment.data.data.surveys else { return }
        
        let displays = UserManager.shared.displays ?? []
        let responses = UserManager.shared.responses ?? []
        let segments = UserManager.shared.segments ?? []
        
        filteredSurveys = filterSurveysBasedOnDisplayType(surveys, displays: displays, responses: responses)
        filteredSurveys = filterSurveysBasedOnRecontactDays(filteredSurveys, defaultRecontactDays: environment.data.data.project.recontactDays)
        
        // If we have a user, we do more filtering
        if UserManager.shared.userId != nil {
            if segments.isEmpty {
                filteredSurveys = []
                return
            }
            
            filteredSurveys = filterSurveysBasedOnSegments(filteredSurveys, segments: segments)
        }
    }
    
    /// Checks if there are any surveys to display, based in the track action, and if so, displays the first one.
    /// Handles the display percentage and the delay of the survey.
    func track(_ action: String) {
        let actionClasses = environmentResponse?.data.data.actionClasses ?? []
        let codeActionClasses = actionClasses.filter { $0.type == "code" }
        let actionClass = codeActionClasses.first { $0.key == action }
        let firstSurveyWithActionClass = filteredSurveys.first { survey in
            return survey.triggers?.contains(where: { $0.actionClass?.name == actionClass?.name }) ?? false
        }
        
        // Display percentage
        let shouldDisplay = shouldDisplayBasedOnPercentage(firstSurveyWithActionClass?.displayPercentage)
        
        // Display and delay it if needed
        if let surveyId = firstSurveyWithActionClass?.id, shouldDisplay {
            let timeout = firstSurveyWithActionClass?.delay ?? 0
            DispatchQueue.global().asyncAfter(deadline: .now() + Double(timeout)) {
                self.showSurvey(withId: surveyId)
            }
        }
    }
}

// MARK: - API calls -
extension SurveyManager {
    /// Checks if the environment state needs to be refreshed based on its `expiresAt` property, and if so, refreshes it, starts the refresh timer, and filters the surveys.
    func refreshEnvironmentIfNeeded(force: Bool = false) {
        if let environmentResponse = environmentResponse, environmentResponse.data.expiresAt.timeIntervalSinceNow > 0, !force {
            Formbricks.logger.debug("Environment state is still valid until \(environmentResponse.data.expiresAt)")
            filterSurveys()
            return
        }
        
        service.getEnvironmentState { [weak self] result in
            switch result {
            case .success(let response):
                self?.environmentResponse = response
                self?.startRefreshTimer(expiresAt: response.data.expiresAt)
                self?.filterSurveys()
            case .failure:
                Formbricks.logger.error(FormbricksSDKError(type: .unableToRefreshEnvironment).message)
                self?.startErrorTimer()
            }
        }
    }
    
    /// Posts a survey response to the Formbricks API.
    func postResponse(surveyId: String) {
        UserManager.shared.anonymousOnResponse(surveyId: surveyId)
    }
    
    /// Posts a survey response to the Formbricks API.
    func postResponse(_ responseUpdate: ResponseUpdate?, forSurveyId id: String) {
        guard let responseUpdate = responseUpdate else {
            Formbricks.logger.error(FormbricksSDKError(type: .invalidJavascriptMessage).message)
            return
        }
        
        /// If we have a responseId, we update the response, otherwise we create a new one.
        if let responseId {
            service.updateResponse(responseUpdate, responseId: responseId) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    Formbricks.logger.error(error.message)
                }
            }
        } else {
            service.postResponse(responseUpdate, forSurveyId: id, userId: UserManager.shared.userId, displayId: displayId) { [weak self] result in
                switch result {
                case .success(let response):
                    self?.responseId = response.data?["id"]
                    if UserManager.shared.userId != nil {
                        UserManager.shared.anonymousOnResponse(surveyId: id)
                    }
                case .failure(let error):
                    Formbricks.logger.error(error.message)
                }
            }
        }
    }
    
    /// Creates a new display for the survey. It is called when the survey is displayed to the user.
    func onNewDisplay(surveyId: String) {
        UserManager.shared.anonymousOnDisplay(surveyId: surveyId)
    }
    
    /// Creates a new display for the survey. It is called when the survey is displayed to the user.
    func createNewDisplay(surveyId: String) {
        guard let userId = UserManager.shared.userId else {
            /// If we don't have a user, we only save the last displayed date in the `UserManager`
            UserManager.shared.anonymousOnDisplay(surveyId: surveyId)
            return
        }
        
        service.postDisplay(forSurveyId: surveyId, userId: userId) { [weak self] result in
            switch result {
            case .success(let response):
                self?.displayId = response.data.id
                self?.responseId = nil
            case .failure(let error):
                Formbricks.logger.error(error.message)
            }
        }
    }
    
    /// Fetch a public upload URL for a file to be uploaded to the Formbricks API.
    func upload(uploadId: String, file: File, forSurveyId surveyId: String, completion: @escaping (String)->()) {
        service.fetchUploadUrl(forFileName: file.name, fileType: file.type, allowedFileExtensions: nil, surveyId: surveyId) { [weak self] result in
            switch result {
            case .success(let response):
                self?.reallyUploadFile(file: file, surveyId: surveyId, storageData: response.data, uploadId: uploadId, completion: completion)
            case .failure(let error):
                Formbricks.logger.error(error.message)
            }
        }
    }
    
    /// Uploads the file to the Formbricks API.
    func reallyUploadFile(file: File, surveyId: String, storageData: StorageData, uploadId: String, completion: @escaping (String)->()) {
        var finalUrl = storageData.signedUrl.replacingOccurrences(of: "http://localhost:3000", with: Formbricks.appUrl ?? "")
        service.uploadFile(url: finalUrl, fileName: storageData.updatedFileName, fileType: file.type, surveyId: surveyId, signature: storageData.signingData.signature, timestamp: String(storageData.signingData.timestamp), uuid: storageData.signingData.uuid, fileBase64String: file.base64) { [weak self] result in
            switch result {
            case .success(let response):

                var jsonDict: [String: Any] = [:]
                jsonDict["success"] = true
                jsonDict["url"] = storageData.fileUrl
                jsonDict["uploadId"] = uploadId
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: .fragmentsAllowed), let jsonString = String(data: jsonData, encoding: .utf8) {
                    completion(jsonString)
                } else {
                    completion("")
                }
              
            case .failure(let error):
                Formbricks.logger.error(error.message)
            }
        }
    }
}

// MARK: - Present and dismiss survey window -
extension SurveyManager {
    /// Dismisses the presented survey window.
    func dismissSurveyWebView() {
        viewController?.dismiss(animated: true)
    }
    
    /// Dismisses the presented survey window after a delay.
    func delayedDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(Config.Environment.closingTimeoutInSeconds)) {
            self.dismissSurveyWebView()
        }
    }
}

private extension SurveyManager {
    /// Presents the survey window with the given id. It is called when a survey is triggered.
    /// The survey is displayed based on the `FormbricksView`.
    /// The view controller is presented over the current context.
    func showSurvey(withId id: String) {
        if let environmentResponse = environmentResponse {
            DispatchQueue.main.async {
                if let window = UIApplication.safeShared?.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first {
                    let view = FormbricksView(viewModel: FormbricksViewModel(environmentResponse: environmentResponse, surveyId: id))
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
                    self.viewController = vc
                    window.rootViewController?.present(vc, animated: true, completion: nil)
                }
            }
        }
                    
    }
    
    /// Starts a timer to refresh the environment state after the given timeout (`expiresAt`).
    func startRefreshTimer(expiresAt: Date) {
        let timeout = expiresAt.timeIntervalSinceNow
        refreshEnvironmentAfter(timeout: timeout)
    }
    
    /// When an error occurs, it starts a timer to refresh the environment state after the given timeout.
    func startErrorTimer() {
        refreshEnvironmentAfter(timeout: Double(Config.Environment.refreshStateOnErrorTimeoutInMinutes) * 60.0)
    }
    
    /// Refreshes the environment state after the given timeout.
    func refreshEnvironmentAfter(timeout: Double) {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            Formbricks.logger.debug("Refreshing environment state.")
            self.refreshEnvironmentIfNeeded(force: true)
        }
    }
    
    /// Decides if the survey should be displayed based on the display percentage.
    func shouldDisplayBasedOnPercentage(_ displayPercentage: Double?) -> Bool {
        guard let displayPercentage = displayPercentage else { return true }
        let randomNum = Double(Int.random(in: 0..<10000)) / 100.0
        return randomNum <= displayPercentage
    }
}

// MARK: - Store data in the UserDefaults -
extension SurveyManager {
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
}

// MARK: - Helper methods -
private extension SurveyManager {
    /// Filters the surveys based on the display type and limit.
    func filterSurveysBasedOnDisplayType(_ surveys: [Survey], displays: [Display], responses: [String]) -> [Survey] {
        return surveys.filter { survey in
            switch survey.displayOption {
            case .respondMultiple:
                return true
                
            case .displayOnce:
                return !displays.contains { $0.surveyId == survey.id }
                
            case .displayMultiple:
                return !responses.contains { $0 == survey.id }
                
            case .displaySome:
                if let limit = survey.displayLimit {
                    if responses.contains(where: { $0 == survey.id }) { return false }
                    return displays.filter { $0.surveyId == survey.id }.count < limit
                } else {
                    return true
                }
                
            default:
                Formbricks.logger.error(FormbricksSDKError(type: .invalidDisplayOption).message)
                return false
            }
            
            
        }
    }
    
    /// Filters the surveys based on the recontact days and the `lastDisplayedAt` date.
    func filterSurveysBasedOnRecontactDays(_ surveys: [Survey], defaultRecontactDays:  Int?) -> [Survey] {
        surveys.filter { survey in
            guard let lastDisplayedAt = UserManager.shared.lastDisplayedAt else { return true }
            let recontactDays = survey.recontactDays ?? defaultRecontactDays
            
            if let recontactDays = recontactDays {
                return Calendar.current.numberOfDaysBetween(Date(), and: lastDisplayedAt) >= recontactDays
            }
            
            return true
        }
    }
    
    /// Filters the surveys based on the user's segments.
    func filterSurveysBasedOnSegments(_ surveys: [Survey], segments: [String]) -> [Survey] {
        return surveys.filter { survey in
            guard let segmentId = survey.segment?.id else { return false }
            return segments.contains(segmentId)
        }
    }

}
