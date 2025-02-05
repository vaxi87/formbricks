package com.formbricks.formbrickssdk.network

import com.formbricks.formbrickssdk.api.error.FormbricksAPIError
import com.formbricks.formbrickssdk.helper.mapToJsonElement
import com.formbricks.formbrickssdk.model.display.PostDisplayBody
import com.formbricks.formbrickssdk.model.display.PostDisplayResponse
import com.formbricks.formbrickssdk.model.environment.EnvironmentResponse
import com.formbricks.formbrickssdk.model.environment.EnvironmentDataHolder
import com.formbricks.formbrickssdk.model.response.PostSurveyResponse
import com.formbricks.formbrickssdk.model.response.PostSurveyResponseBody
import com.formbricks.formbrickssdk.model.response.UpdateSurveyResponseBody
import com.formbricks.formbrickssdk.model.upload.FetchStorageUrlRequestBody
import com.formbricks.formbrickssdk.model.upload.FetchStorageUrlResponse
import com.formbricks.formbrickssdk.model.upload.FileUploadBody
import com.formbricks.formbrickssdk.model.user.PostUserBody
import com.formbricks.formbrickssdk.model.user.UserResponse
import com.google.gson.Gson
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.jsonObject
import retrofit2.Call
import retrofit2.Retrofit

class FormbricksFileUploadService(appUrl: String, isLoggingEnabled: Boolean) {
    private var retrofit: Retrofit = FormbricksRetrofitBuilder(appUrl, isLoggingEnabled)
        .getBuilder()
        .build()


    fun uploadFile(path: String, body: FileUploadBody): Result<Map<String, *>> {
        return execute {
            retrofit.create(FormbricksService::class.java)
                .uploadFile(path, body)
        }
    }

    private inline fun <T> execute(apiCall: () -> Call<T>): Result<T> {
        val call = apiCall().execute()
        return if (call.isSuccessful) {
            val body = call.body()
            if (body == null) {
                Result.failure(RuntimeException("Invalid response"))
            } else {
                Result.success(body)
            }
        } else {
            return try {
                val errorResponse =
                    Gson().fromJson(call.errorBody()?.string(), FormbricksAPIError::class.java)
                Result.failure(errorResponse)
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
}