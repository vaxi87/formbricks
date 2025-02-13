package com.formbricks.formbrickssdk.webview

import android.util.Log
import android.webkit.JavascriptInterface
import com.formbricks.formbrickssdk.Formbricks

class WebAppInterface {



    interface WebAppCallback {
        fun onClose()
        fun onResponse()
    }

    @JavascriptInterface
    fun message(data: String) {
        if (Formbricks.loggingEnabled) {
            Log.d("WebAppInterface message", data)
        }
    }

    companion object {
        const val INTERFACE_NAME = "FormbricksJavascript"
    }
}