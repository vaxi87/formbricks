final class UpdateDisplayRequest: EncodableRequest<UpdateDisplayRequest.Body>, CodableRequest {
    typealias Response = PostDisplayResponse
    
    var requestEndPoint: String { return "/api/v1/client/{environmentId}/displays/{displayId}" }
    var requestType: HTTPMethod { return .put }
    
    var pathParams: [String : String]? {
        return ["displayId": displayId]
    }
    
    struct Body: Codable {
        let surveyId: String
        let userId: String?
    }
    
    let displayId: String
        
    init(displayId: String, surveyId: String, userId: String?) {
        self.displayId = displayId
        super.init(object: Body(surveyId: surveyId, userId: userId))
    }
}
