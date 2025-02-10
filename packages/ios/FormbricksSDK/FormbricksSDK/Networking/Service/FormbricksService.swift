final class FormbricksService {
    typealias EnvironmentStateCompletion = (ResultType<EnvironmentResponse>) -> Void
    typealias PostResponseCompletion = (ResultType<PostResponseRequest.Response>) -> Void
    
    func getEnvironmentState(completion: @escaping EnvironmentStateCompletion) {
        let endPointRequest = GetEnvironmentRequest()
        execute(endPointRequest, withCompletion: completion)
    }
    
    func postResponse(_ responseUpdate: ResponseUpdate, forSurveyId surveyId: String, completion: @escaping PostResponseCompletion) {
        let endPointRequest = PostResponseRequest(surveyId: surveyId, userId: nil, responseUpdate: responseUpdate)
        execute(endPointRequest, withCompletion: completion)
    }
    
    func execute<Request: CodableRequest>(_ request: Request, withCompletion completion: @escaping (ResultType<Request.Response>) -> Void) {
        let operation = APIClient(request: request, completion: completion)
        Formbricks.apiQueue.addOperation(operation)
    }
}
