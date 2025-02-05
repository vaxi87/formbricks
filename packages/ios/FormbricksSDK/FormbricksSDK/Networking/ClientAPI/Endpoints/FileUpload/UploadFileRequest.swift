final class UploadFileRequest: EncodableRequest<UploadFileRequest.Body>, CodableRequest {
    typealias Response = AnyCodable
    
    var baseURL: String? { return url }
    var requestEndPoint: String { return "" }
    var requestType: HTTPMethod { return .post }
    
    let url: String
    
    struct Body: Codable {
        let fileName: String
        let fileType: String
        let surveyId: String?
        let signature: String
        let timestamp: String
        let uuid: String
        let fileBase64String: String
    }
    
    init(fileUploadUrl: String, fileName: String, fileType: String, surveyId: String = "", signature: String, timestamp: String, uuid: String, fileBase64String: String) {
        self.url = fileUploadUrl
        let body = Body(fileName: fileName, fileType: fileType, surveyId: surveyId, signature: signature, timestamp: timestamp, uuid: uuid, fileBase64String: fileBase64String)
        super.init(object: body)
        
    }

}
