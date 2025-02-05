package com.formbricks.formbrickssdk.model.response

import com.google.gson.annotations.SerializedName

data class PostSurveyResponse(
    @SerializedName("data") val data: PostSurveyResponseData
)