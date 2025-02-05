final class FormbricksService {
    typealias EnvironmentStateCompletion = (ResultType<EnvironmentResponse>) -> Void
    
    func getEnvironmentState(completion: @escaping EnvironmentStateCompletion) {
        let endPointRequest = GetEnvironmentRequest()
        execute(endPointRequest, withCompletion: completion)
    }
    
    func execute<Request: CodableRequest>(_ request: Request, withCompletion completion: @escaping (ResultType<Request.Response>) -> Void) {
        let operation = APIClient(request: request, completion: completion)
        Formbricks.apiQueue.addOperation(operation)
    }
}
