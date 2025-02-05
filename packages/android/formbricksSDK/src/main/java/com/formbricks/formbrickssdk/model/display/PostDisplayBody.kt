package com.formbricks.formbrickssdk.model.display

import com.google.gson.annotations.SerializedName

data class PostDisplayBody(
    @SerializedName("surveyId") val surveyId: String,
    @SerializedName("userId") val userId: String?
) {
    companion object {
        fun create(surveyId: String, userId: String?): PostDisplayBody {
            return PostDisplayBody(surveyId, userId)
        }
    }
}