package com.formbricks.formbrickssdk.api

import com.formbricks.formbrickssdk.Formbricks
import com.formbricks.formbrickssdk.model.display.PostDisplayBody
import com.formbricks.formbrickssdk.model.display.PostDisplayResponse
import com.formbricks.formbrickssdk.model.environment.EnvironmentDataHolder
import com.formbricks.formbrickssdk.model.response.PostSurveyResponse
import com.formbricks.formbrickssdk.model.response.PostSurveyResponseBody
import com.formbricks.formbrickssdk.model.response.SurveyResponse
import com.formbricks.formbrickssdk.model.response.UpdateSurveyResponseBody
import com.formbricks.formbrickssdk.model.upload.FetchStorageUrlRequestBody
import com.formbricks.formbrickssdk.model.upload.FetchStorageUrlResponse
import com.formbricks.formbrickssdk.model.user.PostUserBody
import com.formbricks.formbrickssdk.model.user.UserResponse
import com.formbricks.formbrickssdk.network.FormbricksApiService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

object FormbricksApi {
    private val service = FormbricksApiService()

    fun initialize() {
        service.initialize(
            appUrl = Formbricks.appUrl,
            isLoggingEnabled = Formbricks.loggingEnabled
        )
    }

    suspend fun getEnvironmentState(): Result<EnvironmentDataHolder> = withContext(Dispatchers.IO) {
        try {
            val response = service.getEnvironmentStateObject(Formbricks.environmentId)
            val result = response.getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun postSurveyResponse(surveyId: String, userId: String?, displayId: String?, response: SurveyResponse): Result<PostSurveyResponse> = withContext(Dispatchers.IO) {
        try {
            val r = service.postSurveyResponse(Formbricks.environmentId, PostSurveyResponseBody.create(surveyId, userId, displayId, response))
            val result = r.getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateSurveyResponse(responseId: String, response: SurveyResponse): Result<Any> = withContext(Dispatchers.IO) {
        try {
            val r = service.updateSurveyResponse(Formbricks.environmentId, responseId, UpdateSurveyResponseBody.create(response))
            val result = r.getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun postDisplay(userId: String?, surveyId: String): Result<PostDisplayResponse> = withContext(Dispatchers.IO) {
        try {
            val result = service.postDisplay(Formbricks.environmentId, PostDisplayBody.create(surveyId, userId)).getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateDisplay(surveyId: String, displayId: String, userId: String?): Result<Any> = withContext(Dispatchers.IO) {
        try {
            val result = service.updateDisplay(Formbricks.environmentId, displayId, PostDisplayBody.create(surveyId, userId)).getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun postUser(userId: String, attributes: Map<String, *>?): Result<UserResponse> = withContext(Dispatchers.IO) {
        try {
            val result = service.postUser(Formbricks.environmentId, PostUserBody.create(userId, attributes)).getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun fetchUploadUrl(fileName: String, fileType: String, allowedFileExtensions: List<String>?, surveyId: String): Result<FetchStorageUrlResponse> = withContext(Dispatchers.IO) {
        try {
            val result = service.fetchUploadUrl(Formbricks.environmentId, FetchStorageUrlRequestBody.create(fileName, fileType, allowedFileExtensions, surveyId)).getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}