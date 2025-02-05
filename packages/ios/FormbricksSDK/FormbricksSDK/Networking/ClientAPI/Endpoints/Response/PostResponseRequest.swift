final class PostResponseRequest: EncodableRequest<PostResponseRequest.Body>, CodableRequest {
    var requestEndPoint: String { return "/api/v1/client/{environmentId}/responses" }
    var requestType: HTTPMethod { return .post }

    struct Response: Codable {
        let data: [String: String]?
    }

    struct Body: Codable {
        let surveyId: String
        let userId: String?
        let displayId: String?
        let finished: Bool
        let data: [String: AnyCodable]?
    }
    
    init(surveyId: String, userId: String?, displayId: String?, responseUpdate: ResponseUpdate) {
        let body = Body(surveyId: surveyId, userId: userId, displayId: displayId, finished: responseUpdate.finished ?? false, data: responseUpdate.data)
        super.init(object: body)
    }
    
}
