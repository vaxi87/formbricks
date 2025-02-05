package com.formbricks.formbrickssdk.model.response

import com.google.gson.annotations.SerializedName

enum class EventType {
    @SerializedName("onClose")  ON_CLOSE,
    @SerializedName("onFinished") ON_FINISHED,
    @SerializedName("onDisplay") ON_DISPLAY,
    @SerializedName("onResponse") ON_RESPONSE,
    @SerializedName("onRetry") ON_RETRY,
    @SerializedName("onFileUpload") ON_FILE_UPLOAD
}