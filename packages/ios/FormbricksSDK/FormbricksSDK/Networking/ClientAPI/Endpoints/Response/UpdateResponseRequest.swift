final class UpdateResponseRequest: EncodableRequest<UpdateResponseRequest.Body>, CodableRequest {
    var requestEndPoint: String { return "/api/v1/client/{environmentId}/responses/{responseId}" }
    var requestType: HTTPMethod { return .put }

    struct Response: Codable {
        let data: AnyCodable?
    }
    
    var pathParams: [String : String]? {
        return ["{responseId}": responseId]
    }

    struct Body: Codable {
        let finished: Bool
        let data: [String: AnyCodable]?
    }
    
    let responseId: String
    
    init(responseId: String, responseUpdate: ResponseUpdate) {
        self.responseId = responseId
        let body = Body(finished: responseUpdate.finished ?? false, data: responseUpdate.data)
        super.init(object: body)
    }
}
