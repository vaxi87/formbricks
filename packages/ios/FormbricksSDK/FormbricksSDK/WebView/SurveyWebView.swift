import SwiftUI
import WebKit
import JavaScriptCore

/// SwiftUI wrapper for the WKWebView to display a survey.
struct SurveyWebView: UIViewRepresentable {
    let surveyId: String
    let htmlString: String
    
    /// Assemble the WKWebView with the necessary configuration.
    public func makeUIView(context: Context) -> WKWebView {
        clean()
        
        // Add javascript message handlers
        let userContentController = WKUserContentController()
        userContentController.add(LoggingMessageHandler(), name: "logging")
        userContentController.add(JsMessageHandler(surveyId: surveyId), name: "jsMessage")
        userContentController.addUserScript(WKUserScript(source: overrideConsole, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: webViewConfig)
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.isInspectable = true
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    /// Clean up cookies and website data.
    func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

// MARK: - Javascript --> Native message handler -
/// Handle messages coming from the Javascript in the WebView.
final class JsMessageHandler: NSObject, WKScriptMessageHandler {
    
    let surveyId: String
    
    init(surveyId: String) {
        self.surveyId = surveyId
    }
   
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Formbricks.logger.debug(message.body)
        
        if let body = message.body as? String, let data = body.data(using: .utf8), let obj = try? JSONDecoder().decode(JsMessageData.self, from: data) {
            
            switch obj.event {
            /// Happens when the user submits a response for a question.
            case .onResponse:
                if let response = try? JSONDecoder().decode(JsResponseMessage.self, from: data) {
                    SurveyManager.shared.postResponse(response.responseUpdate, forSurveyId: surveyId)
                }
            case .onResponseCreated:
                SurveyManager.shared.postResponse(surveyId: surveyId)
            /// Happens when a survey view appears..
            case .onDisplay:
                SurveyManager.shared.createNewDisplay(surveyId: surveyId)
            case .onDisplayCreated:
                SurveyManager.shared.onNewDisplay(surveyId: surveyId)
            /// Happens when a file is selected to be uploaded from a file picker.
            case .onFileUpload:
                if let fileMessage = try? JSONDecoder().decode(JsFileUploadMessage.self, from: data) {
                    SurveyManager.shared.upload(uploadId: fileMessage.uploadId, file: fileMessage.fileUploadParams.file, forSurveyId: surveyId) { responseMessage in
                        DispatchQueue.main.async {
                           // let finalMessage = responseMessage.replacingOccurrences(of: "\"", with: "'").replacingOccurrences(of: #"\"#, with: "", options: .literal, range: nil)
                            message.webView?.evaluateJavaScript("""
                                                                window.onFileUploadComplete(\(responseMessage.replacingOccurrences(of: "\\\"", with: "\"")))
                                                                """)
                        }
                    }
                }
            
            /// Happens when the user closes the survey view with the close button.
            case .onClose:
                SurveyManager.shared.dismissSurveyWebView()
                
            /// Happens when the survey view is finished  by the user submitting the last question.
            case .onFinished:
                SurveyManager.shared.delayedDismiss()
                
            default:
                break
            }
            
        } else {
            Formbricks.logger.error("\(FormbricksSDKError(type: .invalidJavascriptMessage).message): \(message.body)")
        }
    }
}

// MARK: - Handle Javascript console.log -
/// Handle and send console.log messages from the Javascript to the local logger.
final class LoggingMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Formbricks.logger.debug(message.body)
    }
}

private extension SurveyWebView {
    // https://stackoverflow.com/a/61489361
    var overrideConsole: String {
        return
    """
        function log(emoji, type, args) {
          window.webkit.messageHandlers.logging.postMessage(
            `${emoji} JS ${type}: ${Object.values(args)
              .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v) : v.toString())
              .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
              .join(", ")}`
          )
        }
    
        let originalLog = console.log
        let originalWarn = console.warn
        let originalError = console.error
        let originalDebug = console.debug
    
        console.log = function() { log("📗", "log", arguments); originalLog.apply(null, arguments) }
        console.warn = function() { log("📙", "warning", arguments); originalWarn.apply(null, arguments) }
        console.error = function() { log("📕", "error", arguments); originalError.apply(null, arguments) }
        console.debug = function() { log("📘", "debug", arguments); originalDebug.apply(null, arguments) }
    
        window.addEventListener("error", function(e) {
           log("💥", "Uncaught", [`${e.message} at ${e.filename}:${e.lineno}:${e.colno}`])
        })
    """
    }
}
