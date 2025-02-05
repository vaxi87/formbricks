/// FormbricksService is a service class that handles the network requests for Formbricks API.
final class FormbricksService {
    
    // MARK: - Environment -
    /// Get the current environment state.
    func getEnvironmentState(completion: @escaping (ResultType<GetEnvironmentRequest.Response>) -> Void) {
        let endPointRequest = GetEnvironmentRequest()
        execute(endPointRequest, withCompletion: completion)
    }
    
    // MARK: - Survey response -
    /// Post a response for a survey, made by the user.
    func postResponse(_ responseUpdate: ResponseUpdate, forSurveyId surveyId: String, userId: String?, displayId: String?, completion: @escaping (ResultType<PostResponseRequest.Response>) -> Void) {
        let endPointRequest = PostResponseRequest(surveyId: surveyId, userId: userId, displayId: displayId, responseUpdate: responseUpdate)
        execute(endPointRequest, withCompletion: completion)
    }
    
    /// When we already have a response ID, we can update the response with the new answers.
    func updateResponse(_ responseUpdate: ResponseUpdate, responseId: String, completion: @escaping (ResultType<UpdateResponseRequest.Response>) -> Void) {
        let endPointRequest = UpdateResponseRequest(responseId: responseId, responseUpdate: responseUpdate)
        execute(endPointRequest, withCompletion: completion)
    }
    
    // MARK: - Display -
    /// Post a display for a survey. Called when the survey is displayed.
    func postDisplay(forSurveyId id: String, userId: String?, completion: @escaping (ResultType<PostDisplaysRequest.Response>) -> Void) {
        let endPointRequest = PostDisplaysRequest(surveyId: id, userId: userId)
        execute(endPointRequest, withCompletion: completion)
    }
    
    /// Updates a display
    func updateDisplay(id: String, surveyId: String, userId: String?, completion: @escaping (ResultType<UpdateDisplayRequest.Response>) -> Void) {
        let endPointRequest = UpdateDisplayRequest(displayId: id, surveyId: surveyId, userId: userId)
        execute(endPointRequest, withCompletion: completion)
    }
    
    // MARK: - User -
    /// Logs in a user with the given ID or creates one if it doesn't exist.
    func postUser(id: String, attributes: [String: String]?, completion: @escaping (ResultType<PostUserRequest.Response>) -> Void) {
        let endPointRequest = PostUserRequest(userId: id, attributes: attributes)
        execute(endPointRequest, withCompletion: completion)
    }
    
    // MARK: - File upload -
    /// Fetches the upload URL for a file
    func fetchUploadUrl(forFileName name: String, fileType: String, allowedFileExtensions: [String]?, surveyId: String, completion: @escaping (ResultType<FetchStorageUrlRequest.Response>) -> Void) {
        let endPoint = FetchStorageUrlRequest(fileName: name, fileType: fileType, allowedFileExtensions: allowedFileExtensions, surveyId: surveyId)
        execute(endPoint, withCompletion: completion)
    }
    
    /// Uploads a file to the given URL.
    func uploadFile(url: String, fileName: String, fileType: String, surveyId: String?, signature: String, timestamp: String, uuid: String, fileBase64String: String,  completion: @escaping (ResultType<UploadFileRequest.Response>) -> Void) {
        let endPoint = UploadFileRequest(fileUploadUrl: url, fileName: fileName, fileType: fileType, surveyId: surveyId!, signature: signature, timestamp: timestamp, uuid: uuid, fileBase64String: fileBase64String)
        execute(endPoint, withCompletion: completion)
    }
}

private extension FormbricksService {
    func execute<Request: CodableRequest>(_ request: Request, withCompletion completion: @escaping (ResultType<Request.Response>) -> Void) {
        let operation = APIClient(request: request, completion: completion)
        Formbricks.apiQueue.addOperation(operation)
    }
}
