import SwiftUI

/// A view model for the Formbricks WebView.
/// It generates the HTML string with the necessary data to render the survey.
final class FormbricksViewModel: ObservableObject {
    @Published var htmlString: String?
    let surveyId: String
    
    init(environmentResponse: EnvironmentResponse, surveyId: String) {
        self.surveyId = surveyId
        if let webviewDataJson = WebViewData(environmentResponse: environmentResponse, surveyId: surveyId).getJsonString() {
            htmlString = htmlTemplate.replacingOccurrences(of: "{{WEBVIEW_DATA}}", with: webviewDataJson)
        }
    }
}

private extension FormbricksViewModel {
    /// The HTML template to render the Formbricks WebView.
    var htmlTemplate: String {
        return """
        <!doctype html>
        <html>
            <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
            
            <head>
                <title>Formbricks WebView Survey</title>
                <script src="https://cdn.tailwindcss.com"></script>
            </head>

            <body style="overflow: hidden; height: 100vh; display: flex; flex-direction: column; justify-content: flex-end;">
                <div id="formbricks-react-native" style="width: 100%;"></div>
            </body>

            <script type="text/javascript">
                const json = `{{WEBVIEW_DATA}}`

                function onClose() {
                    window.webkit.messageHandlers.jsMessage.postMessage(JSON.stringify({ event: "onClose" }));
                };

                function onFinished() {
                    window.webkit.messageHandlers.jsMessage.postMessage(JSON.stringify({ event: "onFinished" }));
                };

                function onDisplay() {
                    window.webkit.messageHandlers.jsMessage.postMessage(JSON.stringify({ event: "onDisplay" }));
                };

                function onResponse(responseUpdate) {
                    window.webkit.messageHandlers.jsMessage.postMessage(JSON.stringify({ event: "onResponse", responseUpdate }));
                };

                function onRetry(responseUpdate) {
                    window.webkit.messageHandlers.jsMessage.postMessage(JSON.stringify({ event: "onRetry" }));
                };

                window.fileUploadPromiseCallbacks = new Map();

                function onFileUpload(file, params) {
                    return new Promise((resolve, reject) => {
                        const uploadId = Date.now() + '-' + Math.random(); // Generate a unique ID for this upload

                        window.webkit.messageHandlers.jsMessage.postMessage(JSON.stringify({ event: "onFileUpload", uploadId, fileUploadParams: { file, params } }));

                        const promiseResolve = (url) => {
                            resolve(url);
                        }

                        const promiseReject = (error) => {
                            reject(error);
                        }
                      
                        window.fileUploadPromiseCallbacks.set(uploadId, { resolve: promiseResolve, reject: promiseReject });
                    });
                }
                  
                // Add this function to handle the upload completion
                function onFileUploadComplete(result) {
                    console.log("sas")
                    if (window.fileUploadPromiseCallbacks && window.fileUploadPromiseCallbacks.has(result.uploadId)) {
                        const callback = window.fileUploadPromiseCallbacks.get(result.uploadId);
                        if (result.success) {
                            callback.resolve(result.url);
                        } else {
                            callback.reject(new Error(result.error));
                        }

                        // Remove this specific callback
                        window.fileUploadPromiseCallbacks.delete(result.uploadId);
                    }
                }

                function loadSurvey() {
                    const options = JSON.parse(json);
                    const containerId = "formbricks-react-native";
                    const surveyProps = {
                        ...options,
                        containerId,
                        onFinished,
                        onDisplay,
                        onResponse,
                        onRetry,
                        onClose,
                        onFileUpload
                    };

                    window.formbricksSurveys.renderSurveyInline(surveyProps);
                }

                const script = document.createElement("script");
                script.src = "\(Formbricks.appUrl ?? "http://localhost:3000")/js/surveys.umd.cjs";
                script.async = true;
                script.onload = () => loadSurvey();
                script.onerror = (error) => {
                    console.error("Failed to load Formbricks Surveys library:", error);
                };
                document.head.appendChild(script);
            </script>
        </html>
        """
    }
    
}

// MARK: - Helper class -
private class WebViewData {
    var data: [String: Any] = [:]
    
    init(environmentResponse: EnvironmentResponse, surveyId: String) {
        data["survey"] = environmentResponse.getSurveyJson(forSurveyId: surveyId)
        data["isBrandingEnabled"] = true
        data["languageCode"] = Formbricks.language
        data["appUrl"] = Formbricks.appUrl
        
        let hasCustomStyling = environmentResponse.data.data.surveys?.first(where: { $0.id == surveyId })?.styling != nil
            
        data["styling"] = hasCustomStyling ? environmentResponse.getSurveyStylingJson(forSurveyId: surveyId): environmentResponse.getProjectStylingJson()
    }
    
    func getJsonString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            return String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\\\"", with: "'")
        } catch {
            Formbricks.logger.error(error.message)
            return nil
        }
    }
    
}
