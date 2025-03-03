package com.formbricks.formbrickssdk.webview

import android.webkit.JavascriptInterface
import com.formbricks.formbrickssdk.model.javascript.FileData
import com.formbricks.formbrickssdk.model.javascript.JsFileUploadMessage
import com.formbricks.formbrickssdk.model.javascript.JsMessageData
import com.formbricks.formbrickssdk.model.javascript.JsResponseMessage
import com.formbricks.formbrickssdk.model.response.EventType
import com.formbricks.formbrickssdk.model.response.SurveyResponse
import timber.log.Timber

class WebAppInterface(private val callback: WebAppCallback?) {

    interface WebAppCallback {
        fun onClose()
        fun onFinished()
        fun onDisplay()
        fun onDisplayCreated()
        fun onResponse(response: SurveyResponse?)
        fun onResponseCreated()
        fun onRetry()
        fun onFileUpload(file: FileData, uploadId: String)
    }

    /**
     * Javascript interface to get messages from the WebView's embedded JS
     */
    @JavascriptInterface
    fun message(data: String) {
        Timber.tag("WebAppInterface message").d(data)

        try {
            val jsMessage = JsMessageData.from(data)
            when (jsMessage.event) {
                EventType.ON_CLOSE -> callback?.onClose()
                EventType.ON_FINISHED -> callback?.onFinished()
                EventType.ON_DISPLAY -> callback?.onDisplay()
                EventType.ON_DISPLAY_CREATED -> callback?.onDisplayCreated()
                EventType.ON_RESPONSE -> callback?.onResponse(JsResponseMessage.from(data).surveyResponse)
                EventType.ON_RESPONSE_CREATED -> callback?.onResponseCreated()
                EventType.ON_RETRY -> callback?.onRetry()
                EventType.ON_FILE_UPLOAD -> {
                    val message = JsFileUploadMessage.from(data)
                    callback?.onFileUpload(message.fileUploadParams.file, message.uploadId)
                }
            }
        } catch (e: Exception) {
            Timber.tag("WebAppInterface error").e(e)
        }
    }

    companion object {
        const val INTERFACE_NAME = "FormbricksJavascript"
    }
}