package com.formbricks.formbrickssdk.model

import com.google.gson.annotations.SerializedName
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonIgnoreUnknownKeys


// TODO: split this to files
@Serializable
data class EnvironmentResponse(
    @SerializedName("data") val data: EnvironmentResponseData,
): BaseFormbricksResponse

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class EnvironmentResponseData(
    @SerializedName("data") val data: EnvironmentData,
    @SerializedName("expiresAt") val expiresAt: String?
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class EnvironmentData(
    @SerializedName("surveys") val surveys: List<Survey>?,
    @SerializedName("actionClasses") val actionClasses: List<ActionClass>?,
    @SerializedName("project") val project: Project
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class Survey(
    @SerializedName("id") val id: String,
    @SerializedName("name") val name: String,
    @SerializedName("autoClose") val autoClose: Boolean?,
    @SerializedName("triggers") val triggers: List<Trigger>?,
    @SerializedName("recontactDays") val recontactDays: Int?,
    @SerializedName("displayLimit") val displayLimit: Int?,
    @SerializedName("delay") val delay: Double?,
    @SerializedName("displayPercentage") val displayPercentage: Int?
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class Trigger(
    @SerializedName("actionClass") val actionClass: ActionClassReference?
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class ActionClassReference(
    @SerializedName("name") val name: String?
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class ActionClass(
    @SerializedName("id") val id: String?,
    @SerializedName("type") val type: String?,
    @SerializedName("name") val name: String?,
    @SerializedName("key") val key: String?,
    @SerializedName("noCodeConfig") val noCodeConfig: String?
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class Project(
    @SerializedName("id") val id: String?,
    @SerializedName("recontactDays") val recontactDays: Double?,
    @SerializedName("clickOutsideClose") val clickOutsideClose: Boolean?,
    @SerializedName("darkOverlay") val darkOverlay: Boolean?,
    @SerializedName("placement") val placement: String?,
    @SerializedName("inAppSurveyBranding") val inAppSurveyBranding: Boolean?,
    @SerializedName("styling") val styling: Styling?
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class Styling(
    @SerializedName("brandColor") val brandColor: BrandColor?,
    @SerializedName("allowStyleOverwrite") val allowStyleOverwrite: Boolean?
)

@Serializable
data class BrandColor(
    @SerializedName("light") val light: String?
)
