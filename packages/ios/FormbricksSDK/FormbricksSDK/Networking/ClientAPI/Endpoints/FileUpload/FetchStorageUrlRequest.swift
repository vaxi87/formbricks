final class FetchStorageUrlRequest: EncodableRequest<FetchStorageUrlRequest.Body>, CodableRequest {
    typealias Response = FetchStorageUrlResponse
    var requestEndPoint: String { return "/api/v1/client/{environmentId}/storage" }
    var requestType: HTTPMethod { return .post }
    
    struct Body: Codable {
        let fileName: String
        let fileType: String
        let allowedFileExtensions: [String]?
        let surveyId: String
        let accessType: String
    }
    
    init(fileName: String, fileType: String, allowedFileExtensions: [String]?, surveyId: String, accessType: String = "public") {
        let body = Body(fileName: fileName, fileType: fileType, allowedFileExtensions: allowedFileExtensions, surveyId: surveyId, accessType: accessType)
        super.init(object: body)
    }
}
