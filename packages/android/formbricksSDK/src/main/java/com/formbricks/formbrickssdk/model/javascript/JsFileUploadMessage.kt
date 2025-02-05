package com.formbricks.formbrickssdk.model.javascript

import com.formbricks.formbrickssdk.model.response.EventType
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

data class JsFileUploadMessage(
    @SerializedName("event") val event: EventType,
    @SerializedName("uploadId") val uploadId: String,
    @SerializedName("fileUploadParams") val fileUploadParams: FileUploadParams
){
    companion object {
        fun from(string: String): JsFileUploadMessage {
            return Gson().fromJson(string, JsFileUploadMessage::class.java)
        }
    }
}

data class FileUploadParams(
    @SerializedName("file") val file: FileData,
    @SerializedName("params") val params: Params
)

data class FileData(
    @SerializedName("name") val name: String,
    @SerializedName("type") val type: String,
    @SerializedName("base64") val base64: String
)

data class Params(
    @SerializedName("surveyId") val surveyId: String
)