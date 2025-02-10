import SwiftUI
import WebKit
import JavaScriptCore

struct SurveyWebView: UIViewRepresentable {
    let surveyId: String
    let htmlString: String
    
    public func makeUIView(context: Context) -> WKWebView {
        clean()
        
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
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
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
class JsMessageHandler: NSObject, WKScriptMessageHandler {
    
    let surveyId: String
    
    init(surveyId: String) {
        self.surveyId = surveyId
    }
   
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Formbricks.logger.debug(message.body)
        
        if let body = message.body as? String, let data = body.data(using: .utf8), let obj = try? JSONDecoder().decode(JsResponseUpdate.self, from: data) {
            
            switch obj.event {
            case .onResponse:
                SurveyManager.shared.postResponse(obj.responseUpdate, forSurveyId: surveyId)
                
            default:
                break
            }
            
        } else {
            Formbricks.logger.error("\(FormbricksSDKError(type: .invalidJavascriptMessage).message): \(message.body)")
        }
    }
}

// MARK: - Handle Javascript console.log -
class LoggingMessageHandler: NSObject, WKScriptMessageHandler {
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
