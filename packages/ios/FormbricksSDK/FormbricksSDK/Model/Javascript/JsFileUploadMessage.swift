struct JsFileUploadMessage: Codable {
    let event: EventType
    let uploadId: String
    let fileUploadParams: FileUploadParams
}

struct FileUploadParams: Codable {
    let file: File
    let params: Params
}

struct File: Codable {
    let name: String
    let type: String
    let base64: String
}

struct Params: Codable {
    let surveyId: String
}
