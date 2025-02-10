package com.formbricks.formbrickssdk.model

import com.google.gson.annotations.SerializedName

// TODO: split this to files

data class EnvironmentResponse(
    @SerializedName("data") val data: EnvironmentResponseData,
    //var responseDictionary: MutableMap<String, Any> = mutableMapOf()
): BaseFormbricksResponse

data class EnvironmentResponseData(
    @SerializedName("data") val data: EnvironmentData,
    @SerializedName("expiresAt") val expiresAt: String?
)

data class EnvironmentData(
    @SerializedName("surveys") val surveys: List<Survey>?,
    @SerializedName("actionClasses") val actionClasses: List<ActionClass>?,
    @SerializedName("project") val project: Project
)

data class Survey(
    @SerializedName("id") val id: String,
    @SerializedName("name") val name: String,
    @SerializedName("autoClose") val autoClose: Boolean?,
    @SerializedName("triggers") val triggers: List<Trigger>?,
    @SerializedName("recontactDays") val recontactDays: Int?,
    @SerializedName("displayLimit") val displayLimit: Int?,
    @SerializedName("delay") val delay: Int?,
    @SerializedName("displayPercentage") val displayPercentage: Int?
)

data class Trigger(
    @SerializedName("actionClass") val actionClass: ActionClassReference?
)

data class ActionClassReference(
    @SerializedName("name") val name: String?
)

data class ActionClass(
    @SerializedName("id") val id: String?,
    @SerializedName("type") val type: String?,
    @SerializedName("name") val name: String?,
    @SerializedName("key") val key: String?,
    @SerializedName("noCodeConfig") val noCodeConfig: String?
)

data class Project(
    @SerializedName("id") val id: String?,
    @SerializedName("recontactDays") val recontactDays: Int?,
    @SerializedName("clickOutsideClose") val clickOutsideClose: Boolean?,
    @SerializedName("darkOverlay") val darkOverlay: Boolean?,
    @SerializedName("placement") val placement: String?,
    @SerializedName("inAppSurveyBranding") val inAppSurveyBranding: Boolean?,
    @SerializedName("styling") val styling: Styling?
)

data class Styling(
    @SerializedName("brandColor") val brandColor: BrandColor?,
    @SerializedName("allowStyleOverwrite") val allowStyleOverwrite: Boolean?
)

data class BrandColor(
    @SerializedName("light") val light: String?
)
