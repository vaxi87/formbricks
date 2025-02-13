package com.formbricks.formbrickssdk.model.environment

import com.google.gson.Gson
import com.google.gson.JsonElement
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Date

data class EnvironmentDataHolder(
    val data: EnvironmentResponseData?,
    val originalResponseMap: Map<String, Any>
)

fun EnvironmentDataHolder.expiresAt(): Date? {
    data?.expiresAt?.let {
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        val dateTime = LocalDateTime.parse(it, formatter)
        return Date.from(dateTime.atZone(ZoneId.of("GMT")).toInstant())
    }

    return null
}

@Suppress("UNCHECKED_CAST")
fun EnvironmentDataHolder.getFirstSurveyJson(): JsonElement? {
    val responseMap = originalResponseMap["data"] as? Map<*, *>
    val dataMap = responseMap?.get("data") as? Map<*, *>
    val surveyArray = dataMap?.get("surveys") as? ArrayList<*>
    val firstSurvey = surveyArray?.firstOrNull() as? Map<String, Any?>
    firstSurvey?.let {
        return Gson().toJsonTree(it)
    }

    return null
}

@Suppress("UNCHECKED_CAST")
fun EnvironmentDataHolder.getStylingJson(): JsonElement? {
    val responseMap = originalResponseMap["data"] as? Map<*, *>
    val dataMap = responseMap?.get("data") as? Map<*, *>
    val projectMap = dataMap?.get("project") as? Map<*, *>
    val stylingMap = projectMap?.get("styling") as? Map<String, Any?>
    stylingMap?.let {
        return Gson().toJsonTree(it)
    }

    return null
}