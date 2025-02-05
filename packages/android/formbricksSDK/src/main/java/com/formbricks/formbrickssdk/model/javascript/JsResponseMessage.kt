package com.formbricks.formbrickssdk.model.javascript

import com.formbricks.formbrickssdk.model.response.EventType
import com.formbricks.formbrickssdk.model.response.SurveyResponse
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

data class JsResponseMessage(
    @SerializedName("event") val event: EventType,
    @SerializedName("responseUpdate") val surveyResponse: SurveyResponse?
) {
    companion object {
        fun from(string: String): JsResponseMessage {
            return Gson().fromJson(string, JsResponseMessage::class.java)
        }
    }
}