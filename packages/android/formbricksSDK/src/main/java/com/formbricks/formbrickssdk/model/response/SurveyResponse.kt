package com.formbricks.formbrickssdk.model.response

import com.google.gson.annotations.SerializedName

data class SurveyResponse(
    @SerializedName("data") val data: Map<String, *>? = null,
    @SerializedName("ttc")  val ttc: Map<String, *>? = null,
    @SerializedName("finished") val finished: Boolean? = null,
    @SerializedName("variables") val variables: Map<String, *>? = null,
    @SerializedName("language") val language: String? = null
)