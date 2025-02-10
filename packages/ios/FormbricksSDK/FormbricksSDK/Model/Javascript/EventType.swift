enum EventType: String, Codable {
    case onClose = "onClose"
    case onFinished = "onFinished"
    case onDisplay = "onDisplay" // TODO: create a display API call /api/v1/client/{environmentId}/displays
    case onResponse = "onResponse"
    case onRetry = "onRetry"
    case onFileUpload = "onFileUpload"
    
}
