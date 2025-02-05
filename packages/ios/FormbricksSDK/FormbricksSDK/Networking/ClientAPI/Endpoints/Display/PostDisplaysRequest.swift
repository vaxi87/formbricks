final class PostDisplaysRequest: EncodableRequest<PostDisplaysRequest.Body>, CodableRequest {
    typealias Response = PostDisplayResponse
    
    var requestEndPoint: String { return "/api/v1/client/{environmentId}/displays" }
    var requestType: HTTPMethod { return .post }
    
    struct Body: Codable {
        let surveyId: String
        let userId: String?
    }
    
    init(surveyId: String, userId: String?) {
        super.init(object: Body(surveyId: surveyId, userId: userId))
    }
}
