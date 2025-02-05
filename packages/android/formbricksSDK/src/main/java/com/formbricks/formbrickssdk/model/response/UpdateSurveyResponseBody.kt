package com.formbricks.formbrickssdk.model.response

import com.google.gson.annotations.SerializedName

data class UpdateSurveyResponseBody(
    @SerializedName("finished") val finished: Boolean,
    @SerializedName("data") val data: Map<String, *>?,
) {
    companion object {
        fun create(response: SurveyResponse): UpdateSurveyResponseBody {
            return UpdateSurveyResponseBody(
                finished = response.finished ?: false,
                data = response.data
            )
        }
    }
}