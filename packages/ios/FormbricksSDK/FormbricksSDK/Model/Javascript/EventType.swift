enum EventType: String, Codable {
    case onClose = "onClose"
    case onFinished = "onFinished"
    case onDisplay = "onDisplay"
    case onResponse = "onResponse"
    case onRetry = "onRetry"
    case onFileUpload = "onFileUpload"
    case onDisplayCreated = "onDisplayCreated"
    case onResponseCreated = "onResponseCreated"
}
