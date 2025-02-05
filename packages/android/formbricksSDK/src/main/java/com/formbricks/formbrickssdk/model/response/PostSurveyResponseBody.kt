package com.formbricks.formbrickssdk.model.response

import com.google.gson.annotations.SerializedName

data class PostSurveyResponseBody(
    @SerializedName("surveyId") val surveyId: String,
    @SerializedName("userId") val userId: String?,
    @SerializedName("displayId") val displayId: String?,
    @SerializedName("finished") val finished: Boolean,
    @SerializedName("data") val data: Map<String, *>?,
) {
    companion object {
        fun create(surveyId: String, userId: String?, displayId: String?, response: SurveyResponse): PostSurveyResponseBody {
            return PostSurveyResponseBody(
                surveyId = surveyId,
                userId = userId,
                displayId = displayId,
                finished = response.finished ?: false,
                data = response.data
            )
        }
    }
}