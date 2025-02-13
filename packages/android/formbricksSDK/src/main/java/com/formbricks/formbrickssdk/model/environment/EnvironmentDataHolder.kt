package com.formbricks.formbrickssdk.model.environment

import com.formbricks.formbrickssdk.helper.mapToJsonElement
import com.formbricks.formbrickssdk.model.EnvironmentResponseData
import com.google.gson.Gson
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import kotlinx.serialization.json.jsonObject

data class EnvironmentDataHolder(
    val data: EnvironmentResponseData?,
    val originalResponseMap: Map<String, Any>
)

@Suppress("UNCHECKED_CAST")
fun EnvironmentDataHolder.getFirstSurveyJson(): JsonElement? {
    val responseMap = originalResponseMap["data"] as? Map<*, *>
    val dataMap = responseMap?.get("data") as? Map<*, *>
    val surveyArray = dataMap?.get("surveys") as? ArrayList<*>
    val firstSurvey = surveyArray?.firstOrNull() as? Map<String, Any?>
    firstSurvey?.let {
        return Gson().toJsonTree(it)
//        val firstSurveyJson = mapToJsonElement(it).jsonObject
//        val str = firstSurveyJson.toString()
//        return str.replace("\\\"","'")
//        return Gson().toJson(it).toString()
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
//        val stylingJson = mapToJsonElement(it).jsonObject
//        val str = stylingJson.toString()
//        return str.replace("#", "%23")
////        return Gson().toJson(it).toString()
    }

    return null
}